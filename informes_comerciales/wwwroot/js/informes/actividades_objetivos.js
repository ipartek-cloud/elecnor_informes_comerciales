/**
 * Informe: Actividades_Objetivos (Consejo Administración)
 * Módulo para renderizado dinámico del informe de actividades con objetivos e IP.
 */

import { RPT_CLASSES, formatCurrency, formatPercentage, actualizarEstadoPaginacion, inicializarEventListenersBase, getNombreMes, getVarClass } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars, MARGENES_ESTANDAR } from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

/**
 * Punto de entrada llamado por el gestor de informes.
 */
export async function ejecutar({ anio, mes, nroPagina, mostrarTitulo }) {
  try {
    let url = `/api/ActividadesObjetivos?anio=${anio}&mes=${mes}`;
    if (nroPagina) url += `&nroPagina=${nroPagina}`;
    url += `&_=${Date.now()}`;

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
    console.error("Error al ejecutar informe Actividades_Objetivos:", error);
    throw error;
  }
}

function _renderizarPagina() {
  const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
  if (!container) return;

  container.innerHTML = `
  <div class="${RPT_CLASSES.PAPER} rpt-paper--actividades_objetivos" data-informe="actividades_objetivos" role="main" ${getStyleVars(estado.margenes)}>
    ${_getHtmlEncabezado()}
    <div class="report-body rpt-cmai-mt-standard">
      ${_renderCuerpoInforme()}
    </div>
  </div>
  `;

  container.scrollTop = 0;
  actualizarEstadoPaginacion(0, 1, '');
}

function _getHtmlEncabezado() {
  return getHtmlEncabezadoBase({
    tituloCorporativo: `<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container rpt-d-none">Consejo Elecnor</span> <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>`,
    textoBanner1: 'Elecnor',
    textoBanner2: 'Actividades',
    mes: estado.informeGlobalData?.meta?.filtros?.mes,
    anio: estado.informeGlobalData?.meta?.filtros?.anio,
    nroPagina: estado.nroPagina,
    mostrarNumeroPagina: estado.mostrarNumeroPagina,
    mostrarTitulo: estado.mostrarTitulo
  });
}

function _renderCuerpoInforme() {
  const data = estado.informeGlobalData;
  if (!data || !data.paises) return '';

  return data.paises.map(pais => _renderBloquePais(pais)).join('');
}

