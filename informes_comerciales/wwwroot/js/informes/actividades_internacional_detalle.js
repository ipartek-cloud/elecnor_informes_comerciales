/**
 * Módulo para el informe Detalle Actividades Internacional.
 * Patrón: Sábana continua (claveAgrupacion: 'NONE').
 */
import {
    RPT_CLASSES, formatCurrency, escapeHtml, getNombreMes, inicializarEventListenersBase
} from './utils.js';
import {
    crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase,
    getStyleVars, imprimirInformeUnificado, MARGENES_ESTANDAR
} from './informes_unificados_utils.js';
import { ApiClient, GlobalUI } from '../site.js';

const estado = crearEstadoInforme();

export async function ejecutar({ anio, mes, nroPagina, mostrarTitulo = false }) {
    try {
        const url = `/api/ActividadesInternacionalDetalle?anio=${anio}&mes=${mes}&_=${Date.now()}`;

        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: '',
            claveAgrupacion: 'NONE',
            margenes: MARGENES_ESTANDAR
        });
    } catch (error) {
        console.error('[ActividadesInternacionalDetalle] Error:', error);
        GlobalUI.showAlert('Error al cargar el informe', 'danger');
        throw error;
    }
}

function _formatSubActividad(valor, decimales = 0, esPorcentaje = false) {
    if (valor === 0 || valor === null || valor === undefined) return '';
    const formatted = formatCurrency(valor, decimales);
    return esPorcentaje ? `${formatted}%` : formatted;
}

