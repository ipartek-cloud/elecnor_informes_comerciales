/**
 * Informe: Actividades (Consejo Administración)
 * Módulo para renderizado dinámico del informe de actividades por país.
 */

import { RPT_CLASSES, formatCurrency, formatPercentage, actualizarEstadoPaginacion, inicializarEventListenersBase, getNombreMes, getVarClass } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars, MARGENES_ESTANDAR } from './informes_unificados_utils.js';

// ============================================================
// ESTADO DEL MÓDULO
// ============================================================
const estado = crearEstadoInforme();

/**
 * Punto de entrada llamado por el gestor de informes.
 */
export async function ejecutar({ anio, mes, nroPagina, mostrarTitulo }) {
    try {
        const url = `/api/Actividades?anio=${anio}&mes=${mes}&_=${Date.now()}`;
        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: '',
            claveAgrupacion: 'NONE', // Informe de página única con múltiples bloques
            margenes: MARGENES_ESTANDAR
        });
    } catch (error) {
        console.error("Error al ejecutar informe Actividades:", error);
        throw error;
    }
}

/**
 * Renderizado de la vista de Actividades.
 */
function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="actividades" role="main" ${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body rpt-cmai-mt-standard">
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
        tituloCorporativo: '<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container">Consejo de Administración</span><span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>',
        textoBanner1: 'Elecnor',
        textoBanner2: 'Actividades',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina || 4,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
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
      <th colspan="2" class="rpt-align-center rpt-p-0">Cierre ${anioAnterior}</th>
      <th class="rpt-col-act-nombre"></th>
      <th colspan="3" class="rpt-align-center rpt-p-0">${anioActual}</th>
    </tr>
    <tr class="rpt-th-year">
      <th colspan="2" class="rpt-act-line-segment rpt-align-center rpt-p-0"></th>
      <th class="rpt-col-act-nombre"></th>
      <th colspan="3" class="rpt-act-line-segment rpt-align-center rpt-p-0"></th>
    </tr>
    <tr class="rpt-act-row-spacer">
      <th colspan="6"></th>
    </tr>
    <tr class="rpt-th-blue">
      <th class="rpt-col-act-porc-ant rpt-align-center">
        <div class="rpt-act-header-line">% s/Merc</div>
      </th>
      <th class="rpt-col-act-imp-ant rpt-align-end rpt-pad-right-15">
        <div class="rpt-act-header-line">Contr.</div>
      </th>
      <th class="rpt-col-act-nombre rpt-align-start rpt-header-align-middle rpt-p-0">
        <div class="rpt-act-badge rpt-text-uppercase">${pais.nombrePais}</div>
      </th>
      <th class="rpt-col-act-imp-act rpt-align-end rpt-pad-right-15">
        <div class="rpt-act-header-line">Contr.</div>
      </th>
      <th class="rpt-col-act-var rpt-align-center">
        <div class="rpt-act-header-line">% ${anioAnterior}</div>
      </th>
      <th class="rpt-col-act-porc-act rpt-align-center">
        <div class="rpt-act-header-line">% s/Merc</div>
      </th>
    </tr>
  </thead>
  `;

    const filasHtml = pais.detalle.map(d => `
    <tr class="rpt-detail-row">
      <td class="rpt-col-act-porc-ant rpt-align-center">${formatPercentage(d.porcentajeAnteriorMercado, 0)}</td>
      <td class="rpt-col-act-imp-ant rpt-align-end rpt-pad-right-15">${formatCurrency(d.importeAnterior / 1000, 0)}</td>
      <td class="rpt-col-act-nombre rpt-ps-3">${d.actividad}</td>
      <td class="rpt-col-act-imp-act rpt-align-end rpt-pad-right-15">${formatCurrency(d.importeActual / 1000, 0)}</td>
      <td class="rpt-col-act-var rpt-align-center ${getVarClass(d.variacionPorcentaje)}">${d.variacionPorcentaje}</td>
      <td class="rpt-col-act-porc-act rpt-align-center">${formatPercentage(d.porcentajeActualMercado, 0)}</td>
    </tr>
  `).join('');

    const totalesHtml = `
    <tr class="rpt-spacer-row-totales">
      <td colspan="6" class="rpt-spacer-cell-totales"></td>
    </tr>
    <tr class="rpt-total-row">
      <td class="rpt-col-act-porc-ant rpt-align-center">
        <div class="rpt-act-total-line">100%</div>
      </td>
      <td class="rpt-col-act-imp-ant rpt-align-end rpt-pad-right-15">
        <div class="rpt-act-total-line">${formatCurrency(pais.totales.importeAnterior / 1000, 0)}</div>
      </td>
      <td class="rpt-col-act-nombre">
        <div class="rpt-act-total-line rpt-act-total-line-text">&nbsp;</div>
      </td>
      <td class="rpt-col-act-imp-act rpt-align-end rpt-pad-right-15">
        <div class="rpt-act-total-line">${formatCurrency(pais.totales.importeActual / 1000, 0)}</div>
      </td>
      <td class="rpt-col-act-var rpt-align-center">
        <div class="rpt-act-total-line"></div>
      </td>
      <td class="rpt-col-act-porc-act rpt-align-center">
        <div class="rpt-act-total-line">100%</div>
      </td>
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
        modoAgrupacion: 'NONE',
        margenes: estado.margenes,
        nombreInforme: 'actividades'
    });
}