function _renderBloquePais(pais) {
  const anioActual = estado.informeGlobalData.meta.filtros.anio;
  const anioAnterior = anioActual - 1;
  const mesAnterior = _mesAnteriorCorto(estado.informeGlobalData.meta.filtros.mes);

  const tableHeader = `
  <thead>
    <tr class="rpt-th-year">
      <th colspan="2" class="rpt-align-center rpt-pt-0">Cierre ${anioAnterior}</th>
      <th rpt-border-none></th>
      <th class="rpt-col-act-nombre"></th>
      <th rpt-border-none></th>
      <th colspan="5" class="rpt-align-center rpt-pt-0">${anioActual}</th>
    </tr>
    <tr class="rpt-act-row-spacer">
      <th colspan="10"></th>
    </tr>
    <tr class="rpt-th-blue">
      <th class="rpt-col-act-porc-ant rpt-align-end rpt-act-th-border-bottom rpt-fs-8pt rpt-font-bold">
        % s/Merc
      </th>
      <th class="rpt-col-act-imp-ant rpt-align-end rpt-act-th-border-bottom rpt-fs-8pt rpt-font-bold">
        Contr.
      </th>
      <th rpt-border-none></th>
      <th class="rpt-col-act-nombre rpt-align-start rpt-header-align-middle rpt-ps-3 rpt-fs-8pt">
        <div class="rpt-act-badge rpt-text-uppercase">${pais.nombrePais}</div>
      </th>
      <th rpt-border-none></th>
      <th class="rpt-col-act-obj rpt-align-end rpt-act-th-border-bottom rpt-fs-8pt rpt-font-bold">
        Obj.
      </th>
      <th class="rpt-col-act-imp-act rpt-align-end rpt-act-th-border-bottom rpt-fs-8pt rpt-font-bold">
        Contr.
      </th>
      <th class="rpt-col-act-ip rpt-align-end rpt-act-th-border-bottom rpt-fs-8pt rpt-font-bold">
        Ip
      </th>
      <th class="rpt-col-act-var rpt-align-end rpt-act-th-border-bottom rpt-fs-8pt rpt-font-bold">
        % ${mesAnterior || anioAnterior}
      </th>
      <th class="rpt-col-act-porc-act rpt-align-end rpt-act-th-border-bottom rpt-fs-8pt rpt-font-bold">
        % s/Merc
      </th>
    </tr>
  </thead>
  `;

  const filasHtml = pais.detalle.map(d => `
    <tr class="rpt-detail-row">
      <td class="rpt-col-act-porc-ant rpt-align-end">${formatPercentage(d.porcentajeAnteriorMercado, 0)}</td>
      <td class="rpt-col-act-imp-ant rpt-align-end rpt-number-cell">${formatCurrency(d.importeAnterior, 0)}</td>
      <td rpt-border-none></td>
      <td class="rpt-col-act-nombre rpt-ps-3">${d.actividad}</td>
      <td rpt-border-none></td>
      <td class="rpt-col-act-obj rpt-align-end rpt-number-cell">${formatCurrency(d.importeObjetivos, 0)}</td>
      <td class="rpt-col-act-imp-act rpt-align-end rpt-number-cell">${formatCurrency(d.importeActual / 1000, 0)}</td>
      <td class="rpt-col-act-ip rpt-align-end">${formatCurrency(d.ip, 2)}</td>
      <td class="rpt-col-act-var rpt-align-end ${getVarClass(d.variacionPorcentaje)}">${d.variacionPorcentaje}</td>
      <td class="rpt-col-act-porc-act rpt-align-end">${formatPercentage(d.porcentajeActualMercado, 0)}</td>
    </tr>
  `).join('');

  const totalesHtml = `
    <tr class="rpt-act-row-spacer">
      <td colspan="10"></td>
    </tr>
    <tr class="rpt-total-row">
      <td class="rpt-col-act-porc-ant rpt-align-end rpt-act-total-border-top rpt-font-bold">
        100%
      </td>
      <td class="rpt-col-act-imp-ant rpt-align-end rpt-number-cell rpt-act-total-border-top rpt-font-bold">
        ${formatCurrency(pais.totales.importeAnterior, 0)}
      </td>
      <td rpt-border-none></td>
      <td class="rpt-col-act-nombre rpt-act-total-border-top">
        &nbsp;
      </td>
      <td rpt-border-none></td>
      <td class="rpt-col-act-obj rpt-align-end rpt-number-cell rpt-act-total-border-top rpt-font-bold">
        ${formatCurrency(pais.totales.importeObjetivos, 0)}
      </td>
      <td class="rpt-col-act-imp-act rpt-align-end rpt-number-cell rpt-act-total-border-top rpt-font-bold">
        ${formatCurrency(pais.totales.importeActual / 1000, 0)}
      </td>
      <td class="rpt-col-act-ip rpt-align-end rpt-number-cell rpt-act-total-border-top rpt-font-bold">
        ${formatCurrency(pais.totales.ip, 2)}
      </td>
      <td class="rpt-col-act-var rpt-align-end rpt-act-total-border-top rpt-font-bold">
        &nbsp;
      </td>
      <td class="rpt-col-act-porc-act rpt-align-end rpt-act-total-border-top rpt-font-bold">
        100%
      </td>
    </tr>
  `;

  return `
  <div class="rpt-bloque-actividad">
    <table class="rpt-table rpt-table-actividades">
      <colgroup>
        <col class="rpt-col-act-porc-ant">
        <col class="rpt-col-act-imp-ant">
        <col class="rpt-col-10px">
        <col class="rpt-col-act-nombre">
        <col class="rpt-col-10px">
        <col class="rpt-col-act-obj">
        <col class="rpt-col-act-imp-act">
        <col class="rpt-col-act-ip">
        <col class="rpt-col-act-var">
        <col class="rpt-col-act-porc-act">
      </colgroup>
      ${tableHeader}
      <tbody>
        ${filasHtml}
        ${totalesHtml}
      </tbody>
    </table>
  </div>
  `;
}

function _mesAnteriorCorto(mes) {
  const meses = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
  return mes > 1 ? meses[mes - 2] : '';
}

function _registrarEventos() {
  inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
  await imprimirInformeUnificado({
    informeGlobalData: estado.informeGlobalData,
    getHtmlEncabezado: _getHtmlEncabezado,
    renderContenido: _renderCuerpoInforme,
    modoAgrupacion: 'NONE',
    margenes: estado.margenes,
    nombreInforme: 'actividades_objetivos'
  });
}
