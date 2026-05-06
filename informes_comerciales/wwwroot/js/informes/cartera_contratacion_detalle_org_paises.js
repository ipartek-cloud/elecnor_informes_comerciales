/**
 * Informe: Cartera Contratación DG (Detalle) Organización Países
 * Patrón: Sábana continua (página única) con Tabla Maestra para PDF.
 */
import {
    RPT_CLASSES, formatCurrency, escapeHtml,
    actualizarEstadoPaginacion, inicializarEventListenersBase
} from './utils.js';
import {
    crearEstadoInforme, inicializarInforme,
    getHtmlEncabezadoBase, getStyleVars
} from './informes_unificados_utils.js';
import { ApiClient } from '../site.js';

const estado = crearEstadoInforme();

export async function ejecutar({ anio, mes, nroPagina, mercado = 'Todo', limiteImporte, limitePaises, informe = '8.1', mostrarTitulo, codSubDir }) {
    try {
        const subDir = codSubDir || '221';
        const url = `/api/CarteraContratacionDetalleOrgPaises?anio=${anio}&mes=${mes}&mercado=${encodeURIComponent(mercado)}&limiteImporte=${limiteImporte}&limitePaises=${limitePaises}&informe=${encodeURIComponent(informe)}&codSubDirGeneral=${encodeURIComponent(subDir)}&_=${Date.now()}`;

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
            margenes: { web: '16mm', pdf: '16mm', maxWidth: '1050px' }
        });
    } catch (error) {
        console.error('[CarteraContratacionDetalleOrgPaises] Error:', error);
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

    // Renderizar todos los grupos (años) en sábana continua
    const gruposHtml = data.agrupaciones.map((g, idx) =>
        _renderGrupo(g, idx === 0)
    ).join('<div class="rpt-page-break"></div>');

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="cartera_contratacion_detalle_org_paises" role="main" ${getStyleVars(estado.margenes)}>
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
        : 13;
    const tipoDg = filtros.codSubDirGeneral === '286' ? 'Proyectos' : 'Servicios';

    const headerBase = getHtmlEncabezadoBase({
        tituloCorporativo: `
            <span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container">Consejo Elecnor</span>
            <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>
        `,
        textoBanner1: 'Elecnor',
        textoBanner2: `Cartera Contratación DG ${tipoDg} (Detalle)`,
        mes: filtros.mes,
        anio: filtros.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });

    const subtituloBarra = `
        <div class="rpt-ccdop-subtitulo-bar">
            <span class="rpt-subtitle-indicator rpt-fs-10pt rpt-font-bold">Cartera > ${umbralMiles}M</span>
        </div>
    `;

    return headerBase + subtituloBarra;
}