function _formatActividad(valor, decimales = 0, esPorcentaje = false) {
    if (valor === 0 || valor === null || valor === undefined) return '';
    const formatted = formatCurrency(valor, decimales);
    return esPorcentaje ? `${formatted}%` : formatted;
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const data = estado.informeGlobalData;
    const filtros = data?.meta?.filtros || {};

    if (!data.actividades || data.actividades.length === 0) {
        _mostrarSinDatos(data, filtros.anio);
        return;
    }

    let rowsHtml = '';
    
    data.actividades.forEach(act => {
        rowsHtml += `
            <tr class="rpt-detail-row rpt-act-principal">
                <td class="rpt-col-pct-ant rpt-number-cell">${_formatActividad(act.porcentajeSobreMercadoAnterior, 0, true)}</td>
                <td class="rpt-col-contr-ant rpt-number-cell">${_formatActividad(act.importeContratadoAcumuladoAñoAnterior / 1000, 0)}</td>
                <td class="rpt-col-actividad">${escapeHtml(act.nombre)}</td>
                <td class="rpt-col-objetivo rpt-number-cell">${_formatActividad(act.importeObjetivos, 0)}</td>
                <td class="rpt-col-contr-actual rpt-number-cell">${_formatActividad(act.importeContratadoAcumulado / 1000, 0)}</td>
                <td class="rpt-col-ip rpt-align-center">${_formatActividad(act.indiceProduccion, 2)}</td>
                <td class="rpt-col-pct-actual rpt-number-cell">${_formatActividad(act.porcentajeSobreMercado, 0, true)}</td>
            </tr>`;

        if (act.subActividades && act.subActividades.length > 0) {
            act.subActividades.forEach(sub => {
                rowsHtml += `
                    <tr class="rpt-detail-row rpt-act-sub">
                        <td class="rpt-col-pct-ant rpt-number-cell">${_formatSubActividad(sub.porcentajeSobreMercadoAnterior, 0, true)}</td>
                        <td class="rpt-col-contr-ant rpt-number-cell">${_formatSubActividad(sub.importeContratadoAcumuladoAñoAnterior / 1000, 0)}</td>
                        <td class="rpt-col-actividad rpt-sub-indent">${escapeHtml(sub.nombre)}</td>
                        <td class="rpt-col-objetivo rpt-number-cell">${_formatSubActividad(0, 0)}</td>
                        <td class="rpt-col-contr-actual rpt-number-cell">${_formatSubActividad(sub.importeContratadoAcumulado / 1000, 0)}</td>
                        <td class="rpt-col-ip rpt-align-center">${_formatSubActividad(0, 2)}</td>
                        <td class="rpt-col-pct-actual rpt-number-cell">${_formatSubActividad(sub.porcentajeSobreMercado, 0, true)}</td>
                    </tr>`;
            });
        }
    });

    const tot = data.totales;
    rowsHtml += `
        <tr class="rpt-spacer-row-totales"><td colspan="7" class="rpt-spacer-cell-totales"></td></tr>
        <tr class="rpt-detail-row rpt-total-row">
            <td class="rpt-col-pct-ant rpt-number-cell"><div class="rpt-total-line">${_formatActividad(tot.porcentajeSobreMercadoAnterior, 0, true)}</div></td>
            <td class="rpt-col-contr-ant rpt-number-cell"><div class="rpt-total-line">${_formatActividad(tot.importeContratadoAcumuladoAñoAnterior / 1000, 0)}</div></td>
            <td class="rpt-col-actividad"></td>
            <td class="rpt-col-objetivo rpt-number-cell"><div class="rpt-total-line">${_formatActividad(tot.importeObjetivos, 0)}</div></td>
            <td class="rpt-col-contr-actual rpt-number-cell"><div class="rpt-total-line">${_formatActividad(tot.importeContratadoAcumulado / 1000, 0)}</div></td>
            <td class="rpt-col-ip rpt-align-center"><div class="rpt-total-line">${_formatActividad(tot.indiceProduccion, 2)}</div></td>
            <td class="rpt-col-pct-actual rpt-number-cell"><div class="rpt-total-line">${_formatActividad(tot.porcentajeSobreMercado, 0, true)}</div></td>
        </tr>`;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="actividades_internacional_detalle" role="main" ${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado(filtros)}
            <div class="report-body rpt-cmai-mt-standard">
                <table class="rpt-table rpt-table-act-int-det">
                    <colgroup>
                        <col class="rpt-col-pct-ant">
                        <col class="rpt-col-contr-ant">
                        <col class="rpt-col-actividad">
                        <col class="rpt-col-objetivo">
                        <col class="rpt-col-contr-actual">
                        <col class="rpt-col-ip">
                        <col class="rpt-col-pct-actual">
                    </colgroup>
                    <thead>
                        <tr class="rpt-th-year">
                            <th colspan="2" class="rpt-align-center rpt-text-corporate rpt-fs-8pt">Cierre ${filtros.anio - 1}</th>
                            <th></th>
                            <th colspan="4" class="rpt-align-center rpt-text-corporate rpt-fs-8pt">${filtros.anio}</th>
                        </tr>
                        <tr class="rpt-th-year">
                            <th colspan="2" class="rpt-act-line-segment"></th>
                            <th></th>
                            <th colspan="4" class="rpt-act-line-segment"></th>
                        </tr>
                        <tr class="rpt-act-row-spacer"><th colspan="7"></th></tr>
                        <tr class="rpt-th-blue">
                            <th class="rpt-text-corporate rpt-align-center rpt-fs-8pt">
                                <div class="rpt-act-header-line">% s/Merc</div>
                            </th>
                            <th class="rpt-text-corporate rpt-align-end rpt-fs-8pt">
                                <div class="rpt-act-header-line">Contr.</div>
                            </th>
                            <th class="rpt-text-corporate rpt-align-start rpt-fs-8pt rpt-col-internacional-header">
                                <div class="rpt-act-header-line">Internacional</div>
                            </th>
                            <th class="rpt-text-corporate rpt-align-end rpt-fs-8pt">
                                <div class="rpt-act-header-line">Objetivo</div>
                            </th>
                            <th class="rpt-text-corporate rpt-align-end rpt-fs-8pt">
                                <div class="rpt-act-header-line">Contr.</div>
                            </th>
                            <th class="rpt-text-corporate rpt-align-center rpt-fs-8pt">
                                <div class="rpt-act-header-line">IP</div>
                            </th>
                            <th class="rpt-text-corporate rpt-align-center rpt-fs-8pt">
                                <div class="rpt-act-header-line">% s/Merc</div>
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        ${rowsHtml}
                    </tbody>
                </table>
            </div>
        </div>`;

    container.scrollTop = 0;
}

function _getHtmlEncabezado(filtros) {
    return getHtmlEncabezadoBase({
        tituloCorporativo: `
            <span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container rpt-d-none">Consejo Elecnor</span>
            <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>`,
        textoBanner1: 'Elecnor',
        textoBanner2: 'Actividades',
        mes: filtros.mes,
        anio: filtros.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: () => _getHtmlEncabezado(estado.informeGlobalData?.meta?.filtros || {}),
        renderContenido: () => _renderTablaParaPdf(),
        modoAgrupacion: 'NONE',
        margenes: estado.margenes,
        nombreInforme: 'actividades_internacional_detalle'
    });
}

function _renderTablaParaPdf() {
    const data = estado.informeGlobalData;
    const filtros = data?.meta?.filtros || {};
    let rowsHtml = '';
    
    data.actividades.forEach(act => {
        rowsHtml += `
            <tr class="rpt-detail-row rpt-act-principal">
                <td class="rpt-col-pct-ant rpt-number-cell">${_formatActividad(act.porcentajeSobreMercadoAnterior, 0, true)}</td>
                <td class="rpt-col-contr-ant rpt-number-cell">${_formatActividad(act.importeContratadoAcumuladoAñoAnterior / 1000, 0)}</td>
                <td class="rpt-col-actividad">${escapeHtml(act.nombre)}</td>
                <td class="rpt-col-objetivo rpt-number-cell">${_formatActividad(act.importeObjetivos, 0)}</td>
                <td class="rpt-col-contr-actual rpt-number-cell">${_formatActividad(act.importeContratadoAcumulado / 1000, 0)}</td>
                <td class="rpt-col-ip rpt-align-center">${_formatActividad(act.indiceProduccion, 2)}</td>
                <td class="rpt-col-pct-actual rpt-number-cell">${_formatActividad(act.porcentajeSobreMercado, 0, true)}</td>
            </tr>`;

        if (act.subActividades && act.subActividades.length > 0) {
            act.subActividades.forEach(sub => {
                rowsHtml += `
                    <tr class="rpt-detail-row rpt-act-sub">
                        <td class="rpt-col-pct-ant rpt-number-cell">${_formatSubActividad(sub.porcentajeSobreMercadoAnterior, 0, true)}</td>
                        <td class="rpt-col-contr-ant rpt-number-cell">${_formatSubActividad(sub.importeContratadoAcumuladoAñoAnterior / 1000, 0)}</td>
                        <td class="rpt-col-actividad rpt-sub-indent">${escapeHtml(sub.nombre)}</td>
                        <td class="rpt-col-objetivo rpt-number-cell">${_formatSubActividad(0, 0)}</td>
                        <td class="rpt-col-contr-actual rpt-number-cell">${_formatSubActividad(sub.importeContratadoAcumulado / 1000, 0)}</td>
                        <td class="rpt-col-ip rpt-align-center">${_formatSubActividad(0, 2)}</td>
                        <td class="rpt-col-pct-actual rpt-number-cell">${_formatSubActividad(sub.porcentajeSobreMercado, 0, true)}</td>
                    </tr>`;
            });
        }
    });

    const tot = data.totales;
    rowsHtml += `
        <tr class="rpt-spacer-row-totales"><td colspan="7" class="rpt-spacer-cell-totales"></td></tr>
        <tr class="rpt-detail-row rpt-total-row">
            <td class="rpt-col-pct-ant rpt-number-cell"><div class="rpt-total-line">${_formatActividad(tot.porcentajeSobreMercadoAnterior, 0, true)}</div></td>
            <td class="rpt-col-contr-ant rpt-number-cell"><div class="rpt-total-line">${_formatActividad(tot.importeContratadoAcumuladoAñoAnterior / 1000, 0)}</div></td>
            <td class="rpt-col-actividad"></td>
            <td class="rpt-col-objetivo rpt-number-cell"><div class="rpt-total-line">${_formatActividad(tot.importeObjetivos, 0)}</div></td>
            <td class="rpt-col-contr-actual rpt-number-cell"><div class="rpt-total-line">${_formatActividad(tot.importeContratadoAcumulado / 1000, 0)}</div></td>
            <td class="rpt-col-ip rpt-align-center"><div class="rpt-total-line">${_formatActividad(tot.indiceProduccion, 2)}</div></td>
            <td class="rpt-col-pct-actual rpt-number-cell"><div class="rpt-total-line">${_formatActividad(tot.porcentajeSobreMercado, 0, true)}</div></td>
        </tr>`;

    return `
        <table class="rpt-table rpt-table-act-int-det">
            <colgroup>
                <col class="rpt-col-pct-ant">
                <col class="rpt-col-contr-ant">
                <col class="rpt-col-actividad">
                <col class="rpt-col-objetivo">
                <col class="rpt-col-contr-actual">
                <col class="rpt-col-ip">
                <col class="rpt-col-pct-actual">
            </colgroup>
            <thead>
                <tr class="rpt-th-year">
                    <th colspan="2" class="rpt-align-center rpt-text-corporate rpt-fs-8pt">Cierre ${filtros.anio - 1}</th>
                    <th></th>
                    <th colspan="4" class="rpt-align-center rpt-text-corporate rpt-fs-8pt">${filtros.anio}</th>
                </tr>
                <tr class="rpt-th-year">
                    <th colspan="2" class="rpt-act-line-segment"></th>
                    <th></th>
                    <th colspan="4" class="rpt-act-line-segment"></th>
                </tr>
                <tr class="rpt-act-row-spacer"><th colspan="7"></th></tr>
                <tr class="rpt-th-blue">
                    <th class="rpt-text-corporate rpt-align-center rpt-fs-8pt"><div class="rpt-act-header-line">% s/Merc</div></th>
                    <th class="rpt-text-corporate rpt-align-end rpt-fs-8pt"><div class="rpt-act-header-line">Contr.</div></th>
                    <th class="rpt-text-corporate rpt-align-start rpt-fs-8pt rpt-col-internacional-header"><div class="rpt-act-header-line">Internacional</div></th>
                    <th class="rpt-text-corporate rpt-align-end rpt-fs-8pt"><div class="rpt-act-header-line">Objetivo</div></th>
                    <th class="rpt-text-corporate rpt-align-end rpt-fs-8pt"><div class="rpt-act-header-line">Contr.</div></th>
                    <th class="rpt-text-corporate rpt-align-center rpt-fs-8pt"><div class="rpt-act-header-line">IP</div></th>
                    <th class="rpt-text-corporate rpt-align-center rpt-fs-8pt"><div class="rpt-act-header-line">% s/Merc</div></th>
                </tr>
            </thead>
            <tfoot class="rpt-print-tfoot-master">
                <tr><td colspan="7" class="rpt-print-tfoot-cell"></td></tr>
            </tfoot>
            <tbody>${rowsHtml}</tbody>
        </table>`;
}

function _mostrarSinDatos(data, anio) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;
    container.innerHTML = `
        <div class="rpt-info-alert">
            <div class="rpt-info-alert-icon"><i class="fas fa-info-circle"></i></div>
            <h5 class="rpt-info-alert-title">No hay datos disponibles</h5>
            <p class="rpt-info-alert-text">
                No se encontraron registros para el año ${anio}.
            </p>
        </div>`;
}
