/**
 * Informe: Principales Contrataciones del Año
 */

import { RPT_CLASSES, formatCurrency, escapeHtml, getNombreMes, inicializarEventListenersBase, ejecutarGeneracionPrevia } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars, MARGENES_ESTANDAR } from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

/**
 * Punto de entrada principal para la ejecución del informe.
 */
export async function ejecutar({ anio, mes, nroPagina, mercado, umbral, mostrarTitulo, umbral1, umbral2, umbral3, umbral4 }) {
    try {
        // 1. Verificar y ejecutar generación previa si el checkbox está activado
        const generacionOk = await ejecutarGeneracionPrevia(
            'chkGenerarRPTPrincipalesObras',
            '/api/Contrataciones/generarcontratacionobras',
            { anio, mes },
            'Generando datos de contrataciones...'
        );
        if (!generacionOk) return;

        // 2. Cargar el informe (con o sin generación previa)
        // Construir URL con umbrales dinámicos (solo si se proporcionan)
        let url = `/api/Contrataciones?anio=${anio}&mes=${mes}`;
        if (umbral1 != null) url += `&umbral1=${umbral1}`;
        if (umbral2 != null) url += `&umbral2=${umbral2}`;
        if (umbral3 != null) url += `&umbral3=${umbral3}`;
        if (umbral4 != null) url += `&umbral4=${umbral4}`;
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
        console.error("Error al ejecutar informe Contrataciones:", error);
        throw error;
    }
}

