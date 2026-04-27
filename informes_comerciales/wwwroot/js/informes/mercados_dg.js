/**
 * Módulo para el informe D.G. Infraestructuras x Mercado.
 * Estructura de página única sin paginación lógica.
 */
import { RPT_CLASSES, formatCurrency, formatPercentage, getIpClass, getVarClass, actualizarEstadoPaginacion, inicializarEventListenersBase } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars } from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

/**
 * Punto de entrada principal para la ejecución del informe.
 */
export async function ejecutar({ anio, mes, nroPagina, mostrarTitulo }) {
    try {
        const url = `/api/MercadosDG?anio=${anio}&mes=${mes}&_=${Date.now()}`;

        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

  await inicializarInforme({
    url,
    estado,
    renderizarPagina: _renderizarPagina,
    inicializarEventListeners: _registrarEventos,
    prefijoPaginacion: '',
    claveAgrupacion: 'NONE', // Visualización unificada
    margenes: { web: '16mm', pdf: '16mm', maxWidth: '1050px' }
  });
    } catch (error) {
        throw error;
    }
}

/**
 * Renderizado de la vista principal en el modal.
 */
function _renderizarPagina(index) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="mercados_dg" data-pagina-index="0" role="main"${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${_renderContructorCompleto()}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(0, 1, '');
}

/**
 * Genera el encabezado corporativo del informe.
 */
function _getHtmlEncabezado() {
  return getHtmlEncabezadoBase({
    tituloCorporativo: '<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container">Consejo Elecnor</span> <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>',
    textoBanner1: 'Elecnor',
    textoBanner2: 'D.G. Infraestructuras x Mercados',
    mes: estado.informeGlobalData?.meta?.filtros?.mes,
    anio: estado.informeGlobalData?.meta?.filtros?.anio,
    nroPagina: estado.nroPagina,
    mostrarNumeroPagina: estado.mostrarNumeroPagina,
    mostrarTitulo: estado.mostrarTitulo
  });
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

/**
 * Gestión de la exportación a PDF.
 */
async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: () => _renderContructorCompleto(true),
        modoAgrupacion: 'NONE',
        margenes: estado.margenes
    });
}

/**
 * Renderiza la cabecera de tabla con secciones Mensual y Acumulado.
 */
function _renderCabeceraCompartida(tituloCentral = 'Mercado') {
  const anioAnterior = (estado.informeGlobalData?.meta?.filtros?.anio - 1) || '2026';

  return `
  <colgroup>
    <col class="rpt-mercado-col-obj-m">
    <col class="rpt-mercado-col-contr-m">
    <col class="rpt-col-10px">
    <col class="rpt-mercado-col-desc">
    <col class="rpt-col-10px">
    <col class="rpt-mercado-col-obj-a">
    <col class="rpt-mercado-col-contr-a">
    <col class="rpt-mercado-col-ip">
    <col class="rpt-mercado-col-var">
  </colgroup>
  <thead>
    <tr class="rpt-font-bold">
      <th colspan="2" class="rpt-align-center rpt-text-corporate rpt-fs-8pt">Mensual</th>
      <th rpt-border-none></th>
      <th></th>
      <th rpt-border-none></th>
      <th colspan="4" class="rpt-align-center rpt-text-corporate rpt-fs-8pt">Acumulado</th>
    </tr>
    <tr class="rpt-mercado-row-spacer">
      <th colspan="9"></th>
    </tr>
    <tr class="rpt-font-bold">
      <th class="rpt-align-end rpt-pad-right-15 rpt-mercado-th-border rpt-text-corporate">Objet.</th>
      <th class="rpt-align-end rpt-pad-right-15 rpt-mercado-th-border rpt-text-corporate">Contr.</th>

      <th rpt-border-none></th>

      <th class="rpt-align-center rpt-text-white rpt-mercado-header-align">
        <div class="rpt-mercado-header-badge">${tituloCentral}</div>
      </th>

      <th rpt-border-none></th>

      <th class="rpt-align-end rpt-pad-right-15 rpt-mercado-th-border rpt-text-corporate">Objet.</th>
      <th class="rpt-align-end rpt-pad-right-15 rpt-mercado-th-border rpt-text-corporate">Contr.</th>
      <th class="rpt-align-center rpt-mercado-th-border rpt-text-corporate">Ip</th>
      <th class="rpt-align-center rpt-mercado-th-border rpt-text-corporate">Var/${anioAnterior}</th>
    </tr>
  </thead>
  `;
}

