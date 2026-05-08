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

/**
 * Inicializa los bocadillos de previsualización (Tooltips) para los botones de informe.
 * Utiliza Tippy.js para mostrar los filtros reales que se aplicarán.
 */
function inicializarTooltipsFiltros() {
    if (typeof tippy === 'undefined') return;

    // Destruir instancias previas para evitar duplicados
    tippy.destroyAll?.();

    tippy('.btn.rpt-btn-index', {
        theme: 'elecnor',
        placement: 'top',
        allowHTML: true,
        animation: 'fade',
        arrow: true,
        onShow(instance) {
            const btn = instance.reference;
            const ds = btn.dataset;
            
            // 1. Obtener valores globales (Inputs)
            const valorInputMonto = parseFloat(document.getElementById('inputLimiteMonto')?.value || 0);
            const valorInputPaises = parseInt(document.getElementById('inputLimiteNumeroPaises')?.value || 0, 10);

            // 2. Obtener valores por defecto del botón
            const limiteImporteDefault = ds.limiteimporte ? parseFloat(ds.limiteimporte) : null;
            const limitePaisesDefault = ds.limitepaises ? parseInt(ds.limitepaises, 10) : null;

            // 3. Resolver Jerarquía (REPLICA EXACTA DE CARGARINFORME)
            // Lógica: Si el input es 0 o vacío, manda el botón. Si el input tiene valor, manda el input.
            const montoReal = (!valorInputMonto || valorInputMonto === 0) && limiteImporteDefault
                ? limiteImporteDefault
                : (valorInputMonto || limiteImporteDefault || 13000);

            const paisesReal = (!valorInputPaises || valorInputPaises === 0) && limitePaisesDefault
                ? limitePaisesDefault
                : (valorInputPaises || limitePaisesDefault || 20);

            let umbral = ds.umbral;

            // 4. Construir HTML del bocadillo
            let content = `<div class="p-1">`;
            content += `<div class="mb-1"><strong>Filtros Activos</strong></div>`;
            
            let tieneInfo = false;

            // B. Filtro de Monto
            if (ds.limiteimporte !== undefined || ds.informe?.includes('cartera') || ds.informe?.includes('detalle')) {
                const valorM = montoReal / 1000;
                // Formatear a 1 decimal y convertir de nuevo a número para eliminar .0 si existe
                const displayMonto = Number(valorM.toFixed(1));
                content += `<div>Monto: ${displayMonto}M</div>`;
                tieneInfo = true;
            }

            // C. Filtro de Países
            if (ds.limitepaises !== undefined || ds.informe?.includes('cartera') || ds.informe?.includes('detalle')) {
                content += `<div>Países: ${paisesReal}</div>`;
                tieneInfo = true;
            }

            // D. Umbral de Filtrado
            if (umbral !== undefined && umbral !== null && umbral !== "") {
                const num = parseFloat(umbral);
                const displayUmbral = num === 0 ? "0" : Math.round(num / 1000) + "k";
                content += `<div>Umbral: ${displayUmbral}</div>`;
                tieneInfo = true;
            }

            content += `</div>`;

            if (!tieneInfo) return false;

            instance.setContent(content);
        }
    });
}

// Inicializar cuando el DOM esté listo o se cargue el script
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', inicializarTooltipsFiltros);
} else {
    inicializarTooltipsFiltros();
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
    // Normalizar: parsear a entero y tratar 0 como null (sin número de página)
    const idInputPag = btn?.dataset?.inputPag;
    const rawPag = idInputPag ? document.getElementById(idInputPag)?.value : null;
    const nroPagina = rawPag != null ? parseInt(rawPag, 10) : null;
    const nroPaginaFinal = nroPagina > 0 ? nroPagina : null;

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
                nroPagina: nroPaginaFinal,
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
