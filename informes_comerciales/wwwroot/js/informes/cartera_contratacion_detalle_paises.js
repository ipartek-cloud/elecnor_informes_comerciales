/**
 * Informe: Cartera Contratación Países (Detalle) Nacional - Internacional
 * Patrón: Sábana continua (página única) con Tabla Maestra para PDF.
 */
import {
    RPT_CLASSES, formatCurrency, escapeHtml,
    actualizarEstadoPaginacion, inicializarEventListenersBase
} from './utils.js';
import {
    crearEstadoInforme, inicializarInforme,
    getHtmlEncabezadoBase, getStyleVars, imprimirInformeUnificado, MARGENES_ESTANDAR
} from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

export async function ejecutar({ anio, mes, nroPagina, mercado = 'Todo', limiteImporte, limitePaises, informe = '9.1', mostrarTitulo }) {
    try {
        const url = `/api/CarteraContratacionDetallePaises?anio=${anio}&mes=${mes}&mercado=${encodeURIComponent(mercado)}&limiteImporte=${limiteImporte}&limitePaises=${limitePaises}&informe=${encodeURIComponent(informe)}&_=${Date.now()}`;

        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: 'Página',
            claveAgrupacion: 'NONE',
            margenes: MARGENES_ESTANDAR
        });
    } catch (error) {
        console.error('[CarteraContratacionDetallePaises] Error:', error);
        throw error;
    }
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const data = estado.informeGlobalData;
    if (!data.agrupaciones || data.agrupaciones.length === 0) {
        _mostrarSinDatos(data);
        return;
    }

    const gruposHtml = data.agrupaciones.map((g, idx) =>
        _renderGrupo(g, idx === 0)
    ).join('<div class="rpt-page-break"></div>');

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="cartera_contratacion_detalle_paises" role="main" ${getStyleVars(estado.margenes)}>
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

function _getHtmlEncabezado() {
    const meta = estado.informeGlobalData?.meta;
    const filtros = meta?.filtros || {};
    const umbralMiles = filtros.limiteImporte
        ? Math.round(Number(filtros.limiteImporte) / 1000)
        : 17;

    const esInternacional = filtros.mercado && filtros.mercado.toLowerCase() === 'internacional';
    const textoBanner2 = esInternacional
        ? 'Cartera Contratación Países (Detalle) Internacional'
        : 'Cartera Contratación Países (Detalle)';

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

    const subtituloBarra = `
        <div class="rpt-ccdp-subtitulo-bar">
            <span class="rpt-subtitle-indicator rpt-fs-11pt rpt-font-bold">Cartera > ${umbralMiles}M</span>
        </div>
    `;

    return headerBase + subtituloBarra;
}

function _renderGrupo(grupo, mostrarHeader) {
    const meta = estado.informeGlobalData?.meta;
    const filtros = meta?.filtros || {};
    const anioAnterior = (filtros.anio || new Date().getFullYear()) - 1;
    const anioActual = filtros.anio || new Date().getFullYear();

    const paisesHtml = grupo.paises.map((pais) => {
        const detalleHtml = pais.detalles.map(d => `
            <tr class="${RPT_CLASSES.DETAIL_ROW}">
                <td class="rpt-ccdp-col-cliente rpt-fs-7pt">${escapeHtml(d.nomCliente ?? '')}</td>
                <td class="rpt-ccdp-col-proyecto rpt-fs-7pt">${escapeHtml(d.desOferta ?? '')}</td>
                <td class="rpt-ccdp-col-anterior ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeCarteraOfertaAnterior, 0)}</td>
                <td class="rpt-ccdp-col-actual ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeCarteraOferta, 0)}</td>
                <td class="rpt-ccdp-col-total ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeTotalOferta, 0)}</td>
            </tr>
        `).join('');

        return `
            <tr class="rpt-ccdp-pais-header rpt-font-bold">
                <td colspan="2" class="rpt-fs-8pt">${escapeHtml(pais.nombrePais ?? '')}</td>
                <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(pais.importeCarteraPaisAnterior, 0)}</td>
                <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(pais.importeCarteraPais, 0)}</td>
                <td></td>
            </tr>
            ${detalleHtml}
        `;
    }).join('');

    const theadHtml = mostrarHeader ? `
        <thead>
            <tr>
                <th colspan="2" class="rpt-align-center rpt-fs-9pt rpt-font-bold"></th>
                <th colspan="2" class="rpt-align-center rpt-fs-9pt rpt-font-bold rpt-text-corporate rpt-ccdp-acumulado-border">Acumulado</th>
                <th class="rpt-align-center rpt-fs-9pt rpt-font-bold"></th>
            </tr>
            <tr class="${RPT_CLASSES.TH_BLUE}">
                <th class="rpt-align-center rpt-fs-9pt rpt-font-bold">Cliente</th>
                <th class="rpt-align-center rpt-fs-9pt rpt-font-bold">Proyecto</th>
                <th class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-9pt rpt-font-bold">${anioAnterior}</th>
                <th class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-9pt rpt-font-bold">${anioActual}</th>
                <th class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-9pt rpt-font-bold">Total</th>
            </tr>
        </thead>
    ` : '';

    return `
        <table class="${RPT_CLASSES.TABLE} rpt-ccdp-table">
            <colgroup>
                <col class="rpt-ccdp-col-cliente">
                <col class="rpt-ccdp-col-proyecto">
                <col class="rpt-ccdp-col-anterior">
                <col class="rpt-ccdp-col-actual">
                <col class="rpt-ccdp-col-total">
            </colgroup>
            ${theadHtml}
            <tbody>
                ${paisesHtml}
            </tbody>
        </table>
    `;
}