/**
 * Renderiza cabecera simplificada para sub-bloques.
 */
function _renderCabeceraSubinforme(tituloCentral = 'Mercado') {
  const anioAnterior = (estado.informeGlobalData?.meta?.filtros?.anio - 1) || '2026';

  return `
  <colgroup>
    <col class="rpt-mercado-col-obj-m">
    <col class="rpt-mercado-col-contr-m">
    <col class="rpt-col-10px">
    <col class="rpt-mercado-col-desc">
    <col class="rpt-col-10px">
    <col class="rpt-mercado-col-obj-a">
    <col class="rpt-mercado-col-contr-a">
    <col class="rpt-mercado-col-ip">
    <col class="rpt-mercado-col-var">
  </colgroup>
  <thead>
    <tr class="rpt-font-bold">
      <th class="rpt-align-end rpt-pad-right-15 rpt-mercado-th-border rpt-text-corporate">Objet.</th>
      <th class="rpt-align-end rpt-pad-right-15 rpt-mercado-th-border rpt-text-corporate">Contr.</th>

      <th rpt-border-none></th>

      <th class="rpt-align-center rpt-text-white rpt-mercado-header-align">
        <div class="rpt-mercado-header-badge">${tituloCentral}</div>
      </th>

      <th rpt-border-none></th>

      <th class="rpt-align-end rpt-pad-right-15 rpt-mercado-th-border rpt-text-corporate">Objet.</th>
      <th class="rpt-align-end rpt-pad-right-15 rpt-mercado-th-border rpt-text-corporate">Contr.</th>
      <th class="rpt-align-center rpt-mercado-th-border rpt-text-corporate">Ip</th>
      <th class="rpt-align-center rpt-mercado-th-border rpt-text-corporate">Var/${anioAnterior}</th>
    </tr>
  </thead>
  `;
}

/**
 * Banner de separador de sección.
 */
function _renderRptBanner(txtIzquierda, txtDerecha = "") {
  return `
  <div class="${RPT_CLASSES.BANNER} rpt-px-3 rpt-mt-4 rpt-mb-3">
    <span>${txtIzquierda}</span>
    <span>${txtDerecha}</span>
  </div>
  `;
}

/**
 * Constructor de la estructura completa del informe.
 */
function _renderContructorCompleto(esImpresion = false) {
  const data = estado.informeGlobalData;
  if (!data) return '';

  let html = `<div class="rpt-w-100 ${esImpresion ? '' : 'rpt-mb-4'}">`;

  // BLOQUE 1: Resumen Global (Mercado)
  html += `
  <div class="rpt-mt-6 rpt-mb-4">
    <table class="rpt-table rpt-table-stackable rpt-mercado-layout rpt-mb-0 rpt-w-100">
      ${_renderCabeceraCompartida('Mercado')}
      <tbody>
      `;
  data.resumenGlobal.forEach(rg => {
    html += _construirHtmlFila(rg.nombre, rg.mensual, rg.acumulado);
  });
  html += `
      </tbody>
      <tr class="rpt-spacer-row-totales"><td colspan="9" class="rpt-spacer-cell-totales"></td></tr>
      <tfoot>
        ${_construirHtmlFila('', data.totalGlobal.mensual, data.totalGlobal.acumulado, true)}
      </tfoot>
    </table>
  </div>`;

  // BLOQUE 2: Desglose por Direcciones de Negocio
  data.dirNegocios.forEach(dn => {

    html += _renderRptBanner("", dn.nombre);

    // Nacional / Internacional
    html += `
    <div class="rpt-mb-2">
      <table class="rpt-table rpt-table-stackable rpt-mercado-layout rpt-mb-0 rpt-w-100">
        ${_renderCabeceraSubinforme(dn.nombre)}
        <tbody>
        `;
    dn.mercados.forEach(m => {
      html += _construirHtmlFila(m.nombre, m.mensual, m.acumulado);
    });
    html += `
        </tbody>
        <tr class="rpt-spacer-row-totales"><td colspan="9" class="rpt-spacer-cell-totales"></td></tr>
        <tfoot>
          ${_construirHtmlFila('', dn.total.mensual, dn.total.acumulado, true)}
        </tfoot>
      </table>
    </div>`;

    // Unidades de Negocio
    html += `
    <div class="rpt-mb-5">
      <table class="rpt-table rpt-table-stackable rpt-mercado-layout rpt-mb-0 rpt-w-100">
        ${_renderCabeceraSubinforme('Unidades de Negocio')}
        <tbody>
        `;
    dn.unidades.forEach(u => {
      html += _construirHtmlFila(u.nombre, u.mensual, u.acumulado);
    });
    html += `
        </tbody>
        <tr class="rpt-spacer-row-totales"><td colspan="9" class="rpt-spacer-cell-totales"></td></tr>
        <tfoot>
          ${_construirHtmlFila('', dn.total.mensual, dn.total.acumulado, true)}
        </tfoot>
      </table>
    </div>`;
  });

  // BLOQUE 3: Subinforme Cartera Diferida
  html += _renderCarteraDiferida();

  html += `</div>`;
  return html;
}

