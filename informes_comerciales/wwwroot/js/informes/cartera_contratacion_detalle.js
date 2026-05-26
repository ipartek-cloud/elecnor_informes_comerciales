/**
 * Módulo para el informe Cartera Contratación (Detalle) Nacional - Internacional.
 * Patrón: Sábana continua (página única) con paginación lógica deshabilitada.
 * Estándares: Print-Perfect Parity V-01..V-22.
 */
import {
    RPT_CLASSES,
    formatCurrency,
    escapeHtml,
    actualizarEstadoPaginacion,
    inicializarEventListenersBase
} from './utils.js';
import {
    crearEstadoInforme,
    inicializarInforme,
    getHtmlEncabezadoBase,
    getStyleVars,
    MARGENES_ESTANDAR
} from './informes_unificados_utils.js';
import { ApiClient, GlobalUI } from '../site.js';

const estado = crearEstadoInforme();

/**
 * Punto de entrada llamado por el gestor de informes.
 * @param {object} params - Objeto de parámetros
 */
export async function ejecutar({ anio, mes, nroPagina, mercado = 'Todo', limiteImporte, limitePaises, informe = '9.1', mostrarTitulo }) {
    try {
        const url = `/api/CarteraContratacionDetalle?anio=${anio}&mes=${mes}&mercado=${encodeURIComponent(mercado)}&limiteImporte=${limiteImporte}&limitePaises=${limitePaises}&informe=${encodeURIComponent(informe)}&_=${Date.now()}`;

        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: 'Página',
            claveAgrupacion: 'NONE', // Informe de sábana continua / página única
            margenes: MARGENES_ESTANDAR
        });
    } catch (error) {
        console.error('[CarteraContratacionDetalle] Error:', error);
        throw error;
    }
}

/**
 * Renderiza la vista única del informe (todos los datos en sábana).
 */
function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const data = estado.informeGlobalData;
    if (!data.agrupaciones || data.agrupaciones.length === 0) {
        _mostrarSinDatos(data);
        return;
    }

    // Construir contenido: todos los grupos (años) en sábana continua
    const gruposHtml = data.agrupaciones.map((g, idx) =>
        _renderGrupo(g, idx === 0)
    ).join('<div class="rpt-page-break"></div>');

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="cartera_contratacion_detalle" role="main" ${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body rpt-cmai-mt-standard">
                ${gruposHtml}
                ${_renderPieInforme(data)}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(0, 1, '');
}

/**
 * Genera el encabezado corporativo + barra de subtítulo personalizada.
 */
function _getHtmlEncabezado() {
    const meta = estado.informeGlobalData?.meta;
    const filtros = meta?.filtros || {};
    const umbralMiles = filtros.limiteImporte
        ? Math.round(Number(filtros.limiteImporte) / 1000)
        : 13;

    const esInternacional = filtros.mercado && filtros.mercado.toLowerCase() === 'internacional';
    const textoBanner2 = esInternacional
        ? 'Cartera de Contratación Internacional (Detalle)'
        : 'Cartera de Contratación (Detalle)';

    const headerBase = getHtmlEncabezadoBase({
        tituloCorporativo: `
            <span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container rpt-d-none">Consejo Elecnor</span>
            <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>
        `,
        textoBanner1: 'Elecnor',
        textoBanner2: textoBanner2,
        mes: filtros.mes,
        anio: filtros.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });

    // Barra de filtro: solo el indicador de umbral (Cierre y Miles ya están en el banner)
    const subtituloBarra = `
        <div class="rpt-ccd-subtitulo-bar">
            <span class="rpt-subtitle-indicator rpt-fs-11pt rpt-font-bold">Cartera > ${umbralMiles}M</span>
        </div>
    `;

    return headerBase + subtituloBarra;
}

/**
 * Renderiza un grupo (año) completo.
 * @param {object} grupo - Datos del grupo
 * @param {boolean} mostrarHeader - Si debe incluir thead (solo el primero)
 */