function _renderPieInforme(data) {
    const totales = data?.totales;
    if (!totales) return '';

    return `
        <table class="${RPT_CLASSES.TABLE} rpt-ccdp-table rpt-ccdp-total-general">
            <colgroup>
                <col class="rpt-ccdp-col-cliente">
                <col class="rpt-ccdp-col-proyecto">
                <col class="rpt-ccdp-col-anterior">
                <col class="rpt-ccdp-col-actual">
                <col class="rpt-ccdp-col-total">
            </colgroup>
            <tbody>
                <tr class="rpt-ccdp-grand-total-row rpt-font-bold">
                    <td colspan="2"></td>
                    <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt rpt-ccdp-totals-border">${formatCurrency(totales.sumaCarteraPaisAnterior ?? 0, 0)}</td>
                    <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt rpt-ccdp-totals-border">${formatCurrency(totales.sumaCarteraPais ?? 0, 0)}</td>
                    <td></td>
                </tr>
                <tr class="rpt-ccdp-grand-total-row rpt-font-bold">
                    <td colspan="2" class="rpt-align-end rpt-fs-9pt rpt-ccdp-total-label">Total Cartera Contratación (miles de euros)</td>
                    <td colspan="2" class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-9pt rpt-text-corporate">
                        ${formatCurrency(totales.totalCarteraGeneral ?? 0, 0)}
                    </td>
                    <td></td>
                </tr>
            </tbody>
        </table>
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

// ═══════════════════════════════════════════════════════════════════════════
// TABLA MAESTRA PARA PDF (thead repetido en cada página física)
// ═══════════════════════════════════════════════════════════════════════════
function _renderTablaMaestraPDF() {
    const data = estado.informeGlobalData;
    const meta = data?.meta;
    const filtros = meta?.filtros || {};
    const anioAnterior = (filtros.anio || new Date().getFullYear()) - 1;
    const anioActual = filtros.anio || new Date().getFullYear();

    const gruposHtml = data.agrupaciones.map(g => _renderFilasGrupoPDF(g)).join('');
    const pieHtml = _renderFilasPiePDF(data);

    return `
        <table class="${RPT_CLASSES.TABLE} rpt-ccdp-table rpt-table-print-master">
            <colgroup>
                <col class="rpt-ccdp-col-cliente">
                <col class="rpt-ccdp-col-proyecto">
                <col class="rpt-ccdp-col-anterior">
                <col class="rpt-ccdp-col-actual">
                <col class="rpt-ccdp-col-total">
            </colgroup>
            <thead class="rpt-print-thead-corporate">
                <tr class="rpt-print-thead-row">
                    <th colspan="5" class="rpt-print-thead-cell">
                        ${_getHtmlEncabezado()}
                    </th>
                </tr>
                <tr class="rpt-font-bold rpt-table-header-columns">
                    <th colspan="2" class="rpt-text-corporate rpt-align-center rpt-fs-9pt"></th>
                    <th colspan="2" class="rpt-text-corporate rpt-align-center rpt-fs-9pt rpt-ccdp-acumulado-border">Acumulado</th>
                    <th class="rpt-text-corporate rpt-align-center rpt-fs-9pt"></th>
                </tr>
                <tr class="rpt-font-bold rpt-table-header-columns">
                    <th class="rpt-text-corporate rpt-align-center rpt-fs-9pt">Cliente</th>
                    <th class="rpt-text-corporate rpt-align-center rpt-fs-9pt">Proyecto</th>
                    <th class="rpt-text-corporate ${RPT_CLASSES.NUMBER_CELL} rpt-fs-9pt">${anioAnterior}</th>
                    <th class="rpt-text-corporate ${RPT_CLASSES.NUMBER_CELL} rpt-fs-9pt">${anioActual}</th>
                    <th class="rpt-text-corporate ${RPT_CLASSES.NUMBER_CELL} rpt-fs-9pt">Total</th>
                </tr>
            </thead>
            <tfoot class="rpt-print-tfoot-master">
                <tr><td colspan="5" class="rpt-print-tfoot-cell"></td></tr>
            </tfoot>
            <tbody>
                ${gruposHtml}
                ${pieHtml}
            </tbody>
        </table>
    `;
}

function _renderFilasGrupoPDF(grupo) {
    return grupo.paises.map(pais => {
        const paisHeader = `
            <tr class="rpt-ccdp-pais-header rpt-font-bold">
                <td colspan="2" class="rpt-fs-8pt">${escapeHtml(pais.nombrePais ?? '')}</td>
                <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(pais.importeCarteraPaisAnterior, 0)}</td>
                <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(pais.importeCarteraPais, 0)}</td>
                <td></td>
            </tr>`;

        const detalleHtml = pais.detalles.map(d => `
            <tr class="${RPT_CLASSES.DETAIL_ROW}">
                <td class="rpt-ccdp-col-cliente rpt-fs-7pt">${escapeHtml(d.nomCliente ?? '')}</td>
                <td class="rpt-ccdp-col-proyecto rpt-fs-7pt">${escapeHtml(d.desOferta ?? '')}</td>
                <td class="rpt-ccdp-col-anterior ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeCarteraOfertaAnterior, 0)}</td>
                <td class="rpt-ccdp-col-actual ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeCarteraOferta, 0)}</td>
                <td class="rpt-ccdp-col-total ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeTotalOferta, 0)}</td>
            </tr>
        `).join('');

        return paisHeader + detalleHtml;
    }).join('');
}

function _renderFilasPiePDF(data) {
    const totales = data?.totales;
    if (!totales) return '';

    return `
        <tr class="rpt-ccdp-grand-total-row rpt-font-bold">
            <td colspan="2"></td>
            <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt rpt-ccdp-totals-border">${formatCurrency(totales.sumaCarteraPaisAnterior ?? 0, 0)}</td>
            <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt rpt-ccdp-totals-border">${formatCurrency(totales.sumaCarteraPais ?? 0, 0)}</td>
            <td></td>
        </tr>
        <tr class="rpt-ccdp-grand-total-row rpt-font-bold">
            <td colspan="2" class="rpt-align-end rpt-fs-9pt rpt-ccdp-total-label">Total Cartera Contratación (miles de euros)</td>
            <td colspan="2" class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-9pt rpt-text-corporate">
                ${formatCurrency(totales.totalCarteraGeneral ?? 0, 0)}
            </td>
            <td></td>
        </tr>
    `;
}

async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        // Este informe usa el patrón "Tabla Maestra PDF": la cabecera vive dentro
        // del <thead> de _renderTablaMaestraPDF() para que el navegador la repita
        // en cada salto de página físico. Por ello NO se inyecta cabecera exterior.
        getHtmlEncabezado: () => '',
        renderContenido: () => _renderTablaMaestraPDF(),
        modoAgrupacion: 'NONE',
        margenes: estado.margenes,
        nombreInforme: 'cartera_contratacion_detalle_paises'
    });
}
