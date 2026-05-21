/**
 * Módulo para el informe Cartera de Contratación (Resumen SDG).
 * Patrón: Sábana continua (página única) con paginación lógica deshabilitada.
 * Jerarquía: SDG (fila maestra) → DN (filas de detalle indentadas).
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
export async function ejecutar({ anio, mes, nroPagina, mercado = 'Todo', mostrarTitulo }) {
    try {
        const url = `/api/CarteraContratacionResumenSDG?anio=${anio}&mes=${mes}&mercado=${encodeURIComponent(mercado)}&_=${Date.now()}`;

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
        console.error('[CarteraContratacionResumenSDG] Error:', error);
        throw error;
    }
}

/**
 * Renderiza la vista única del informe (todos los datos en sábana continua).
 */
function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const data = estado.informeGlobalData;
    if (!data.datos || data.datos.length === 0) {
        _mostrarSinDatos(data);
        return;
    }

    const tablaHtml = _renderTabla(data);

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="cartera_contratacion_resumen_sdg" role="main" ${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body rpt-cmai-mt-standard">
                <div class="rpt-ccrsdg-subinforme-wrapper">
                    ${tablaHtml}
                    ${_renderPieInforme(data)}
                </div>
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

    const esInternacional = filtros.mercado && filtros.mercado.toLowerCase() === 'internacional';
    const textoBanner2 = esInternacional
        ? 'Cartera de Contratación Internacional (Resumen)'
        : 'Cartera de Contratación (Resumen)';

    return getHtmlEncabezadoBase({
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
}

/**
 * Renderiza la tabla principal con SDG como filas maestras y DN como subfilas.
 */
function _renderTabla(data) {
    const filasHtml = data.datos.map(sdg => _renderFilasSDG(sdg)).join('');

    return `
        <table class="${RPT_CLASSES.TABLE} rpt-ccrsdg-table">
            <colgroup>
                <col class="rpt-ccrsdg-col-dn">
                <col class="rpt-ccrsdg-col-anterior">
                <col class="rpt-ccrsdg-col-actual">
            </colgroup>
            <thead>
                <tr>
                    <th class="rpt-align-center rpt-fs-9pt rpt-font-bold"></th>
                    <th class="rpt-ccrsdg-header-acumulado rpt-align-center rpt-fs-9pt rpt-font-bold" colspan="2">Acumulado</th>
                </tr>
                <tr class="rpt-ccrsdg-header-years-row">
                    <th class="rpt-ccrsdg-header-elecnor rpt-fs-9pt rpt-font-bold">Elecnor</th>
                    <th class="rpt-align-right rpt-fs-9pt rpt-font-bold">${data.meta?.filtros?.anio - 1 || ''}</th>
                    <th class="rpt-align-right rpt-fs-9pt rpt-font-bold">${data.meta?.filtros?.anio || ''}</th>
                </tr>
            </thead>
            <tbody>
                ${filasHtml}
            </tbody>
        </table>
    `;
}

/**
 * Renderiza una SDG (fila maestra) y sus DN (subfilas indentadas).
 */
function _renderFilasSDG(sdg) {
    const dnHtml = sdg.detalleDN.map(dn => `
        <tr class="${RPT_CLASSES.DETAIL_ROW} rpt-ccrsdg-dn-row">
            <td class="rpt-ccrsdg-col-dn rpt-fs-8pt rpt-ccrsdg-dn-cell">${escapeHtml(dn.dn ?? '')}</td>
            <td class="rpt-ccrsdg-col-anterior ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((dn.totAñoAnterior ?? 0), 0)}</td>
            <td class="rpt-ccrsdg-col-actual ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((dn.totAño ?? 0), 0)}</td>
        </tr>
    `).join('');

    const sdgHtml = `
        <tr class="rpt-ccrsdg-sdg-row rpt-font-bold">
            <td class="rpt-ccrsdg-col-dn rpt-fs-8pt rpt-ccrsdg-sdg-cell">${escapeHtml(sdg.nombreSubDirGeneral ?? sdg.codSubDirGeneral)}</td>
            <td class="rpt-ccrsdg-col-anterior ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((sdg.totalAñoAnterior ?? 0), 0)}</td>
            <td class="rpt-ccrsdg-col-actual ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((sdg.totalAño ?? 0), 0)}</td>
        </tr>
    `;

    return sdgHtml + dnHtml;
}

/**
 * Renderiza el pie de informe con los totales globales.
 */
function _renderPieInforme(data) {
    const totales = data?.totales;
    if (!totales) return '';

    return `
        <table class="${RPT_CLASSES.TABLE} rpt-ccrsdg-table rpt-ccrsdg-total-general">
            <colgroup>
                <col class="rpt-ccrsdg-col-dn">
                <col class="rpt-ccrsdg-col-anterior">
                <col class="rpt-ccrsdg-col-actual">
            </colgroup>
            <tbody>
                <tr class="rpt-ccrsdg-grand-total-row rpt-font-bold">
                    <td class="rpt-ccrsdg-col-dn rpt-fs-8pt rpt-align-center"></td>
                    <td class="rpt-ccrsdg-col-anterior ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((totales.totalGeneralAñoAnterior ?? 0), 0)}</td>
                    <td class="rpt-ccrsdg-col-actual ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((totales.totalGeneralAño ?? 0), 0)}</td>
                </tr>
            </tbody>
        </table>
    `;
}

/**
 * Genera las filas de la Tabla Maestra para el PDF (sin thead, para ser envuelto en print-master).
 */
function _renderFilasTablaMaestra(data) {
    return data.datos.map(sdg => {
        const sdgRow = `
            <tr class="rpt-ccrsdg-sdg-row rpt-font-bold">
                <td class="rpt-ccrsdg-col-dn rpt-fs-8pt rpt-ccrsdg-sdg-cell">${escapeHtml(sdg.nombreSubDirGeneral ?? sdg.codSubDirGeneral)}</td>
                <td class="rpt-ccrsdg-col-anterior ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((sdg.totalAñoAnterior ?? 0), 0)}</td>
                <td class="rpt-ccrsdg-col-actual ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((sdg.totalAño ?? 0), 0)}</td>
            </tr>
        `;
        const dnRows = sdg.detalleDN.map(dn => `
            <tr class="${RPT_CLASSES.DETAIL_ROW} rpt-ccrsdg-dn-row">
                <td class="rpt-ccrsdg-col-dn rpt-fs-8pt rpt-ccrsdg-dn-cell">${escapeHtml(dn.dn ?? '')}</td>
                <td class="rpt-ccrsdg-col-anterior ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((dn.totAñoAnterior ?? 0), 0)}</td>
                <td class="rpt-ccrsdg-col-actual ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((dn.totAño ?? 0), 0)}</td>
            </tr>
        `).join('');
        return sdgRow + dnRows;
    }).join('');
}

function _renderFilasPieInforme(data) {
    const totales = data?.totales;
    if (!totales) return '';

    return `
        <tr class="rpt-ccrsdg-grand-total-row rpt-font-bold">
            <td class="rpt-ccrsdg-col-dn rpt-fs-8pt rpt-align-center"></td>
            <td class="rpt-ccrsdg-col-anterior ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((totales.totalGeneralAñoAnterior ?? 0), 0)}</td>
            <td class="rpt-ccrsdg-col-actual ${RPT_CLASSES.NUMBER_CELL} rpt-fs-8pt">${formatCurrency((totales.totalGeneralAño ?? 0), 0)}</td>
        </tr>
    `;
}

/**
 * Genera la Tabla Maestra para el PDF con encabezado corporativo repetible en cada página.
 */
function _renderTablaMaestraPDF() {
    const data = estado.informeGlobalData;
    const filasHtml = _renderFilasTablaMaestra(data);
    const pieHtml = _renderFilasPieInforme(data);
    const anio = data.meta?.filtros?.anio || '';
    const anioAnterior = anio ? anio - 1 : '';

    return `
        ${_getHtmlEncabezado()}
        <div class="rpt-ccrsdg-subinforme-wrapper">
            <table class="${RPT_CLASSES.TABLE} rpt-ccrsdg-table rpt-table-print-master">
                <colgroup>
                    <col class="rpt-ccrsdg-col-dn">
                    <col class="rpt-ccrsdg-col-anterior">
                    <col class="rpt-ccrsdg-col-actual">
                </colgroup>
                <thead class="rpt-print-thead-corporate">
                    <tr>
                        <th class="rpt-print-thead-cell-empty"></th>
                        <th class="rpt-ccrsdg-header-acumulado rpt-text-corporate rpt-align-center rpt-fs-9pt" colspan="2">Acumulado</th>
                    </tr>
                    <tr class="rpt-ccrsdg-header-years-row">
                        <th class="rpt-ccrsdg-header-elecnor rpt-text-corporate rpt-fs-9pt">Elecnor</th>
                        <th class="rpt-text-corporate rpt-align-right rpt-fs-9pt">${anioAnterior}</th>
                        <th class="rpt-text-corporate rpt-align-right rpt-fs-9pt">${anio}</th>
                    </tr>
                </thead>
                <tfoot class="rpt-print-tfoot-master">
                    <tr><td colspan="3" class="rpt-print-tfoot-cell"></td></tr>
                </tfoot>
                <tbody>
                    ${filasHtml}
                    ${pieHtml}
                </tbody>
            </table>
        </div>
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

async function _imprimirInforme() {
    const contenidoHtml = _renderTablaMaestraPDF();
    const styleVars = getStyleVars(estado.margenes);

    const capaPrint = document.createElement('div');
    capaPrint.className = 'rpt-print-layer';
    capaPrint.innerHTML = `
        <div class="rpt-paper rpt-paper--print" data-informe="cartera_contratacion_resumen_sdg" ${styleVars}>
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
