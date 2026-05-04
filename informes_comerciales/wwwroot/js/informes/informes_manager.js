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

    // Forzar Subdirección si el botón lo exige explícitamente
    if (btn && btn.dataset && btn.dataset.subdireccion) {
        const cmbSubDir = document.getElementById('cmbSubDireccionGeneral');
        if (cmbSubDir) {
            cmbSubDir.value = btn.dataset.subdireccion;
        }
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
            const _codSubDir = document.getElementById('cmbSubDireccionGeneral')?.value || null;
            
            // Construir objeto de parámetros (Context Object) para evitar colisiones posicionales
            const parametros = {
                anio: anio,
                mes: mes,
                nroPagina: nroPagina,
                mercado: mercado,
                umbral: btn?.dataset?.umbral || null,
                codSubDir: _codSubDir,
                mostrarTitulo: mostrarTitulo,
                limiteImporte: btn?.dataset?.limiteimporte || null,
                limitePaises: btn?.dataset?.limitepaises || null,
                informe: btn?.dataset?.informe || null
            };

            await modulo.ejecutar(parametros);
        } else {
            console.error(`El informe '${nombreInforme}' no exporta la función 'ejecutar'.`);
            GlobalUI.showAlert('Error en la estructura del informe', 'error');
        }

    } catch (error) {
        console.error('Error al cargar el módulo del informe:', error);
        GlobalUI.showAlert('No se pudo cargar el componente del informe', 'error');
    } finally {
        GlobalUI.hideLoading();
    }
};