async function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const cuerpoInformeHtml = await _renderCuerpoInforme();

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="contrataciones" role="main" ${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body rpt-cmai-mt-standard">
                ${cuerpoInformeHtml}
            </div>
        </div>
    `;

    container.scrollTop = 0;
}

function _getHtmlEncabezado() {
  const data = estado.informeGlobalData;
  return getHtmlEncabezadoBase({
    tituloCorporativo: '<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container">Consejo de Administración</span><span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>',
        textoBanner1: 'Principales Contrataciones del Año',
        textoBanner2: 'Contratos',
        mes: data?.meta?.filtros?.mes,
        anio: data?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina || 5,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

async function _renderCuerpoInforme() {
    const data = estado.informeGlobalData;
    let html = '';

    // Renderizar encabezado del informe principal SIEMPRE (título sección + mes),
    // incluso si no hay filas de datos (p.ej. todas filtradas por "SIN").
    if (data?.informePrincipal) {
        const tieneFilas = data.informePrincipal.datos && data.informePrincipal.datos.length > 0;
        html = `
            <div class="rpt-content-block">
                ${_renderTituloSeccion()}
                ${_renderCabeceraMes(data.informePrincipal)}
                ${tieneFilas ? _renderTablaContrataciones(data.informePrincipal) : ''}
            </div>
        `;
    }
    // Renderizar SubInforme 1: Año Nacional Anterior
    if (data?.subInformes?.annoNacionalAnterior?.length > 0) {
        const u2 = data.meta?.filtros?.umbral2 ?? 15000;
        html += _renderSubInformeGenerico(data.subInformes.annoNacionalAnterior, {
            titulo: `Anterior > ${_formatearUmbral(u2)}`,
            mostrarMes: false,
            claseSeccion: 'rpt-contrataciones-anno-nacional-anterior-section'
        });
    }

    // Renderizar SubInforme 2: Internacional Mes (Al final como solicitado)
    if (data?.subInformes?.annoInternacionalMes?.length > 0) {
        const u3 = data.meta?.filtros?.umbral3 ?? 10000;
        html += _renderSubInformeGenerico(data.subInformes.annoInternacionalMes, {
            titulo: `Mercado Internacional > ${_formatearUmbral(u3)}`,
            mostrarMes: true,
            claseSeccion: '' // Sin clase extra, usa la base rpt-content-block
        });
    }

  // Renderizar SubInforme 3: Internacional Anterior (Último bloque - sin borde inferior)
  if (data?.subInformes?.annoInternacionalAnterior?.length > 0) {
    const u4 = data.meta?.filtros?.umbral4 ?? 25000;
    html += _renderSubInformeGenerico(data.subInformes.annoInternacionalAnterior, {
      titulo: `Anterior > ${_formatearUmbral(u4)}`,
      mostrarMes: false,
      claseSeccion: 'rpt-contrataciones-last' // Clase especial para el último subinforme (sin borde)
    });
  }

    return html;
}

/**
 * Renderizador genérico para subinformes de contratación (Nacional Anterior, Internacional Mes).
 * Unifica la lógica de renderizado para evitar duplicidad de código.
 */
function _renderSubInformeGenerico(datos, config) {
    if (!datos || datos.length === 0) return '';

  const filas = datos.map(item => {
    const badgeAI = item.ai === 'AI' ?
      `<span class="rpt-badge-ai" title="Oferta Asociada a Inversión">AI</span>` : '';

    return `
    <tr class="${RPT_CLASSES.DETAIL_ROW}">
      <td class="rpt-col-ai rpt-align-center">${badgeAI}</td>
      <td class="rpt-col-desc rpt-align-start">${escapeHtml(item.descripcionOfertas_OK)}</td>
      <td class="rpt-col-cliente rpt-align-start">${escapeHtml(item.nombreClientes_OK)}</td>
      <td class="rpt-col-importe rpt-align-end rpt-font-mono">${formatCurrency(item.importeContratado_OK, 0)}</td>
      <td class="rpt-col-dirnegocio rpt-align-start rpt-ps-3">${escapeHtml(item.nombreDirNegocio_OK)}</td>
    </tr>
    `;
  }).join('');

    const htmlMes = config.mostrarMes ? `<div class="rpt-month-header">${datos[0].meses}</div>` : '';

    return `
        <div class="rpt-content-block ${config.claseSeccion}">
            <h3 class="rpt-section-title">${config.titulo}</h3>
            ${htmlMes}
            <table class="${RPT_CLASSES.TABLE} rpt-table-contrataciones">
                <tbody>
                    ${filas}
                </tbody>
            </table>
        </div>
    `;
}

function _renderTituloSeccion() {
    const data = estado.informeGlobalData;
    const u1 = data?.meta?.filtros?.umbral1 ?? 5000;
    return `<h3 class="rpt-section-title">Mercado Nacional > ${_formatearUmbral(u1)}</h3>`;
}

/**
 * Formatea un umbral numérico (en miles de euros) dividiéndolo entre 1000
 * para mostrar en el título con el sufijo "M".
 * Ej: 5000 → "5M", 15000 → "15M", 13100 → "13.1M"
 */
function _formatearUmbral(valor) {
    const valorM = valor / 1000;
    return (valorM % 1 === 0) ? `${valorM}M` : `${valorM.toFixed(1)}M`;
}

function _renderCabeceraMes(data) {
    const mes = data?.meta?.filtros?.mes;
    const nombreMes = getNombreMes(mes);
    
    return `<div class="rpt-month-header">${nombreMes}</div>`;
}

function _renderTablaContrataciones(data) {
  const filas = data.datos.map(item => `
    <tr class="${RPT_CLASSES.DETAIL_ROW}">
      <td class="rpt-col-ai"></td>
      <td class="rpt-col-desc rpt-align-start">${escapeHtml(item.descripcionOfertas_OK)}</td>
      <td class="rpt-col-cliente rpt-align-start">${escapeHtml(item.nombreClientes_OK)}</td>
      <td class="rpt-col-importe rpt-align-end">${formatCurrency(item.importeContratado_OK, 0)}</td>
      <td class="rpt-col-dirnegocio"></td>
    </tr>
  `).join('');

    return `
        <table class="${RPT_CLASSES.TABLE} rpt-table-contrataciones">
            <tbody>
                ${filas}
            </tbody>
        </table>
    `;
}


function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    try {
        // Obtenemos el HTML completo (incluyendo el subinforme asíncrono)
        const contenidoHtml = await _renderCuerpoInforme();
        
        // Llamamos a la utilidad de impresión con modoAgrupacion: 'NONE'
        // Esto es CRÍTICO para informes que son visualmente una sola página con bloques,
        // de lo contrario intentaría paginar por cada registro del array base.
        await imprimirInformeUnificado({
            informeGlobalData: estado.informeGlobalData,
            getHtmlEncabezado: _getHtmlEncabezado,
            renderContenido: () => contenidoHtml,
            modoAgrupacion: 'NONE',
            margenes: estado.margenes,
            nombreInforme: 'contrataciones'
        });
    } catch (error) {
        console.error("Error al intentar imprimir el informe:", error);
    }
}