function _renderGrupo(grupo, mostrarHeader) {
    const meta = estado.informeGlobalData?.meta;
    const filtros = meta?.filtros || {};
    const anioAnterior = (filtros.anio || new Date().getFullYear()) - 1;
    const anioActual = filtros.anio || new Date().getFullYear();

    const dnHtml = grupo.direccionesNegocio.map((dn, dnIdx, allDn) => {
        const paisesHtml = dn.paises.map((pais) => {
            const detalleHtml = pais.detalles.map(d => `
                <tr class="${RPT_CLASSES.DETAIL_ROW}">
                    <td class="rpt-ccdop-col-cliente rpt-fs-7pt">${escapeHtml(d.nomCliente ?? '')}</td>
                    <td class="rpt-ccdop-col-proyecto rpt-fs-7pt">${escapeHtml(d.desOferta ?? '')}</td>
                    <td class="rpt-ccdop-col-anterior ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeCarteraOfertaAnterior, 0)}</td>
                    <td class="rpt-ccdop-col-actual ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeCarteraOferta, 0)}</td>
                    <td class="rpt-ccdop-col-total ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeTotalOferta, 0)}</td>
                </tr>
            `).join('');

            return `
                <tr class="rpt-ccdop-pais-header rpt-font-bold">
                    <td colspan="2" class="rpt-fs-8pt">${escapeHtml(pais.nombrePais ?? '')}</td>
                    <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(pais.importeCarteraPaisAnterior, 0)}</td>
                    <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(pais.importeCarteraPais, 0)}</td>
                    <td></td>
                </tr>
                ${detalleHtml}
            `;
        }).join('');

        const separatorHtml = dnIdx < allDn.length - 1
            ? '<tr class="rpt-ccdop-dn-separator"><td colspan="5"></td></tr>'
            : '';

        return `
            <tr class="rpt-ccdop-dn-header rpt-font-bold">
                <td colspan="2" class="rpt-fs-10pt">${escapeHtml(dn.nombreDirNegocio ?? '')}</td>
                <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(dn.importeCarteraDNAnterior, 0)}</td>
                <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(dn.importeCarteraDN, 0)}</td>
                <td></td>
            </tr>
            ${paisesHtml}
            ${separatorHtml}
        `;
    }).join('');

    const theadHtml = mostrarHeader ? `
        <thead>
            <tr>
                <th colspan="2" class="rpt-align-center rpt-fs-9pt rpt-font-bold"></th>
                <th colspan="2" class="rpt-align-center rpt-fs-9pt rpt-font-bold rpt-text-corporate rpt-ccdop-acumulado-border">Acumulado</th>
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
        <table class="${RPT_CLASSES.TABLE} rpt-ccdop-table">
            <colgroup>
                <col class="rpt-ccdop-col-cliente">
                <col class="rpt-ccdop-col-proyecto">
                <col class="rpt-ccdop-col-anterior">
                <col class="rpt-ccdop-col-actual">
                <col class="rpt-ccdop-col-total">
            </colgroup>
            ${theadHtml}
            <tbody>
                ${dnHtml}
            </tbody>
        </table>
    `;
}

