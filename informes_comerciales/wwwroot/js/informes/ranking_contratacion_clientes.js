/**
 * Informe: Ranking de Contratación por Clientes
 * GUÍA: Print-Perfect Parity v4.2
 */

import { RPT_CLASSES, formatCurrency, formatPercentage, escapeHtml, getNombreMes } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars } from './informes_unificados_utils.js';
import { ApiClient } from '../site.js';

const estado = crearEstadoInforme();

/**
 * Función principal de ejecución del informe.
 * @param {number} anio - Año del informe
 * @param {number} mes - Mes del informe
 * @param {number|null} nroPagina - Número de página opcional
 * @param {string} mercado - Mercado ('Nacional' o 'Internacional')
 * @param {number|null} umbral - Umbral de filtrado (no usado en este informe, por compatibilidad)
 * @param {boolean} mostrarTitulo - Flag de visibilidad del título
 */
export async function ejecutar({ anio, mes, nroPagina, mercado, mostrarTitulo }) {
    try {
        const url = `/api/ranking-contratacion-clientes?anio=${anio || 0}&mes=${mes || 0}&mercado=${mercado || 'Nacional'}&_=${Date.now()}`;
        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            claveAgrupacion: 'NONE',
            margenes: { web: '16mm', pdf: '16mm', maxWidth: '1050px' }
        });

    } catch (error) {
        console.error("Error al ejecutar informe Ranking de Clientes:", error);
        GlobalUI.showAlert?.("Error al cargar los datos del informe", "danger");
    }
}

/**
 * Renderiza la página del informe.
 */