function _construirHtmlFila(tituloFila, mens, acu, esTotal = false) {
  if (!mens) mens = {};
  if (!acu) acu = {};

  const wrapTotal = (val, align = 'rpt-align-end') => {
    if (!esTotal) return val;
    return `<div class="${align} rpt-font-bold rpt-text-corporate">${val}</div>`;
  };

  let midCellContent = tituloFila;
  let midCellClass = tituloFila ? '' : 'rpt-font-bold';

  if (esTotal) {
    midCellContent = '';
    midCellClass = 'rpt-td-total';
  } else {
    midCellClass += " rpt-ps-3";
    if (tituloFila && tituloFila.trim().startsWith('*')) {
      midCellClass += " rpt-hanging-indent";
    }
  }

  const rowClass = esTotal ? 'rpt-font-bold rpt-text-corporate' : 'rpt-detail-row rpt-mercado-detail-row';
  const mensualClass = esTotal ? 'rpt-td-total' : 'rpt-number-cell';
  const acumuladoClass = esTotal ? 'rpt-td-total' : 'rpt-number-cell';

  return `
  <tr class="${rowClass}">
    <td class="${mensualClass} rpt-pad-right-15" data-label="Obj. Mensual">${wrapTotal(formatCurrency(mens.importeObjetivo, 0))}</td>
    <td class="${mensualClass} rpt-pad-right-15" data-label="Real Mensual">${wrapTotal(formatCurrency(mens.importeContratado, 0))}</td>

    <td rpt-border-none></td>

    <td class="${midCellClass}" data-label="Descripción">${midCellContent}</td>

    <td rpt-border-none></td>

    <td class="${acumuladoClass} rpt-pad-right-15" data-label="Obj. Acum.">${wrapTotal(formatCurrency(acu.importeObjetivo, 0))}</td>
    <td class="${acumuladoClass} rpt-pad-right-15" data-label="Real Acum.">${wrapTotal(formatCurrency(acu.importeContratado, 0))}</td>
    <td class="${acumuladoClass} rpt-align-center ${getIpClass(acu.indiceProduccion)}"
      data-label="IP Acum."
      role="img"
      aria-label="Índice de producción: ${acu.indiceProduccion ?? 0}">
      ${wrapTotal(formatCurrency(acu.indiceProduccion, 2), 'rpt-align-center')}
    </td>
    <td class="${acumuladoClass} rpt-align-center ${getVarClass(acu.variacion)}"
      data-label="Var. %"
      role="img"
      aria-label="Variación porcentual: ${acu.variacion || '0%'}">
      ${wrapTotal(acu.variacion || '0%', 'rpt-align-center')}
    </td>
  </tr>
  `;
}

/**
 * Renderiza el subinforme de Cartera Diferida al final del informe.
 */
