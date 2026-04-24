/**
 * Informe Contrataciones Significativas
 * Filtros: Mercado y SubDirección General
 */
import {
    RPT_CLASSES, formatCurrency, getNombreMes, escapeHtml,
    actualizarEstadoPaginacion, inicializarEventListenersBase
} from './utils.js';
import {
    crearEstadoInforme, inicializarInforme,
    getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars
} from './informes_unificados_utils.js';
import { ApiClient, GlobalUI } from '../site.js';

// --- Estado ---
const estado = crearEstadoInforme();

// --- Ejecución ---
export async function ejecutar({ anio, mes, nroPagina, mercado = 'Nacional', umbral, codSubDir = '221', mostrarTitulo = true }) {
    try {
        const chkGenerar = document.getElementById('chkGenerarRPTPrincipalesContrataciones');
        if (chkGenerar?.checked) {
            GlobalUI.showLoading('Generando contrataciones significativas...');
            const genResp = await ApiClient.post('/api/ContratacionesSignificativas/generar', { anio, mes }, true);
            if (!genResp.ok) {
                const errorText = await genResp.text();
                GlobalUI.showAlert('Error al generar: ' + errorText, 'danger');
                GlobalUI.hideLoading();
                return;
            }
            GlobalUI.hideLoading();
        }

        const subDir = codSubDir || '221';
        const url = `/api/ContratacionesSignificativas?anio=${anio}&mes=${mes}&mercado=${encodeURIComponent(mercado)}&codSubDirGeneral=${encodeURIComponent(subDir)}&_=${Date.now()}`;

        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: 'Página',
            claveAgrupacion: 'datos',
            margenes: { web: '16mm', pdf: '16mm', maxWidth: '1050px' } // V-01, V-02
        });

    } catch (error) {
        console.error('[ContratacionesSignificativas] Error:', error);
    }
}

async function _renderizarPagina(index = 0) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const dataArr = estado.informeGlobalData?.datos || [];
    const direccion = dataArr[index];
    const cuerpoHtml = direccion ? _renderTablaDireccion(direccion) : '<div class="text-center p-5 rpt-text-muted-gray">No hay registros disponibles.</div>';

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="contrataciones_significativas" role="main" ${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${cuerpoHtml}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(estado.paginaActual, estado.paginasTotales, 'Página');
}

function _getHtmlEncabezado() {
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    const mercado = filtros.mercado || 'Nacional';
    
    return getHtmlEncabezadoBase({
        // V-14: Patrón Título CMAI
        tituloCorporativo: `
            <span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container">Consejo Elecnor</span>
            <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Información complementaria</span>`,
        textoBanner1: 'Elecnor',
        textoBanner2: `Contrat. significativas Mercado ${mercado}`,
        mes: filtros.mes,
        anio: filtros.anio,
        nroPagina: estado.nroPagina || (mercado === 'Nacional' ? 9 : 10),
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

function _renderTablaDireccion(direccion) {
    const dataMes = estado.informeGlobalData?.datosMes || [];
    const dataAnterior = estado.informeGlobalData?.datosMesesAnteriores || [];
    const nombreMes = getNombreMes(estado.informeGlobalData?.meta?.filtros?.mes);

    // Filtrado de datos
    const contratosMes = dataMes.filter(item => item.nombreDirNegocio === direccion.nombreDirNegocio);
    const contratosAnt = dataAnterior.filter(item => item.nombreDirNegocio === direccion.nombreDirNegocio);

    let rowsHtml = `
        <tr>
            <td colspan="3" class="rpt-cont-sig-group-header">
                <span class="rpt-cont-sig-group-title">${escapeHtml(direccion.nombreDirNegocio)}</span>
            </td>
        </tr>
        <tr class="rpt-cont-sig-month-row">
            <td colspan="3" class="rpt-cont-sig-mes-label rpt-font-bold">${escapeHtml(nombreMes)}</td>
        </tr>`;

    rowsHtml += contratosMes.map(item => `
        <tr class="rpt-detail-row">
            <td class="rpt-col-mes-cliente">${escapeHtml(item.nombreCliente_OK.replace(/^ZZ_/, ''))}</td>
            <td class="rpt-col-mes-oferta">${escapeHtml(item.descripcionOferta_OK)}</td>
            <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
        </tr>`).join('');

    if (contratosAnt.length > 0) {
        rowsHtml += `
            <tr class="rpt-cont-sig-anterior-label">
                <td colspan="3" class="rpt-text-muted-gray">Anterior</td>
            </tr>`;
        rowsHtml += contratosAnt.map(item => `
            <tr class="rpt-detail-row rpt-cont-sig-hist-row">
                <td class="rpt-col-mes-cliente">${escapeHtml(item.nombreCliente_OK.replace(/^ZZ_/, ''))}</td>
                <td class="rpt-col-mes-oferta">${escapeHtml(item.descripcionOferta_OK)}</td>
                <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
            </tr>`).join('');
    }

    return `
        <table class="rpt-table rpt-table-cont-sig">
            <colgroup>
                <col class="rpt-col-mes-cliente">
                <col class="rpt-col-mes-oferta">
                <col class="rpt-col-mes-importe">
            </colgroup>
            <thead>
                <tr class="rpt-font-bold">
                    <th class="rpt-text-corporate rpt-align-start rpt-ps-3 rpt-fs-8pt">Contratación &gt;1M</th>
                    <th></th>
                    <th class="rpt-text-corporate rpt-align-end rpt-pe-3 rpt-fs-8pt">Mensual</th>
                </tr>
            </thead>
            <tbody>
                ${rowsHtml}
            </tbody>
        </table>`;
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: (dir) => _renderTablaDireccion(dir),
        modoAgrupacion: 'datos',
        margenes: estado.margenes
    });
}
