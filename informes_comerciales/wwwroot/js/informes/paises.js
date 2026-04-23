/**
 * Módulo para el informe de Países (Mercado Internacional).
 * Basado en el diseño simétrico de dos columnas comparativas.
 * Soporta dos modos de filtrado:
 * - umbral = 0: Muestra todos los países con importe > 0
 * - umbral = 100000: Muestra solo países con importe >= 100000 (Relevantes)
 */
import { RPT_CLASSES, formatCurrency, formatPercentage, actualizarEstadoPaginacion, inicializarEventListenersBase } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars } from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

/**
 * Punto de entrada llamado por el gestor de informes.
 * @param {object} params - Objeto de parámetros
 */
export async function ejecutar({ anio, mes, nroPagina, umbral = 0, mostrarTitulo }) {
    try {
        // Convertir umbral a número (viene como string desde data-umbral en HTML)
        const umbralNum = umbral !== undefined && umbral !== null ? Number(umbral) : 0;
        
        let url = `/api/Paises?anio=${anio}&mes=${mes}&umbral=${umbralNum}`;
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
            claveAgrupacion: 'NONE', // Informe de página única
            margenes: { web: '16mm', pdf: '16mm', maxWidth: '1050px' }
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
        <div class="${RPT_CLASSES.PAPER}" data-informe="paises" role="main"${getStyleVars(estado.margenes)}>
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
        tituloCorporativo: '<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container">Consejo Elecnor</span><span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>',
        textoBanner1: 'Elecnor',
        textoBanner2: estado.informeGlobalData?.meta?.titulo || 'Mercado internacional por países',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina || 3,
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
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: () => _renderTablaPaises() + _renderFooterInfo(),
        modoAgrupacion: 'NONE',
        margenes: estado.margenes
    });
}

/**
 * Renderiza la tabla principal con el layout simétrico.
 */
function _renderTablaPaises() {
    const data = estado.informeGlobalData;
    if (!data || !data.paises) return '<p class="rpt-align-center rpt-fs-8pt">No hay datos disponibles para este periodo.</p>';

    const anioActual = data.meta.filtros.anio;
    const anioAnterior = anioActual - 1;

    let html = `
        <table class="rpt-table rpt-paises-table rpt-w-100">
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
                <tr class="rpt-th-blue-segmented">
<th class="rpt-align-center rpt-paises-th-border">% S/Internac</th>
            <th class="rpt-align-end rpt-pad-right-15 rpt-paises-th-border">Contr.</th>
            <th class="rpt-align-center rpt-paises-th-border">Pos.</th>
            <th class="rpt-paises-pais-cell rpt-paises-th-border-pais">País</th>
            <th class="rpt-align-center rpt-paises-th-border">Pos.</th>
            <th class="rpt-align-end rpt-pad-right-15 rpt-paises-th-border">Contr.</th>
            <th class="rpt-align-center rpt-paises-th-border">% S/Internac</th>
                </tr>
            </thead>
            <tbody>
    `;

    data.paises.forEach(p => {
        const porcAnterior = p.porcentajeSobreInternacionalAnterior != null ? p.porcentajeSobreInternacionalAnterior.toLocaleString('de-DE', { minimumFractionDigits: 0, maximumFractionDigits: 0 }) : '0';
        const porcActual = p.porcentajeSobreInternacionalActual != null ? p.porcentajeSobreInternacionalActual.toLocaleString('de-DE', { minimumFractionDigits: 0, maximumFractionDigits: 0 }) : '0';
        
        html += `
            <tr class="rpt-detail-row">
<td class="rpt-align-center">${porcAnterior}%</td>
      <td class="rpt-paises-num-cell">${formatCurrency(p.importeAnterior, 0)}</td>
      <td class="rpt-paises-pos-cell">${p.posicionAnterior || ''}</td>

      <td class="rpt-paises-pais-cell">
        <div class="rpt-paises-pais-wrapper">
          <span class="rpt-paises-asterisk-container">
            ${p.esNuevo ? '<span class="rpt-paises-new-flag">*</span>' : ''}
          </span>
          <span>${p.pais}</span>
        </div>
      </td>

      <td class="rpt-paises-pos-cell">${p.posicionActual || ''}</td>
      <td class="rpt-paises-num-cell">${formatCurrency(p.importeActual / 1000, 0)}</td>
      <td class="rpt-align-center">${porcActual}%</td>
            </tr>
        `;
    });

    // FILA 1 de totales: Subtotal de los países visibles en pantalla
    const subtotalPorcAnterior = data.totales.subtotalPorcentajeAnterior != null
        ? data.totales.subtotalPorcentajeAnterior.toLocaleString('de-DE', { minimumFractionDigits: 0, maximumFractionDigits: 0 })
        : '0';
    const subtotalPorcActual = data.totales.subtotalPorcentajeActual != null
        ? data.totales.subtotalPorcentajeActual.toLocaleString('de-DE', { minimumFractionDigits: 0, maximumFractionDigits: 0 })
        : '0';

    html += `
</tbody>
  <tfoot class="rpt-paises-total-row">
  <!-- Fila separadora 6px (Estándar V-11 - Gap de Totales) -->
  <tr class="rpt-spacer-row-totales">
    <td colspan="7" class="rpt-spacer-cell-totales"></td>
  </tr>
  <tr>
    <td class="rpt-align-center rpt-paises-total-line">${subtotalPorcAnterior}%</td>
    <td class="rpt-paises-num-cell rpt-paises-total-line">${formatCurrency(data.totales.subtotalImporteAnterior, 0)}</td>
    <td></td>
    <td class="rpt-paises-total-line"></td>
    <td></td>
    <td class="rpt-paises-num-cell rpt-paises-total-line">${formatCurrency(data.totales.subtotalImporteActual / 1000, 0)}</td>
    <td class="rpt-align-center rpt-paises-total-line">${subtotalPorcActual}%</td>
  </tr>
  <!-- Fila 2: Total Internacional Global -->
  <tr class="rpt-paises-total-global">
    <td></td>
    <td class="rpt-paises-num-cell">${formatCurrency(data.totales.totalInternacionalAnterior, 0)}</td>
    <td></td>
    <td>Total Internacional</td>
    <td></td>
    <td class="rpt-paises-num-cell">${formatCurrency(data.totales.totalInternacionalActual / 1000, 0)}</td>
    <td></td>
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
            <div class="rpt-paises-footer-nota">(*) País nuevo con contratación</div>
        </div>
    `;
}