function _renderGrupo(grupo, mostrarHeader) {
    if (!grupo.detalles || grupo.detalles.length === 0) return '';

    const rowsHtml = grupo.detalles.map(d => `
        <tr class="${RPT_CLASSES.DETAIL_ROW}">
            <td class="rpt-ccd-col-proyecto rpt-fs-7pt">${escapeHtml(d.desOferta ?? '')}</td>
            <td class="rpt-ccd-col-cliente rpt-fs-7pt">${escapeHtml(d.nomCliente ?? '')}</td>
            <td class="rpt-ccd-col-cartera ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeCarteraOferta, 0)}</td>
            <td class="rpt-ccd-col-total ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.total, 0)}</td>
        </tr>
    `).join('');

    const theadHtml = mostrarHeader ? `
        <thead>
            <tr class="${RPT_CLASSES.TH_BLUE}">
                <th class="rpt-align-center rpt-fs-9pt rpt-font-bold">Proyecto</th>
                <th class="rpt-align-center rpt-fs-9pt rpt-font-bold">Cliente</th>
                <th class="rpt-align-end rpt-fs-9pt rpt-font-bold">Cartera</th>
                <th class="rpt-align-end rpt-fs-9pt rpt-font-bold">TOTAL</th>
            </tr>
        </thead>
    ` : '';

    const pieGrupoHtml = `
        <tbody>
            <tr class="rpt-ccd-subtotal-row rpt-font-bold">
                <td colspan="2"></td>
                <td class="rpt-ccd-col-cartera ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(grupo.totalCarteraGrupo, 0)}</td>
                <td class="rpt-ccd-col-total ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(grupo.totalSumaGrupo, 0)}</td>
            </tr>
        </tbody>
    `;

    return `
        <table class="${RPT_CLASSES.TABLE} rpt-ccd-table">
            <colgroup>
                <col class="rpt-ccd-col-proyecto">
                <col class="rpt-ccd-col-cliente">
                <col class="rpt-ccd-col-cartera">
                <col class="rpt-ccd-col-total">
            </colgroup>
            ${theadHtml}
            <tbody>
                ${rowsHtml}
            </tbody>
            ${pieGrupoHtml}
        </table>
    `;
}

/**
 * Genera las filas HTML (detalle + subtotal) de un grupo para la Tabla Maestra PDF.
 */
function _renderFilasGrupo(grupo) {
    if (!grupo.detalles || grupo.detalles.length === 0) return '';

    const detallesHtml = grupo.detalles.map(d => `
        <tr class="${RPT_CLASSES.DETAIL_ROW}">
            <td class="rpt-ccd-col-proyecto rpt-fs-7pt">${escapeHtml(d.desOferta ?? '')}</td>
            <td class="rpt-ccd-col-cliente rpt-fs-7pt">${escapeHtml(d.nomCliente ?? '')}</td>
            <td class="rpt-ccd-col-cartera ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeCarteraOferta, 0)}</td>
            <td class="rpt-ccd-col-total ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.total, 0)}</td>
        </tr>
    `).join('');

    const subtotalHtml = `
        <tr class="rpt-ccd-subtotal-row rpt-font-bold">
            <td colspan="2"></td>
            <td class="rpt-ccd-col-cartera ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(grupo.totalCarteraGrupo, 0)}</td>
            <td class="rpt-ccd-col-total ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(grupo.totalSumaGrupo, 0)}</td>
        </tr>
    `;

    return detallesHtml + subtotalHtml;
}

/**
 * Renderiza el pie de informe con el total general de cartera.
 */
function _renderPieInforme(data) {
    const totales = data?.totales;
    if (!totales) return '';

    return `
        <table class="${RPT_CLASSES.TABLE} rpt-ccd-table rpt-ccd-total-general">
            <colgroup>
                <col class="rpt-ccd-col-proyecto">
                <col class="rpt-ccd-col-cliente">
                <col class="rpt-ccd-col-cartera">
                <col class="rpt-ccd-col-total">
            </colgroup>
            <tbody>
                <tr class="rpt-ccd-grand-total-row rpt-font-bold">
                    <td colspan="2" class="rpt-align-center rpt-fs-9pt">Total Cartera Contratación (miles de euros)</td>
                    <td class="rpt-ccd-col-cartera ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(totales.totalCarteraGeneral ?? 0, 0)}</td>
                    <td class="rpt-ccd-col-total ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt"></td>
                </tr>
            </tbody>
        </table>
    `;
}

