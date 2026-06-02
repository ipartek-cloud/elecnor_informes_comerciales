/**
 * Informe: Contrataciones AI (Asociadas a Inversión)
 * Basado en la arquitectura del informe de Contrataciones.
 */

import { RPT_CLASSES, formatCurrency, escapeHtml, getNombreMes, inicializarEventListenersBase, ejecutarGeneracionPrevia } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars, MARGENES_ESTANDAR } from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

/**
 * Función principal de ejecución del informe.
 */
export async function ejecutar({ anio, mes, nroPagina, mercado, umbral, mostrarTitulo, umbral1, umbral2 }) {
    try {
        // 1. Verificar y ejecutar generación previa si el checkbox está activado
        const generacionOk = await ejecutarGeneracionPrevia(
            'chkGenerarRPTPrincipalesObrasAI',
            '/api/ContratacionesAI/generar',
            { anio, mes },
            'Generando datos AI...'
        );
        if (!generacionOk) return;

        // 2. Cargar el informe
        let url = `/api/ContratacionesAI?anio=${anio}&mes=${mes}`;
        if (umbral1 != null) url += `&umbral1=${umbral1}`;
        if (umbral2 != null) url += `&umbral2=${umbral2}`;
        url += `&_=${Date.now()}`;
        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            claveAgrupacion: 'NONE',
            margenes: MARGENES_ESTANDAR
        });

    } catch (error) {
        console.error("Error al ejecutar informe Contrataciones AI:", error);
        throw error;
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
            <div class="report-body rpt-cmai-mt-standard">
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
    tituloCorporativo: '<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container">Consejo de Administración</span><span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>',
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
    if (data.datos) {
        const tieneFilas = data.datos.length > 0;
        const u1 = data.meta?.filtros?.umbral1 ?? 300;
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
          <div class="rpt-section-ai-header">
            Asociado a Inversión > ${_formatearUmbral(u1)}
          </div>
          <div class="rpt-month-header">${mesNombre}</div>
          ${tieneFilas ? `
          <table class="${RPT_CLASSES.TABLE} rpt-table-contrataciones-ai">
              <tbody>
                  ${filas}
              </tbody>
          </table>` : ''}
        </div>
        `;
    }

    // 2. SUBINFORME (MESES ANTERIORES ACUMULADOS) - Estilo Gris Histórico
    if (data.datosAnterior) {
        const tieneFilas = data.datosAnterior.length > 0;
        const u2 = data.meta?.filtros?.umbral2 ?? 700;
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
          <div class="rpt-section-ai-header">
            Anterior > ${_formatearUmbral(u2)}
          </div>
          ${tieneFilas ? `
          <table class="${RPT_CLASSES.TABLE} rpt-table-contrataciones-ai">
              <tbody>
                  ${filasAnt}
              </tbody>
          </table>` : ''}
        </div>
        `;
    }

    // Si no hay ningún dato en ninguno de los bloques
    if (!html) return `<div class="rpt-align-center rpt-p-5 rpt-text-muted">No se han encontrado registros para el periodo seleccionado.</div>`;

    return html;
}

/**
 * Formatea un umbral numérico (en miles de euros) dividiéndolo entre 1000
 * para mostrar en el título con el sufijo "M".
 * Ej: 300 → "0.3M", 700 → "0.7M", 1000 → "1M"
 */
function _formatearUmbral(valor) {
    const valorM = valor / 1000;
    return (valorM % 1 === 0) ? `${valorM}M` : `${valorM.toFixed(1)}M`;
}

/**
 * Registra eventos.
 */
function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
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
            margenes: estado.margenes,
            nombreInforme: 'contrataciones_ai'
        });
    } catch (error) {
        console.error("Error al intentar imprimir el informe AI:", error);
    }
}
