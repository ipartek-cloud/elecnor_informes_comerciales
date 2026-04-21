/**
 * Informe: Principales Contrataciones del Año
 */

import { RPT_CLASSES, formatCurrency, escapeHtml, getNombreMes } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars } from './informes_unificados_utils.js';
import { ApiClient, GlobalUI } from '../site.js';

const estado = crearEstadoInforme();

/**
 * Punto de entrada principal para la ejecución del informe.
 */
export async function ejecutar({ anio, mes, nroPagina, mercado, umbral, mostrarTitulo }) {
    try {
        // 1. Verificar si el checkbox está activado
        const chkGenerar = document.getElementById('chkGenerarRPTPrincipalesObras');
        const debeGenerar = chkGenerar?.checked ?? false;

        // 2. Si checkbox activado, llamar al endpoint de generación
        if (debeGenerar) {
            GlobalUI.showLoading('Generando datos de contrataciones...');

            try {
                const genResp = await ApiClient.post('/api/Contrataciones/generarcontratacionobras', {
                    anio: anio,
                    mes: mes
                }, true);

                if (!genResp.ok) {
                    const errorText = await genResp.text();
                    GlobalUI.showAlert('Error al generar datos: ' + errorText, 'danger');
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

        // 3. Cargar el informe (con o sin generación previa)
        const url = `/api/Contrataciones?anio=${anio}&mes=${mes}&_=${Date.now()}`;
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
            margenes: { web: '3rem', pdf: '6.4mm', maxWidth: '1050px' }
        });

    } catch (error) {
        console.error("Error al ejecutar informe Contrataciones:", error);
    }
}

async function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const cuerpoInformeHtml = await _renderCuerpoInforme();

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="contrataciones" role="main" ${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${cuerpoInformeHtml}
            </div>
        </div>
    `;

    container.scrollTop = 0;
}

function _getHtmlEncabezado() {
    const data = estado.informeGlobalData;
    return getHtmlEncabezadoBase({
        tituloCorporativo: '<span class="rpt-text-orange-council fs-3">Consejo de Administración</span> <span class="ms-3 fs-6 text-primary">Informe de Contratación</span>',
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

    // Renderizar informe principal (Solo si hay datos, sin alertas de "No hay datos")
    if (data?.informePrincipal?.datos && data.informePrincipal.datos.length > 0) {
        html = `
            <div class="rpt-content-block">
                ${_renderTituloSeccion()}
                ${_renderCabeceraMes(data.informePrincipal)}
                ${_renderTablaContrataciones(data.informePrincipal)}
            </div>
        `;
    }
    // Renderizar SubInforme 1: Año Nacional Anterior
    if (data?.subInformes?.annoNacionalAnterior?.length > 0) {
        html += _renderSubInformeGenerico(data.subInformes.annoNacionalAnterior, {
            titulo: 'Anterior > 15 M',
            mostrarMes: false,
            claseSeccion: 'rpt-contrataciones-anno-nacional-anterior-section'
        });
    }

    // Renderizar SubInforme 2: Internacional Mes (Al final como solicitado)
    if (data?.subInformes?.annoInternacionalMes?.length > 0) {
        html += _renderSubInformeGenerico(data.subInformes.annoInternacionalMes, {
            titulo: 'Mercado Internacional > 10 M',
            mostrarMes: true,
            claseSeccion: '' // Sin clase extra, usa la base rpt-content-block
        });
    }

    // Renderizar SubInforme 3: Internacional Anterior (Último bloque)
    if (data?.subInformes?.annoInternacionalAnterior?.length > 0) {
        html += _renderSubInformeGenerico(data.subInformes.annoInternacionalAnterior, {
            titulo: 'Anterior > 25 M',
            mostrarMes: false,
            claseSeccion: 'rpt-contrataciones-anno-nacional-anterior-section'
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
            `<span class="badge border border-primary text-primary px-1" title="Oferta Asociada a Inversión" 
                   style="font-size: 0.65rem; min-width: 20px; display: inline-block;">AI</span>` : '';
                   
        return `
            <tr class="${RPT_CLASSES.DETAIL_ROW}">
                <td class="rpt-col-ai text-center">${badgeAI}</td>
                <td class="rpt-col-desc text-start">${escapeHtml(item.descripcionOfertas_OK)}</td>
                <td class="rpt-col-cliente text-start">${escapeHtml(item.nombreClientes_OK)}</td>
                <td class="rpt-col-importe text-end font-monospace">${formatCurrency(item.importeContratado_OK, 0)}</td>
                <td class="rpt-col-dirnegocio text-start ps-3">${escapeHtml(item.nombreDirNegocio_OK)}</td>
            </tr>
        `;
    }).join('');

    const htmlMes = config.mostrarMes ? `<div class="rpt-month-header">${datos[0].meses}</div>` : '<hr class="rpt-subreport-separator">';

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
    return '<h3 class="rpt-section-title">Mercado Nacional > 5 M</h3>';
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
            <td class="rpt-col-desc text-start">${escapeHtml(item.descripcionOfertas_OK)}</td>
            <td class="rpt-col-cliente text-start">${escapeHtml(item.nombreClientes_OK)}</td>
            <td class="rpt-col-importe text-end">${formatCurrency(item.importeContratado_OK, 0)}</td>
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
    // Es vital que btnPdf obtenga su handler cada vez, ya que los botones son compartidos
    const btnPdf = document.getElementById(RPT_CLASSES.BTN_EXPORTAR_PDF);
    if (btnPdf) {
        btnPdf.onclick = _imprimirInforme;
    }
    estado.eventosIniciados = true;
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
            margenes: estado.margenes
        });
    } catch (error) {
        console.error("Error al intentar imprimir el informe:", error);
    }
}