function _renderCarteraDiferida() {
    const data = estado.informeGlobalData;
    if (!data || !data.carteraDiferida || !data.carteraDiferida.lineas || data.carteraDiferida.lineas.length === 0) return '';

    const cd = data.carteraDiferida;
    const val = (v) => formatCurrency(v || 0, 0);
    const totales = cd.totales;
    const anioBase = data.meta?.filtros?.anio || new Date().getFullYear();

    // Headers dinámicos visuales
    const labelCartPrev = `1.1.${(anioBase - 2).toString().slice(-2)}`;
    const labelCartAct  = `1.1.${(anioBase - 1).toString().slice(-2)}`;
    const labelFuturo1  = `${anioBase}`;
    const labelFuturo2  = `${anioBase + 1}`;

  return `
  <div class="rpt-cd-separator rpt-mt-4 rpt-mb-3">
    <table class="rpt-table rpt-table-stackable rpt-mercado-layout w-100">
      <colgroup>
        <col class="rpt-cd-col-vacia">
        <col class="rpt-cd-col-cart">
        <col class="rpt-cd-col-cart">
        <col class="rpt-cd-col-concepto">
        <col class="rpt-cd-col-proy">
        <col class="rpt-cd-col-proy">
        <col class="rpt-cd-col-vacia">
      </colgroup>
      <thead>
        <tr class="rpt-cd-row-spacer">
          <th colspan="7"></th>
        </tr>
        <tr class="rpt-font-bold">
          <th></th>
          <th colspan="2" class="rpt-align-center rpt-text-corporate rpt-fs-8pt">Cart.</th>
          <th></th>
          <th colspan="2" class="rpt-align-center rpt-text-corporate rpt-fs-8pt"></th>
          <th></th>
        </tr>
        <tr class="rpt-cd-row-spacer">
          <th colspan="7"></th>
        </tr>
        <tr class="rpt-font-bold">
          <th></th>
          <th class="rpt-align-end rpt-pad-right-15 rpt-cd-th-border rpt-text-corporate">${labelCartPrev}</th>
          <th class="rpt-align-end rpt-pad-right-15 rpt-cd-th-border rpt-text-corporate">${labelCartAct}</th>
          <th class="rpt-align-center rpt-text-white rpt-cd-header-align">
            <div class="rpt-cd-header-badge">Cartera Diferida</div>
          </th>
          <th class="rpt-align-end rpt-pad-right-15 rpt-cd-th-border rpt-text-corporate">${labelFuturo1}</th>
          <th class="rpt-align-end rpt-pad-right-15 rpt-cd-th-border rpt-text-corporate">${labelFuturo2}</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        ${cd.lineas.map(l => `
        <tr class="rpt-detail-row rpt-cd-detail-row">
          <td></td>
          <td class="rpt-number-cell rpt-pad-right-15" data-label="Cartera Inicio 1">${val(l.valorCartPrev || l.ValorCartPrev || 0)}</td>
          <td class="rpt-number-cell rpt-pad-right-15" data-label="Cartera Inicio 2">${val(l.valorCartAct || l.ValorCartAct || 0)}</td>
          <td class="rpt-ps-3" data-label="Cartera Diferida">${(l.concepto || l.Concepto || '').trim()}</td>
          <td class="rpt-number-cell rpt-pad-right-15" data-label="Proyección 1">${val(l.valorFuturo1 || l.ValorFuturo1 || 0)}</td>
          <td class="rpt-number-cell rpt-pad-right-15" data-label="Proyección 2">${val(l.valorFuturo2 || l.ValorFuturo2 || 0)}</td>
          <td></td>
        </tr>
        `).join('')}
      </tbody>
      <tr class="rpt-spacer-row-totales"><td colspan="7" class="rpt-spacer-cell-totales"></td></tr>
      <tfoot class="rpt-font-bold">
        <tr class="rpt-cd-total-row">
          <td></td>
          <td class="rpt-align-end rpt-number-cell rpt-cd-total-cell" data-label="Total Cartera Inicio 1"><div class="rpt-cd-total-inner">${val(totales.valorCartPrev || totales.ValorCartPrev || 0)}</div></td>
          <td class="rpt-align-end rpt-number-cell rpt-cd-total-cell" data-label="Total Cartera Inicio 2"><div class="rpt-cd-total-inner">${val(totales.valorCartAct || totales.ValorCartAct || 0)}</div></td>
          <td class="rpt-cd-total-cell"></td>
          <td class="rpt-align-end rpt-number-cell rpt-cd-total-cell" data-label="Total Proyección 1"><div class="rpt-cd-total-inner">${val(totales.valorFuturo1 || totales.ValorFuturo1 || 0)}</div></td>
          <td class="rpt-align-end rpt-number-cell rpt-cd-total-cell" data-label="Total Proyección 2"><div class="rpt-cd-total-inner">${val(totales.valorFuturo2 || totales.ValorFuturo2 || 0)}</div></td>
          <td></td>
        </tr>
      </tfoot>
    </table>
  </div>
  `;
}
