/**
 * Gestor Central de Informes
 * Se encarga de la carga dinámica de módulos de informes para mantener el Index ligero.
 *
 * PATRÓN: Registro de módulos (Module Registry).
 * Cada módulo se importa UNA SOLA VEZ y se reutiliza en sucesivas llamadas.
 * Esto evita la multiplicación de event listeners cuando el usuario abre/cierra
 * el modal varias veces, ya que el import() dinámico con cache-buster generaría
 * un contexto de módulo nuevo (y por tanto variables de estado nuevas) en cada llamada.
 */
import { GlobalUI } from '../site.js';

// Registro interno: { [nombreInforme]: moduloImportado }
const _registroModulos = {};

/**
 * Elimina del DOM todos los links de CSS dinámicos de informes.
 * Evita la acumulación de etiquetas <link> y posibles colisiones de estilos.
 */
export function limpiarCssInformes() {
    const links = document.querySelectorAll('link[id^="css-informe-"]');
    links.forEach(link => link.remove());
}

window.cargarInforme = async function (btn, nombreInforme) {

    // Mantener compatibilidad si se llama solo con nombreInforme
    if (typeof btn === 'string') {
        nombreInforme = btn;
        btn = null;
    }

    const anio = document.getElementById('txtAnno').value;
    const mes  = document.getElementById('txtMes').value;
    
    // Capturar nro de página si el botón indica un input de origen
    const idInputPag = btn?.dataset?.inputPag;
    const nroPagina  = idInputPag ? document.getElementById(idInputPag)?.value : null;

    // Capturar mercado si existe (para informes duales como Ranking Clientes)
    const mercado = btn?.dataset?.mercado;

    // Capturar umbral si existe (para informes como Paises/Paises Relevantes)
    const umbral = btn?.dataset?.umbral;

    // Capturar si se debe mostrar el título
    const mostrarTitulo = btn?.dataset?.mostrarTitulo !== 'false';

    // Resolver limiteImporte: inputLimiteMonto vs data-limiteimporte del botón
    const limiteImporteInput = document.getElementById('inputLimiteMonto');
    const valorInputMonto = limiteImporteInput ? parseFloat(limiteImporteInput.value) : 0;
    const limiteImporteDefault = btn?.dataset?.limiteimporte ? parseFloat(btn.dataset.limiteimporte) : null;
    const limiteImporteFinal = (!valorInputMonto || valorInputMonto === 0) && limiteImporteDefault
        ? limiteImporteDefault
        : (valorInputMonto || limiteImporteDefault || 13000);

    // Solo mostrar toast de límite de monto si el informe declara usarlo explícitamente
    const aplicaLimiteMonto = btn?.dataset?.limiteimporte !== undefined;

    // Resolver limitePaises: inputLimiteNumeroPaises vs data-limitepaises del botón
    const limitePaisesInput = document.getElementById('inputLimiteNumeroPaises');
    const valorInputPaises = limitePaisesInput ? parseInt(limitePaisesInput.value, 10) : 0;
    const limitePaisesDefault = btn?.dataset?.limitepaises ? parseInt(btn.dataset.limitepaises, 10) : null;
    const limitePaisesFinal = (!valorInputPaises || valorInputPaises === 0) && limitePaisesDefault
        ? limitePaisesDefault
        : (valorInputPaises || limitePaisesDefault || 20);

    let exito = false;

    try {
        GlobalUI.showLoading();

        // 1. Cargar CSS específico del informe (si no se ha cargado ya)
        const idCss = `css-informe-${nombreInforme}`;
        if (!document.getElementById(idCss)) {
            const link = document.createElement('link');
            link.id   = idCss;
            link.rel  = 'stylesheet';
            link.href = `/css/informes/${nombreInforme}.css?v=${Date.now()}`;
            // No bloqueamos por el CSS, que cargue en paralelo
            document.head.appendChild(link);
        }

        // 2. Cargar módulo (Forzar siempre carga fresca para asegurar que los cambios de escala se aplican)
        const path = `./${nombreInforme}.js?v=${Date.now()}`;
        _registroModulos[nombreInforme] = await import(path);

        const modulo = _registroModulos[nombreInforme];

        if (modulo && modulo.ejecutar) {
            const _codSubDir = btn?.dataset?.subdireccion || null;
            
            // Construir objeto de parámetros (Context Object) para evitar colisiones posicionales
            const parametros = {
                anio: anio,
                mes: mes,
                nroPagina: nroPagina,
                mercado: mercado,
                umbral: btn?.dataset?.umbral || null,
                codSubDir: _codSubDir,
                mostrarTitulo: mostrarTitulo,
                limiteImporte: limiteImporteFinal,
                limitePaises: limitePaisesFinal,
                informe: btn?.dataset?.informe || null
            };

            await modulo.ejecutar(parametros);
            exito = true;
        } else {
            console.error(`El informe '${nombreInforme}' no exporta la función 'ejecutar'.`);
            GlobalUI.showAlert('Error en la estructura del informe', 'error');
        }

    } catch (error) {
        console.error('Error al cargar el módulo del informe:', error);
        GlobalUI.showAlert('No se pudo cargar el componente del informe', 'error');
    } finally {
        GlobalUI.hideLoading();
        if (exito && aplicaLimiteMonto) {
            const valorMiles = Math.round(limiteImporteFinal / 1000);
            GlobalUI.showAlert(`Limite Monto (miles): ${valorMiles}`, 'info', 'Filtro aplicado');
        }
    }
};