async function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const cuerpoHtml = _renderCuerpoInforme();

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="ranking_clientes" role="main"${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${cuerpoHtml}
            </div>
        </div>
    `;

    container.scrollTop = 0;
}

/**
 * Genera el encabezado HTML.
 * V-14: Patrón Título Corporativo CMAI
 */
function _getHtmlEncabezado() {
    const data = estado.informeGlobalData;
    const filtros = data?.meta?.filtros || {};

    return getHtmlEncabezadoBase({
        tituloCorporativo: '<span class="rpt-text-orange-council rpt-fs-14pt">Consejo Elecnor</span><span class="rpt-ms-2 rpt-fs-9pt rpt-text-corporate">Informe de Contratación</span>',
        textoBanner1: 'Ranking de Contratación',
        textoBanner2: 'Clientes',
        mes: filtros.mes,
        anio: filtros.anio,
        nroPagina: estado.nroPagina || 7,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

/**
 * Renderiza el cuerpo del informe (Tabla de Ranking).
 */
function _renderCuerpoInforme() {
    const data = estado.informeGlobalData;
    if (!data || !data.datos || data.datos.length === 0) {
        return '<div class="rpt-no-data">No se han encontrado registros para el periodo seleccionado.</div>';
    }

    const filtros = data?.meta?.filtros || {};
    const anioAnterior = (filtros.anio || 0) - 1;
    const esInternacional = filtros.mercado === 'Internacional';

    // Definir colgroup basado en el mercado
    const colgroupHtml = esInternacional 
        ? '<col class="rpt-col-row"><col class="rpt-col-cliente"><col class="rpt-col-num"><col class="rpt-col-pct">'
        : '<col class="rpt-col-ai"><col class="rpt-col-row"><col class="rpt-col-cliente"><col class="rpt-col-num"><col class="rpt-col-pct"><col class="rpt-col-ant">';

    const filasHtml = data.datos.map(item => {
        // Fila principal del cliente
        let html = `
            <tr class="${RPT_CLASSES.DETAIL_ROW}">
                ${!esInternacional ? `<td class="rpt-col-ai">${item.ai || ''}</td>` : ''}
                <td class="rpt-col-row">${item.row}</td>
                <td class="rpt-col-cliente">${escapeHtml(item.cliente)}</td>
                <td class="rpt-col-num rpt-font-monospace">${formatCurrency((item.importe || 0) / 1000, 0)}</td>
                <td class="rpt-col-pct rpt-font-monospace">${formatPercentage(item.porcentajeSobreTotal, 1)}</td>
                ${!esInternacional ? `
                    <td class="rpt-col-ant rpt-font-monospace">
                        ${item.importeAnterior ? formatCurrency(item.importeAnterior / 1000, 0) : ''}
                    </td>
                ` : ''}
            </tr>
        `;

        // Filas de desglose (si existen)
        if (item.desglose && item.desglose.length > 0) {
            item.desglose.forEach(sub => {
                html += `
                    <tr class="rpt-desglose-row">
                        ${!esInternacional ? `<td class="rpt-col-ai rpt-desglose-ai">${sub.ai || ''}</td>` : ''}
                        <td class="rpt-col-row"></td>
                        <td class="rpt-col-cliente rpt-ps-4">${escapeHtml(sub.clienteDesglose)}</td>
                        <td class="rpt-col-num rpt-font-monospace">${formatCurrency(sub.importeContratadoAcumulado / 1000, 0)}</td>
                        <td class="rpt-col-pct rpt-font-monospace">${formatPercentage(sub.porcentajeSobreTotal, 1)}</td>
                        ${!esInternacional ? `
                            <td class="rpt-col-ant rpt-font-monospace">${sub.importeContratadoAnterior ? formatCurrency(sub.importeContratadoAnterior / 1000, 0) : ''}</td>
                        ` : ''}
                    </tr>
                `;
            });
        }

        return html;
    }).join('');

    return `
        <div class="rpt-content-block">
            <div class="rpt-ranking-subtitle">Mercado ${filtros.mercado || 'Nacional'} - 30 primeros</div>

            <table class="rpt-ranking-table">
                <colgroup>
                    ${colgroupHtml}
                </colgroup>
                <thead>
                    <tr class="rpt-header-grouping">
                        ${!esInternacional ? '<th class="rpt-col-ai"></th>' : ''}
                        <th class="rpt-col-row"></th>
                        <th class="rpt-header-acumulado" colspan="${esInternacional ? 2 : 3}">Acumulado</th>
                        ${!esInternacional ? '<th class="rpt-col-ant"></th>' : ''}
                    </tr>
                    <tr>
                        ${!esInternacional ? '<th class="rpt-col-ai"></th>' : ''}
                        <th class="rpt-col-row"></th>
                        <th class="rpt-header-blue rpt-col-cliente">Cliente</th>
                        <th class="rpt-col-num">
                            <div class="rpt-th-border-blue rpt-w-100">Contr</div>
                        </th>
                        <th class="rpt-col-pct rpt-text-center">
                            <div class="rpt-th-border-blue rpt-w-100">% s/${filtros.mercado || 'Nacional'}</div>
                        </th>
                        ${!esInternacional ? `<th class="rpt-col-ant">
                            <div class="rpt-th-border-gray rpt-w-100">${anioAnterior || '----'} *</div>
                        </th>` : ''}
                    </tr>
                </thead>
                <tbody>
                    ${filasHtml}
                </tbody>
                <tfoot>
                    <tr class="rpt-ranking-total-row">
                        <td colspan="${esInternacional ? 2 : 3}"></td>
                        <td class="rpt-col-num rpt-text-corporate rpt-font-bold">
                            <div class="rpt-td-border-blue rpt-w-100 rpt-text-end rpt-font-monospace">${formatCurrency((data.sumaTop30 || 0) / 1000, 0)}</div>
                        </td>
                        <td class="rpt-col-pct rpt-text-corporate rpt-font-bold">
                            <div class="rpt-td-border-blue rpt-w-100 rpt-text-end rpt-font-monospace">${data.porcentajeTop30 ? data.porcentajeTop30.toLocaleString('es-ES', { minimumFractionDigits: 1, maximumFractionDigits: 1 }) + '%' : '0%'}</div>
                        </td>
                        ${!esInternacional ? '<td class="rpt-col-ant"></td>' : ''}
                    </tr>
                    <tr class="rpt-ranking-grand-total-row">
                        <td colspan="${esInternacional ? 2 : 3}" class="rpt-pb-2 rpt-px-0 rpt-va-bottom">
                            <div class="rpt-d-flex ${esInternacional ? 'rpt-justify-end' : 'rpt-justify-between'} rpt-align-baseline rpt-w-100">
                                ${!esInternacional ? '<span class="rpt-asterisk-legend">* Acumulado mismo mes año anterior</span>' : ''}
                                <span class="rpt-text-corporate rpt-font-bold rpt-pe-3">Total ${filtros.mercado || 'Nacional'}</span>
                            </div>
                        </td>
                        <td class="rpt-text-end rpt-text-corporate rpt-font-bold rpt-pb-2 rpt-va-bottom rpt-font-monospace">${formatCurrency((data.totalMercado || 0) / 1000, 0)}</td>
                        <td colspan="${esInternacional ? 1 : 2}" class="rpt-ps-3 rpt-text-corporate rpt-font-bold rpt-pb-2 rpt-va-bottom rpt-nowrap">Miles de Euros</td>
                    </tr>
                </tfoot>
            </table>
        </div>
    `;
}

/**
 * Registra eventos.
 */
function _registrarEventos() {
    const btnPdf = document.getElementById(RPT_CLASSES.BTN_EXPORTAR_PDF);
    if (btnPdf) {
        btnPdf.onclick = _imprimirInforme;
    }
}

/**
 * Lógica de impresión.
 */
async function _imprimirInforme() {
    try {
        const contenidoHtml = _renderCuerpoInforme();
        await imprimirInformeUnificado({
            informeGlobalData: estado.informeGlobalData,
            getHtmlEncabezado: _getHtmlEncabezado,
            renderContenido: () => contenidoHtml,
            modoAgrupacion: 'NONE',
            margenes: estado.margenes
        });
    } catch (error) {
        console.error("Error al intentar imprimir el informe Ranking Clientes:", error);
    }
}
