/**
 * Módulo para el informe de Gerencias.
 * 8 columnas con cabeceras de 2 niveles (Mensual, Acumulado, Var).
 */
import {
    RPT_CLASSES,
    formatCurrency,
    getIpClass,
    getVarClass,
    getNombreMes,
    getMesCorto,
    actualizarEstadoPaginacion,
    inicializarEventListenersBase
} from './utils.js';
import {
    crearEstadoInforme,
    inicializarInforme,
    getHtmlEncabezadoBase,
    imprimirInformeUnificado
} from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

// Estándar de márgenes para informes de gerencia
const MARGENES_GERENCIA = {
    web: '1.5rem',
    pdf: '6.4mm',
    maxWidth: '1100px'
};

/**
 * Punto de entrada principal.
 */
export async function ejecutar(anio, mes, nroPagina) {
    try {
        const url = `/api/Gerencias?anio=${anio}&mes=${mes}&_=${Date.now()}`;

        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: '',
            claveAgrupacion: 'NONE',
            margenes: MARGENES_GERENCIA // Pasamos los márgenes al inicializador
        });
    } catch (error) {
        console.error('Error al ejecutar el informe de Gerencias:', error);
        throw error;
    }
}

/**
 * Renderizado de la vista principal en el modal.
 */
function _renderizarPagina(index) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    // Inyectamos variables CSS para que el contenedor respete los márgenes del JS
    const styleInline = `
        --rpt-padding-web: ${MARGENES_GERENCIA.web};
        --rpt-padding-pdf: ${MARGENES_GERENCIA.pdf};
        --rpt-max-width: ${MARGENES_GERENCIA.maxWidth};
    `;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" 
             data-informe="gerencias" 
             data-pagina-index="0" 
             role="main"
             style="${styleInline}">
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${_renderContenido()}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(0, 1, '');
}

/**
 * Genera el encabezado corporativo del informe.
 */
function _getHtmlEncabezado() {
    return getHtmlEncabezadoBase({
        tituloCorporativo: 'Informe de Contratación',
        textoBanner1: 'Elecnor',
        textoBanner2: 'Gerencias',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina
    });
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

/**
 * Gestión de la exportación a PDF.
 */
async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: () => _renderContenido(true),
        modoAgrupacion: 'NONE',
        margenes: MARGENES_GERENCIA // Pasamos los márgenes a la utilidad de impresión
    });
}

// ===================================================================
// RENDERIZADO DEL CONTENIDO
// ===================================================================

/**
 * Construye la estructura del informe.
 * Layout Central: [Mensual] [Gerencia] [Acumulado] [Variación]
 */
function _renderContenido(esImpresion = false) {
    const data = estado.informeGlobalData;
    if (!data) return '<div class="text-center p-5">Cargando datos del informe...</div>';

    if (!data.gerencias || data.gerencias.length === 0) {
        const nombreMes = getNombreMes(data.meta?.filtros?.mes);
        const anio = data.meta?.filtros?.anio || '';
        return `
            <div class="${RPT_CLASSES.INFO_ALERT}" role="alert">
                <div class="rpt-info-alert-icon"><i class="fas fa-info-circle" aria-hidden="true"></i></div>
                <h5 class="rpt-info-alert-title">No hay datos disponibles</h5>
                <p class="rpt-info-alert-text">
                    No se encontraron registros de gerencias para ${nombreMes} ${anio}.
                </p>
            </div>`;
    }

    const anioAnterior = (data.meta?.filtros?.anio - 1) || '';

    let html = `
        <div class="w-100 ${esImpresion ? '' : 'mb-4'}">
            <table class="rpt-table rpt-gerencias-layout mb-0 w-100">
                ${_getCabeceraTabla(anioAnterior)}
                <tbody>
    `;

    data.gerencias.forEach(g => {
        html += _construirHtmlFila(g);
    });

    if (data.totalGeneral) {
        html += `</tbody><tfoot class="fw-bold">`;
        html += _construirHtmlFilaTotal(data.totalGeneral);
    }

    html += `
                </tfoot>
            </table>
        </div>
    `;

    return html;
}

/**
 * Cabecera con Gerencia central y líneas segmentadas.
 */
