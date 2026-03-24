/**
 * Módulo para el informe de Países (Mercado Internacional).
 * Basado en el diseño simétrico de dos columnas comparativas.
 */
import { RPT_CLASSES, formatCurrency, formatPercentage, actualizarEstadoPaginacion, inicializarEventListenersBase } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado } from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

/**
 * Punto de entrada llamado por el gestor de informes.
 */
export async function ejecutar(anio, mes, nroPagina) {
    try {
        let url = `/api/Paises?anio=${anio}&mes=${mes}`;
        if (nroPagina) url += `&nroPagina=${nroPagina}`;
        url += `&_=${Date.now()}`;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: '',
            claveAgrupacion: 'NONE' // Informe de página única
        });
    } catch (error) {
        console.error("Error al ejecutar informe Paises:", error);
    }
}

/**
 * Renderizado de la vista de Países.
 */
function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="paises" role="main">
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${_renderTablaPaises()}
                ${_renderFooterInfo()}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(0, 1, '');
}

function _getHtmlEncabezado() {
    return getHtmlEncabezadoBase({
        tituloCorporativo: '<span class="rpt-text-orange-council fs-3">Consejo de Administración</span> <span class="ms-3 fs-6">Informe de Contratación</span>',
        textoBanner1: 'Elecnor',
        textoBanner2: 'Mercado internacional por países',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.informeGlobalData?.meta?.filtros?.nroPagina
    });
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: () => _renderTablaPaises() + _renderFooterInfo(),
        modoAgrupacion: 'NONE'
    });
}

/**
 * Renderiza la tabla principal con el layout simétrico.
 */
function _renderTablaPaises() {
    const data = estado.informeGlobalData;
    if (!data || !data.paises) return '<p class="text-center">No hay datos disponibles para este periodo.</p>';

    const anioActual = data.meta.filtros.anio;
    const anioAnterior = anioActual - 1;

    let html = `
        <table class="rpt-table rpt-paises-table w-100">
            <colgroup>
                <col class="rpt-paises-col-porc">
                <col class="rpt-paises-col-contr">
                <col class="rpt-paises-col-pos">
                <col class="rpt-paises-col-pais">
                <col class="rpt-paises-col-pos">
                <col class="rpt-paises-col-contr">
                <col class="rpt-paises-col-porc">
            </colgroup>
            <thead>
                <tr class="rpt-paises-header-year">
                    <th colspan="3">Cierre ${anioAnterior}</th>
                    <th></th>
                    <th colspan="3">${anioActual}</th>
                </tr>
                <tr class="rpt-th-blue">
                    <th class="text-center">% S/Internac</th>
                    <th class="text-end pe-3">Contr.</th>
                    <th class="text-center">Pos.</th>
                    <th class="rpt-paises-pais-cell">País</th>
                    <th class="text-center">Pos.</th>
                    <th class="text-end pe-3">Contr.</th>
                    <th class="text-center">% S/Internac</th>
                </tr>
            </thead>
            <tbody>
    `;

    data.paises.forEach(p => {
        html += `
            <tr class="rpt-detail-row">
                <td class="text-center">${p.porcentajeSobreInternacionalAnterior || 0}%</td>
                <td class="rpt-paises-num-cell">${formatCurrency(p.importeAnterior, 0)}</td>
                <td class="rpt-paises-pos-cell">${p.posicionAnterior || ''}</td>
                
                <td class="rpt-paises-pais-cell">
                    <div class="d-flex align-items-center justify-content-start ps-2">
                        <span style="width: 25px; display: inline-block; flex-shrink: 0;">
                            ${p.esNuevo ? '<span class="rpt-paises-new-flag">*</span>' : ''}
                        </span>
                        <span>${p.pais}</span>
                    </div>
                </td>
                
                <td class="rpt-paises-pos-cell">${p.posicionActual || ''}</td>
                <td class="rpt-paises-num-cell">${formatCurrency(p.importeActual / 1000, 0)}</td>
                <td class="text-center">${p.porcentajeSobreInternacionalActual || 0}%</td>
            </tr>
        `;
    });

    // Fila de Totales (Suma de los mostrados)
    html += `
            </tbody>
            <tfoot class="rpt-paises-total-row">
                <tr>
                    <td class="text-center rpt-paises-total-line">${data.totales.porcentajeTotalAnterior}%</td>
                    <td class="rpt-paises-num-cell rpt-paises-total-line">${formatCurrency(data.totales.totalInternacionalAnterior, 0)}</td>
                    <td></td>
                    <td class="rpt-paises-total-line">Total Internacional</td>
                    <td></td>
                    <td class="rpt-paises-num-cell rpt-paises-total-line">${formatCurrency(data.totales.totalInternacionalActual / 1000, 0)}</td>
                    <td class="text-center rpt-paises-total-line">${data.totales.porcentajeTotalActual}%</td>
                </tr>
            </tfoot>
        </table>
    `;

    return html;
}

/**
 * Renderiza los bloques informativos de pie de página.
 */
function _renderFooterInfo() {
    const data = estado.informeGlobalData;
    if (!data) return '';

    return `
        <div class="rpt-paises-footer-block">
            <div class="mb-2">(*) País nuevo con contratación</div>
        </div>
    `;
}
