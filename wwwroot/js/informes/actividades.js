/**
 * Informe: Actividades (Consejo Administración)
 * Módulo para renderizado dinámico del informe de actividades por país.
 */

import { RPT_CLASSES, formatCurrency, formatPercentage, actualizarEstadoPaginacion, inicializarEventListenersBase, getNombreMes, getVarClass } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado } from './informes_unificados_utils.js';

// ============================================================
// ESTADO DEL MÓDULO
// ============================================================
const estado = crearEstadoInforme();

/**
 * Punto de entrada llamado por el gestor de informes.
 */
export async function ejecutar(anio, mes, nroPagina) {
    try {
        const url = `/api/Actividades?anio=${anio}&mes=${mes}&_=${Date.now()}`;
        estado.nroPagina = nroPagina;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: '',
            claveAgrupacion: 'NONE' // Informe de página única con múltiples bloques
        });
    } catch (error) {
        console.error("Error al ejecutar informe Actividades:", error);
    }
}

/**
 * Renderizado de la vista de Actividades.
 */
function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="actividades" role="main">
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${_renderCuerpoInforme()}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(0, 1, '');
}

/**
 * Genera el encabezado corporativo unificado.
 */
function _getHtmlEncabezado() {
    return getHtmlEncabezadoBase({
        tituloCorporativo: '<span class="rpt-text-orange-council fs-3">Consejo de Administración</span> <span class="ms-3 fs-6 text-primary">Informe de Contratación</span>',
        textoBanner1: 'Elecnor',
        textoBanner2: 'Actividades',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina || 4 // Usar el nro de página del estado o 4 por defecto
    });
}

/**
 * Renderiza todos los bloques de países en el cuerpo del informe.
 */
function _renderCuerpoInforme() {
    const data = estado.informeGlobalData;
    if (!data || !data.paises) return '';

    return data.paises.map(pais => _renderBloquePais(pais)).join('');
}

/**
 * Renderiza un bloque de País (ej: Elecnor, Nacional, Internacional)
 */
function _renderBloquePais(pais) {
    const anioActual = estado.informeGlobalData.meta.filtros.anio;
    const anioAnterior = anioActual - 1;

    const tableHeader = `
        <thead>
            <tr class="rpt-th-year">
                <th colspan="2" class="text-center p-0">Cierre ${anioAnterior}</th>
                <th class="rpt-col-act-nombre"></th>
                <th colspan="3" class="text-center p-0">${anioActual}</th>
            </tr>
            <tr class="rpt-th-year">
                <th colspan="2" class="rpt-act-line-segment text-center p-0" style="height: 2px;"></th>
                <th class="rpt-col-act-nombre"></th>
                <th colspan="3" class="rpt-act-line-segment text-center p-0" style="height: 2px;"></th>
            </tr>
            <tr class="rpt-act-row-spacer">
                <th colspan="6"></th>
            </tr>
            <tr class="rpt-th-blue">
                <th class="rpt-col-act-porc-ant text-center rpt-act-line-segment">% s/Merc</th>
                <th class="rpt-col-act-imp-ant text-end pe-3 rpt-act-line-segment">Contr.</th>
                <th class="rpt-col-act-nombre text-start rpt-header-align-middle border-0 px-4">
                    <div class="rpt-act-badge text-uppercase">${pais.nombrePais}</div>
                </th>
                <th class="rpt-col-act-imp-act text-end pe-3 rpt-act-line-segment">Contr.</th>
                <th class="rpt-col-act-var text-center rpt-act-line-segment">% ${anioAnterior}</th>
                <th class="rpt-col-act-porc-act text-center rpt-act-line-segment">% s/Merc</th>
            </tr>
        </thead>
    `;

    const filasHtml = pais.detalle.map(d => `
        <tr class="rpt-detail-row">
            <td class="rpt-col-act-porc-ant text-center">${formatPercentage(d.porcentajeAnteriorMercado, 0)}</td>
            <td class="rpt-col-act-imp-ant text-end pe-3">${formatCurrency(d.importeAnterior / 1000, 0)}</td>
            <td class="rpt-col-act-nombre ps-3">${d.actividad}</td>
            <td class="rpt-col-act-imp-act text-end pe-3">${formatCurrency(d.importeActual / 1000, 0)}</td>
            <td class="rpt-col-act-var text-center ${getVarClass(d.variacionPorcentaje)}">${d.variacionPorcentaje}</td>
            <td class="rpt-col-act-porc-act text-center">${formatPercentage(d.porcentajeActualMercado, 0)}</td>
        </tr>
    `).join('');

    const totalesHtml = `
        <tr class="rpt-total-row">
            <td class="rpt-col-act-porc-ant text-center rpt-act-line-segment-top">100%</td>
            <td class="rpt-col-act-imp-ant text-end pe-3 rpt-act-line-segment-top">${formatCurrency(pais.totales.importeAnterior / 1000, 0)}</td>
            <td class="rpt-col-act-nombre p-0 border-0" style="padding-top: 0 !important; vertical-align: top;">
                <div class="rpt-act-line-segment-top mx-3" style="margin-top: -1px;"></div>
            </td>
            <td class="rpt-col-act-imp-act text-end pe-3 rpt-act-line-segment-top">${formatCurrency(pais.totales.importeActual / 1000, 0)}</td>
            <td class="rpt-col-act-var text-center rpt-act-line-segment-top"></td>
            <td class="rpt-col-act-porc-act text-center rpt-act-line-segment-top">100%</td>
        </tr>
    `;

    return `
        <div class="rpt-bloque-actividad">
            <table class="rpt-table rpt-table-actividades">
                ${tableHeader}
                <tbody>
                    ${filasHtml}
                    ${totalesHtml}
                </tbody>
            </table>
        </div>
    `;
}

/**
 * Registro de eventos locales.
 */
function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

/**
 * Exportación unificada a PDF.
 */
async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: _renderCuerpoInforme,
        modoAgrupacion: 'NONE'
    });
}
