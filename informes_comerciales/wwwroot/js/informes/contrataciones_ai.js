/**
 * Informe: Contrataciones AI (Asociadas a Inversión)
 * Basado en la arquitectura del informe de Contrataciones.
 */

import { RPT_CLASSES, formatCurrency, escapeHtml, getNombreMes } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars } from './informes_unificados_utils.js';
import { ApiClient, GlobalUI } from '../site.js';

const estado = crearEstadoInforme();

/**
 * Función principal de ejecución del informe.
 */
export async function ejecutar({ anio, mes, nroPagina, mercado, umbral, mostrarTitulo }) {
    try {
        // 1. Verificar si el checkbox de generación está activado
        const chkGenerar = document.getElementById('chkGenerarRPTPrincipalesObrasAI');
        const debeGenerar = chkGenerar?.checked ?? false;

        // 2. Si checkbox activado, llamar al endpoint de generación
        if (debeGenerar) {
            GlobalUI.showLoading('Generando datos AI...');
            try {
                const genResp = await ApiClient.post('/api/ContratacionesAI/generar', {
                    anio: anio,
                    mes: mes
                }, true);

                if (!genResp.ok) {
                    const errorText = await genResp.text();
                    GlobalUI.showAlert('Error al generar datos AI: ' + errorText, 'danger');
                    GlobalUI.hideLoading();
                    return;
                }
            } catch (error) {
                GlobalUI.showAlert('Error al conectar con el servidor', 'danger');
                GlobalUI.hideLoading();
                return;
            }
            GlobalUI.hideLoading();
        }

        // 3. Cargar el informe
        const url = `/api/ContratacionesAI?anio=${anio}&mes=${mes}&_=${Date.now()}`;
        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

await inicializarInforme({
      url,
      estado,
      renderizarPagina: _renderizarPagina,
      inicializarEventListeners: _registrarEventos,
      claveAgrupacion: 'NONE', // Es un informe de página única por ahora
      margenes: { web: '16mm', pdf: '16mm', maxWidth: '1050px' }
    });

    } catch (error) {
        console.error("Error al ejecutar informe Contrataciones AI:", error);
    }
}

/**
 * [ACCIÓN 3] Renderiza la página del informe de forma asíncrona.
 */
async function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    // Llamada asíncrona preparada para Fase 2 (subinformes)
    const cuerpoInformeHtml = await _renderCuerpoInforme();

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="contrataciones_ai" role="main" ${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${cuerpoInformeHtml}
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
  return getHtmlEncabezadoBase({
    tituloCorporativo: '<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container">Consejo Elecnor</span><span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>',
        textoBanner1: data?.meta?.titulo || 'Principales Contrataciones del Año',
        textoBanner2: data?.meta?.subTitulo || 'Contratos',
        mes: data?.meta?.filtros?.mes,
        anio: data?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina || 6,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

/**
 * [ACCIÓN 3] Renderiza el cuerpo del informe de forma asíncrona.
 * Facilita la carga de subinformes en la Fase 2 mediante Task.WhenAll o llamadas paralelas.
 */
async function _renderCuerpoInforme() {
    const data = estado.informeGlobalData;
    if (!data) return '';

    let html = '';

    // 1. BLOQUE PRINCIPAL (MES ACTUAL)
    if (data.datos && data.datos.length > 0) {
        const mesNombre = getNombreMes(data.meta.filtros.mes);
    const filas = data.datos.map(item => `
    <tr class="${RPT_CLASSES.DETAIL_ROW}">
      <td class="rpt-col-ai rpt-align-center rpt-text-small rpt-text-muted">${item.mercado}</td>
      <td class="rpt-col-desc rpt-align-start">${escapeHtml(item.descripcion)}</td>
      <td class="rpt-col-cliente rpt-align-start">${escapeHtml(item.cliente)}</td>
      <td class="rpt-col-importe rpt-align-end rpt-font-mono">${formatCurrency(item.importe, 0)}</td>
    </tr>
  `).join('');

    html += `
    <div class="rpt-content-block">
      <div class="rpt-section-ai-header rpt-mt-4 rpt-mb-2">
        Asociado a Inversión > 0,3M
      </div>
                <div class="rpt-month-header">${mesNombre}</div>
                <table class="${RPT_CLASSES.TABLE} rpt-table-contrataciones-ai">
                    <tbody>
                        ${filas}
                    </tbody>
                </table>
            </div>
        `;
    }

    // 2. SUBINFORME (MESES ANTERIORES ACUMULADOS) - Estilo Gris Histórico
    if (data.datosAnterior && data.datosAnterior.length > 0) {
    const filasAnt = data.datosAnterior.map(item => `
    <tr class="${RPT_CLASSES.DETAIL_ROW}">
      <td class="rpt-col-ai rpt-align-center rpt-text-small">${item.mercado}</td>
      <td class="rpt-col-desc rpt-align-start">${escapeHtml(item.descripcion)}</td>
      <td class="rpt-col-cliente rpt-align-start">${escapeHtml(item.cliente)}</td>
      <td class="rpt-col-importe rpt-align-end rpt-font-mono">${formatCurrency(item.importe, 0)}</td>
    </tr>
  `).join('');

    html += `
    <div class="rpt-content-block rpt-subreport-ai-anterior">
      <div class="rpt-section-ai-header rpt-mt-4 rpt-mb-2">
        Anterior > 0,7M
      </div>
                <table class="${RPT_CLASSES.TABLE} rpt-table-contrataciones-ai">
                    <tbody>
                        ${filasAnt}
                    </tbody>
                </table>
            </div>
        `;
    }

    // Si no hay ningún dato en ninguno de los bloques
    if (!html) return `<div class="rpt-align-center rpt-p-5 rpt-text-muted">No se han encontrado registros para el periodo seleccionado.</div>`;

    return html;
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
 * Lógica de impresión coordinada.
 */
async function _imprimirInforme() {
    try {
        const contenidoHtml = await _renderCuerpoInforme();
        await imprimirInformeUnificado({
            informeGlobalData: estado.informeGlobalData,
            getHtmlEncabezado: _getHtmlEncabezado,
            renderContenido: () => contenidoHtml,
            modoAgrupacion: 'NONE',
            margenes: estado.margenes
        });
    } catch (error) {
        console.error("Error al intentar imprimir el informe AI:", error);
    }
}