/**
 * Genera las filas del pie de informe (total general) para la Tabla Maestra PDF.
 */
function _renderFilasPieInforme(data) {
    const totales = data?.totales;
    if (!totales) return '';

    return `
        <tr class="rpt-ccd-grand-total-row rpt-font-bold">
            <td colspan="2" class="rpt-align-center rpt-fs-9pt">Total Cartera Contratación (miles de euros)</td>
            <td class="rpt-ccd-col-cartera ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(totales.totalCarteraGeneral ?? 0, 0)}</td>
            <td class="rpt-ccd-col-total ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt"></td>
        </tr>
    `;
}

function _mostrarSinDatos(data) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;
    container.innerHTML = `
        <div class="${RPT_CLASSES.INFO_ALERT}" role="alert">
            <div class="rpt-info-alert-icon"><i class="fas fa-info-circle" aria-hidden="true"></i></div>
            <h5 class="rpt-info-alert-title">No hay datos disponibles</h5>
            <p class="rpt-info-alert-text">No se encontraron registros para ${data.meta?.filtros?.anio || ''}.</p>
        </div>
    `;
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

/**
 * Genera la Tabla Maestra para el PDF con encabezado corporativo repetible en cada página.
 */
function _renderTablaMaestraPDF() {
    const data = estado.informeGlobalData;
    const gruposHtml = data.agrupaciones.map(g => _renderFilasGrupo(g)).join('');
    const pieHtml = _renderFilasPieInforme(data);

    return `
        <table class="${RPT_CLASSES.TABLE} rpt-ccd-table rpt-table-print-master">
            <colgroup>
                <col class="rpt-ccd-col-proyecto">
                <col class="rpt-ccd-col-cliente">
                <col class="rpt-ccd-col-cartera">
                <col class="rpt-ccd-col-total">
            </colgroup>
            <thead class="rpt-print-thead-corporate">
                <tr class="rpt-print-thead-row">
                    <th colspan="4" class="rpt-print-thead-cell">
                        ${_getHtmlEncabezado()}
                    </th>
                </tr>
                <tr class="rpt-font-bold rpt-table-header-columns">
                    <th class="rpt-text-corporate rpt-align-center rpt-fs-9pt">Proyecto</th>
                    <th class="rpt-text-corporate rpt-align-center rpt-fs-9pt">Cliente</th>
                    <th class="rpt-text-corporate rpt-align-end rpt-fs-9pt">Cartera</th>
                    <th class="rpt-text-corporate rpt-align-end rpt-fs-9pt">TOTAL</th>
                </tr>
            </thead>
            <tfoot class="rpt-print-tfoot-master">
                <tr><td colspan="4" class="rpt-print-tfoot-cell"></td></tr>
            </tfoot>
            <tbody>
                ${gruposHtml}
                ${pieHtml}
            </tbody>
        </table>
    `;
}

async function _imprimirInforme() {
    const contenidoHtml = _renderTablaMaestraPDF();
    const styleVars = getStyleVars(estado.margenes);

    const capaPrint = document.createElement('div');
    capaPrint.className = 'rpt-print-layer';
    capaPrint.innerHTML = `
        <div class="rpt-paper rpt-paper--print" data-informe="cartera_contratacion_detalle" ${styleVars}>
            <div class="report-body">
                ${contenidoHtml}
            </div>
        </div>`;
    document.body.appendChild(capaPrint);

    const originalTitle = document.title;
    try {
        await new Promise(resolve => setTimeout(resolve, 300));
        document.title = '';
        window.print();
    } finally {
        document.title = originalTitle;
        if (document.body.contains(capaPrint)) {
            document.body.removeChild(capaPrint);
        }
    }
}

function _getNombreMes(mes) {
    const meses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    return meses[(mes || 1) - 1] || '';
}