function _getCabeceraTabla(anioAnterior) {
    const wrapH = (val, align = 'text-end') => {
        return `<div class="${align} rpt-ger-header-line">${val}</div>`;
    };

    const mesActual = estado.informeGlobalData?.meta?.filtros?.mes || 1;
    const mesAnterior = getMesCorto(mesActual - 1);
    const cartLabel = mesAnterior ? `Cart. (${mesAnterior})` : 'Cart.';

    return `
        <colgroup>
            <col class="rpt-ger-col-m">
            <col class="rpt-ger-col-m">
            <col class="rpt-ger-col-desc">
            <col class="rpt-ger-col-a">
            <col class="rpt-ger-col-a">
            <col class="rpt-ger-col-ip">
            <col class="rpt-ger-col-v-contr">
            <col class="rpt-ger-col-v-cart">
        </colgroup>
        <thead>
            <tr class="rpt-th-blue rpt-va-bottom">
                <th colspan="2" class="text-center">
                    <div class="rpt-text-corporate rpt-gerencias-group-header mb-1">Mensual</div>
                </th>
                <th class="text-center">
                    <div class="rpt-gerencias-title-center">S.G. Instalac. y Redes</div>
                </th>
                <th colspan="3" class="text-center">
                    <div class="rpt-text-corporate rpt-gerencias-group-header mb-1">Acumulado</div>
                </th>
                <th colspan="2" class="text-center">
                    <div class="rpt-text-corporate rpt-gerencias-group-header mb-1">Var/${anioAnterior}</div>
                </th>
            </tr>
            <tr class="rpt-th-blue">
                <th class="p-0">${wrapH('Objet.')}</th>
                <th class="p-0">${wrapH('Contr.')}</th>
                <th class="p-0">
                    <div class="rpt-gerencias-badge">Gerencia</div>
                </th>
                <th class="p-0">${wrapH('Objet.')}</th>
                <th class="p-0">${wrapH('Contr.')}</th>
                <th class="p-0">${wrapH('Ip', 'text-center')}</th>
                <th class="p-0">${wrapH('Contr.', 'text-center')}</th>
                <th class="p-0">${wrapH(cartLabel, 'text-center')}</th>
            </tr>
        </thead>
    `;
}

/**
 * Fila con orden: [ObjM, ContrM, Gerencia, ObjA, ContrA, Ip, VarContr, VarCart]
 */
function _construirHtmlFila(g) {
    return `
        <tr class="rpt-detail-row rpt-gerencias-detail-row">
            <td class="rpt-number-cell" data-label="Objet. Mensual">${formatCurrency(g.objetivoMensual, 0)}</td>
            <td class="rpt-number-cell" data-label="Contr. Mensual">${formatCurrency(g.contratacionMensual, 0)}</td>
            <td class="ps-2" data-label="Gerencia">${_escapeHtml(g.actividad)}</td>
            <td class="rpt-number-cell" data-label="Objet. Acum.">${formatCurrency(g.objetivoAnual, 0)}</td>
            <td class="rpt-number-cell" data-label="Contr. Acum.">${formatCurrency(g.contratacionAcumulada, 0)}</td>
            <td class="text-center ${getIpClass(g.indiceProduccion)}" data-label="IP">
                ${formatCurrency(g.indiceProduccion, 2)}
            </td>
            <td class="text-center ${getVarClass(g.variacionContratacion)}" data-label="Var. Contr.">
                ${g.variacionContratacion || '0%'}
            </td>
            <td class="text-center ${getVarClass(g.variacionCartera)}" data-label="Var. Cartera">
                ${g.variacionCartera || '0%'}
            </td>
        </tr>
    `;
}

/**
 * Fila de totales con líneas segmentadas (divs con border-top).
 * rpt-va-top y p-0 para asegurar alineación perfecta.
 */
function _construirHtmlFilaTotal(t) {
    const wrapT = (val, align = 'text-end') => {
        return `<div class="${align} rpt-ger-total-cell">${val}</div>`;
    };

    return `
        <tr class="rpt-total-row-gerencia">
            <td class="rpt-number-cell p-0 rpt-va-top" data-label="Objet. Mensual">
                ${wrapT(formatCurrency(t.objetivoMensual, 0))}
            </td>
            <td class="rpt-number-cell p-0 rpt-va-top" data-label="Contr. Mensual">
                ${wrapT(formatCurrency(t.contratacionMensual, 0))}
            </td>
            <td class="p-0 rpt-va-top" data-label="Gerencia">
                ${wrapT('&nbsp;', 'text-start')}
            </td>
            <td class="rpt-number-cell p-0 rpt-va-top" data-label="Objet. Acum.">
                ${wrapT(formatCurrency(t.objetivoAnual, 0))}
            </td>
            <td class="rpt-number-cell p-0 rpt-va-top" data-label="Contr. Acum.">
                ${wrapT(formatCurrency(t.contratacionAcumulada, 0))}
            </td>
            <td class="text-center p-0 rpt-va-top" data-label="IP">
                ${wrapT(formatCurrency(t.indiceProduccion, 2), 'text-center')}
            </td>
            <td class="text-center p-0 rpt-va-top" data-label="Var. Contr.">
                ${wrapT(t.variacionContratacion || '0%', 'text-center')}
            </td>
            <td class="text-center p-0 rpt-va-top" data-label="Var. Cartera">
                ${wrapT(t.variacionCartera || '0%', 'text-center')}
            </td>
        </tr>
    `;
}

// ===================================================================
// HELPERS
// ===================================================================

/**
 * Escapa caracteres HTML para prevenir XSS.
 */
function _escapeHtml(text) {
    const map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
    return String(text).replace(/[&<>"']/g, m => map[m]);
}