function _renderPieInforme(data) {
    const totales = data?.totales;
    if (!totales) return '';

    return `
        <table class="${RPT_CLASSES.TABLE} rpt-ccdop-table rpt-ccdop-total-general">
            <colgroup>
                <col class="rpt-ccdop-col-cliente">
                <col class="rpt-ccdop-col-proyecto">
                <col class="rpt-ccdop-col-anterior">
                <col class="rpt-ccdop-col-actual">
                <col class="rpt-ccdop-col-total">
            </colgroup>
            <tbody>
                <tr class="rpt-ccdop-grand-total-row rpt-font-bold">
                    <td colspan="2"></td>
                    <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt rpt-ccdop-totals-border">${formatCurrency(totales.sumaCarteraPaisAnterior ?? 0, 0)}</td>
                    <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt rpt-ccdop-totals-border">${formatCurrency(totales.sumaCarteraPais ?? 0, 0)}</td>
                    <td></td>
                </tr>
                <tr class="rpt-ccdop-grand-total-row rpt-font-bold">
                    <td colspan="2" class="rpt-align-end rpt-fs-9pt rpt-ccdop-total-label">Total Cartera Contratación (miles de euros)</td>
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

// ═══════════════════════════════════════════════════════════════════════════════
// TABLA MAESTRA PARA PDF (thead repetido en cada página)
// ═══════════════════════════════════════════════════════════════════════════════
function _renderTablaMaestraPDF() {
    const data = estado.informeGlobalData;
    const meta = data?.meta;
    const filtros = meta?.filtros || {};
    const anioAnterior = (filtros.anio || new Date().getFullYear()) - 1;
    const anioActual = filtros.anio || new Date().getFullYear();

    const gruposHtml = data.agrupaciones.map(g => _renderFilasGrupoPDF(g)).join('');
    const pieHtml = _renderFilasPiePDF(data);

    return `
        <table class="${RPT_CLASSES.TABLE} rpt-ccdop-table rpt-table-print-master">
            <colgroup>
                <col class="rpt-ccdop-col-cliente">
                <col class="rpt-ccdop-col-proyecto">
                <col class="rpt-ccdop-col-anterior">
                <col class="rpt-ccdop-col-actual">
                <col class="rpt-ccdop-col-total">
            </colgroup>
            <thead class="rpt-print-thead-corporate">
                <tr class="rpt-print-thead-row">
                    <th colspan="5" class="rpt-print-thead-cell">
                        ${_getHtmlEncabezado()}
                    </th>
                </tr>
                <tr class="rpt-font-bold rpt-table-header-columns">
                    <th colspan="2" class="rpt-text-corporate rpt-align-center rpt-fs-9pt"></th>
                    <th colspan="2" class="rpt-text-corporate rpt-align-center rpt-fs-9pt rpt-ccdop-acumulado-border">Acumulado</th>
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
    return grupo.direccionesNegocio.map((dn, dnIdx, allDn) => {
        const dnHeader = `
            <tr class="rpt-ccdop-dn-header rpt-font-bold">
                <td colspan="2" class="rpt-fs-10pt">${escapeHtml(dn.nombreDirNegocio ?? '')}</td>
                <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(dn.importeCarteraDNAnterior, 0)}</td>
                <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(dn.importeCarteraDN, 0)}</td>
                <td></td>
            </tr>`;

        const paisesHtml = dn.paises.map(pais => {
            const paisHeader = `
                <tr class="rpt-ccdop-pais-header rpt-font-bold">
                    <td colspan="2" class="rpt-fs-8pt">${escapeHtml(pais.nombrePais ?? '')}</td>
                    <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(pais.importeCarteraPaisAnterior, 0)}</td>
                    <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(pais.importeCarteraPais, 0)}</td>
                    <td></td>
                </tr>`;

            const detalleHtml = pais.detalles.map(d => `
                <tr class="${RPT_CLASSES.DETAIL_ROW}">
                    <td class="rpt-ccdop-col-cliente rpt-fs-7pt">${escapeHtml(d.nomCliente ?? '')}</td>
                    <td class="rpt-ccdop-col-proyecto rpt-fs-7pt">${escapeHtml(d.desOferta ?? '')}</td>
                    <td class="rpt-ccdop-col-anterior ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeCarteraOfertaAnterior, 0)}</td>
                    <td class="rpt-ccdop-col-actual ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeCarteraOferta, 0)}</td>
                    <td class="rpt-ccdop-col-total ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency(d.importeTotalOferta, 0)}</td>
                </tr>
            `).join('');

            return paisHeader + detalleHtml;
        }).join('');

        const separatorHtml = dnIdx < allDn.length - 1
            ? '<tr class="rpt-ccdop-dn-separator"><td colspan="5"></td></tr>'
            : '';

        return dnHeader + paisesHtml + separatorHtml;
    }).join('');
}

function _renderFilasPiePDF(data) {
    const totales = data?.totales;
    if (!totales) return '';

    return `
        <tr class="rpt-ccdop-grand-total-row rpt-font-bold">
            <td colspan="2"></td>
            <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt rpt-ccdop-totals-border">${formatCurrency(totales.sumaCarteraPaisAnterior ?? 0, 0)}</td>
            <td class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt rpt-ccdop-totals-border">${formatCurrency(totales.sumaCarteraPais ?? 0, 0)}</td>
            <td></td>
        </tr>
        <tr class="rpt-ccdop-grand-total-row rpt-font-bold">
            <td colspan="2" class="rpt-align-end rpt-fs-9pt rpt-ccdop-total-label">Total Cartera Contratación (miles de euros)</td>
            <td colspan="2" class="${RPT_CLASSES.NUMBER_CELL} rpt-fs-9pt rpt-text-corporate">
                ${formatCurrency(totales.totalCarteraGeneral ?? 0, 0)}
            </td>
            <td></td>
        </tr>
    `;
}

async function _imprimirInforme() {
    const contenidoHtml = _renderTablaMaestraPDF();
    const styleVars = getStyleVars(estado.margenes);

    const capaPrint = document.createElement('div');
    capaPrint.className = 'rpt-print-layer';
    capaPrint.innerHTML = `
        <div class="rpt-paper rpt-paper--print" data-informe="cartera_contratacion_detalle_org_paises" ${styleVars}>
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
