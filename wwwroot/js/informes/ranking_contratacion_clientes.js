/**
 * Informe: Ranking de Contratación por Clientes
 */

import { RPT_CLASSES, formatCurrency, formatPercentage, escapeHtml, getNombreMes } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado } from './informes_unificados_utils.js';
import { ApiClient } from '../site.js';

const estado = crearEstadoInforme();

/**
 * Función principal de ejecución del informe.
 */
export async function ejecutar(anio, mes, nroPagina, mercado) {
    try {
        const url = `/api/ranking-contratacion-clientes?anio=${anio || 0}&mes=${mes || 0}&mercado=${mercado || 'Nacional'}&_=${Date.now()}`;
        estado.nroPagina = nroPagina;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            claveAgrupacion: 'NONE'
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
        <div class="${RPT_CLASSES.PAPER}" data-informe="ranking_clientes" role="main">
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
 */
function _getHtmlEncabezado() {
    const data = estado.informeGlobalData;
    const filtros = data?.meta?.filtros || {};
    
    return getHtmlEncabezadoBase({
        tituloCorporativo: '<span class="text-orange-council fs-3">Consejo de Administración</span> <span class="ms-3 fs-6 text-primary">Informe de Contratación</span>',
        textoBanner1: 'Ranking de Contratación',
        textoBanner2: 'Clientes',
        mes: filtros.mes,
        anio: filtros.anio,
        nroPagina: estado.nroPagina || 7
    });
}

/**
 * Renderiza el cuerpo del informe (Tabla de Ranking).
 */
function _renderCuerpoInforme() {
    const data = estado.informeGlobalData;
    if (!data || !data.datos || data.datos.length === 0) {
        return `<div class="text-center p-5 text-muted">No se han encontrado registros para el periodo seleccionado.</div>`;
    }

    const filtros = data?.meta?.filtros || {};
    const anioAnterior = (filtros.anio || 0) - 1;
    const esInternacional = filtros.mercado === 'Internacional';

    const filasHtml = data.datos.map(item => {
        // Fila principal del cliente
        let html = `
            <tr class="${RPT_CLASSES.DETAIL_ROW}">
                ${!esInternacional ? `<td class="rpt-col-ai text-center small">${item.ai || ''}</td>` : ''}
                <td class="rpt-col-row">${item.row}</td>
                <td class="rpt-col-cliente">${escapeHtml(item.cliente)}</td>
                <td class="rpt-col-num font-monospace">${formatCurrency((item.importe || 0) / 1000, 0)}</td>
                <td class="rpt-col-pct font-monospace text-primary">${formatPercentage(item.porcentajeSobreTotal, 1)}</td>
                ${!esInternacional ? `
                    <td class="rpt-col-ant font-monospace">
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
                        ${!esInternacional ? `<td class="rpt-col-ai text-center small opacity-50">${sub.ai || ''}</td>` : ''}
                        <td class="rpt-col-row"></td>
                        <td class="rpt-col-cliente ps-4 small">${escapeHtml(sub.clienteDesglose)}</td>
                        <td class="rpt-col-num font-monospace small">${formatCurrency(sub.importeContratadoAcumulado / 1000, 0)}</td>
                        <td class="rpt-col-pct font-monospace small">${formatPercentage(sub.porcentajeSobreTotal, 1)}</td>
                        ${!esInternacional ? `
                            <td class="rpt-col-ant font-monospace small">${sub.importeContratadoAnterior ? formatCurrency(sub.importeContratadoAnterior / 1000, 0) : ''}</td>
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
                <thead>
                    <tr class="rpt-header-grouping">
                        <th colspan="${esInternacional ? 2 : 3}"></th>
                        <th colspan="2" class="text-center rpt-header-label">Acumulado</th>
                        ${!esInternacional ? '<th></th>' : ''}
                    </tr>
                    <tr>
                        ${!esInternacional ? '<th class="rpt-col-ai"></th>' : ''}
                        <th class="rpt-col-row"></th>
                        <th class="rpt-header-blue">Cliente</th>
                        <th class="rpt-col-num"><div class="rpt-th-border-blue w-100">Contr</div></th>
                        <th class="rpt-col-pct text-center"><div class="rpt-th-border-blue w-90">s/${filtros.mercado || 'Nacional'}</div></th>
                        ${!esInternacional ? `<th class="rpt-col-ant"><div class="rpt-th-border-gray w-100">${anioAnterior || '----'} *</div></th>` : ''}
                    </tr>
                </thead>
                <tbody>
                    ${filasHtml}
                </tbody>
                <tfoot>
                    <tr class="rpt-ranking-total-row rpt-text-corporate fw-bold">
                        <td colspan="${esInternacional ? 2 : 3}"></td>
                        <td class="text-end font-monospace rpt-total-border-blue">${formatCurrency((data.sumaTop30 || 0) / 1000, 0)}</td>
                        <td class="text-end font-monospace rpt-total-border-blue">${data.porcentajeTop30 ? data.porcentajeTop30.toLocaleString('es-ES', { minimumFractionDigits: 1, maximumFractionDigits: 1 }) + '%' : '0%'}</td>
                        ${!esInternacional ? '<td class="rpt-col-ant"></td>' : ''}
                    </tr>
                    <tr class="rpt-ranking-grand-total-row">
                        <td colspan="${esInternacional ? 2 : 3}" class="pb-2 px-0" style="vertical-align: bottom;">
                            <div class="d-flex ${esInternacional ? 'justify-content-end' : 'justify-content-between'} align-items-baseline w-100">
                                ${!esInternacional ? '<span class="rpt-asterisk-legend ms-2">* Acumulado mismo mes año anterior</span>' : ''}
                                <span class="rpt-text-corporate fw-bold pe-3">Total ${filtros.mercado || 'Nacional'}</span>
                            </div>
                        </td>
                        <td class="text-end font-monospace rpt-text-corporate fw-bold pb-2" style="vertical-align: bottom;">${formatCurrency((data.totalMercado || 0) / 1000, 0)}</td>
                        <td colspan="${esInternacional ? 1 : 2}" class="ps-3 rpt-text-corporate fw-bold pb-2" style="vertical-align: bottom; white-space: nowrap !important;">Miles de Euros</td>
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
            modoAgrupacion: 'NONE'
        });
    } catch (error) {
        console.error("Error al intentar imprimir el informe Ranking Clientes:", error);
    }
}
