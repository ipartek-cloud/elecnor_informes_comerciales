/**
 * Informe: Contrataciones Significativas RI
 * Paridad: Access (Estándar 16mm)
 */
import {
    RPT_CLASSES, formatCurrency, getNombreMes,
    actualizarEstadoPaginacion, inicializarEventListenersBase,
    ocultarControlesPaginacion
} from './utils.js';
import {
    crearEstadoInforme, inicializarInforme,
    getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars, MARGENES_ESTANDAR
} from './informes_unificados_utils.js';
import { ApiClient, GlobalUI } from '../site.js';

const estado = crearEstadoInforme();

export async function ejecutar({ anio, mes, nroPagina, mercado = 'Nacional', umbral, codSubDir = '221', mostrarTitulo = true }) {
    try {
        const chkGenerar = document.getElementById('chkGenerarRPTPrincipalesContrataciones');
        if (chkGenerar?.checked) {
            GlobalUI.showLoading('Generando contrataciones...');
            const genResp = await ApiClient.post('/api/ContratacionesSignificativasRi/generar', { anio, mes }, true);
            if (!genResp.ok) {
                GlobalUI.showAlert('Error al generar: ' + await genResp.text(), 'danger');
                GlobalUI.hideLoading();
                return;
            }
            GlobalUI.hideLoading();
        }

        let url = `/api/ContratacionesSignificativasRi?anio=${anio}&mes=${mes}&mercado=${encodeURIComponent(mercado)}&codSubDirGeneral=${encodeURIComponent(codSubDir || '221')}`;
        if (nroPagina) url += `&nroPagina=${nroPagina}`;
        url += `&_=${Date.now()}`;
        
        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina != null);
        estado.mostrarTitulo = mostrarTitulo;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: 'Página',
            claveAgrupacion: 'NONE',
            margenes: MARGENES_ESTANDAR
        });

    } catch (error) {
        console.error('[ContratacionesSignificativas RI] Error:', error);
        GlobalUI.showAlert?.('Error al cargar el informe', 'danger');
        throw error;
    }
}

async function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const dataArr = estado.informeGlobalData?.datos || [];
    const dataMes = estado.informeGlobalData?.datosMes || [];
    const direccionesConDatos = dataArr.filter(dir => dataMes.some(item => item.nombreDirNegocio === dir.nombreDirNegocio));

    if (direccionesConDatos.length === 0) {
        container.innerHTML = `
            <div class="${RPT_CLASSES.PAPER}" data-informe="contrataciones_significativas_ri" ${getStyleVars(estado.margenes)}>
                ${_getHtmlEncabezado()}
                <div class="report-body rpt-cmai-mt-medium rpt-text-center rpt-p-5 rpt-text-muted">No se han encontrado registros.</div>
            </div>`;
        ocultarControlesPaginacion();
        return;
    }

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="contrataciones_significativas_ri" ${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body rpt-cmai-mt-medium">${_renderCuerpoInforme(direccionesConDatos)}</div>
        </div>`;

    container.scrollTop = 0;
    ocultarControlesPaginacion();
}

function _renderCuerpoInforme(direcciones) {
    const dataMes = estado.informeGlobalData?.datosMes || [];
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    const umbralTexto = estado.informeGlobalData?.meta?.umbralTexto || 'Contratación > 2M';

  const filaMesHtml = `
    <tr class="rpt-cont-sig-month-row">
      <td colspan="3" class="rpt-cont-sig-mes-label rpt-font-bold rpt-fs-9pt">${getNombreMes(filtros.mes)}</td>
    </tr>`;

    const bloquesHtml = direcciones.map(dir => {
        const contratos = dataMes.filter(item => item.nombreDirNegocio === dir.nombreDirNegocio);
        return `
            <tr>
                <td colspan="3" class="rpt-cont-sig-group-header">
                    <span class="rpt-cont-sig-group-title rpt-font-bold">${_escapeHtml(dir.nombreDirNegocio)}</span>
                </td>
            </tr>
            ${contratos.map(item => `
                <tr class="${RPT_CLASSES.DETAIL_ROW} rpt-cont-sig-mes-item">
                    <td class="rpt-col-mes-cliente">${_escapeHtml(item.nombreCliente_OK?.replace(/^ZZ_/, ''))}</td>
                    <td class="rpt-col-mes-oferta">${_escapeHtml(item.descripcionOferta_OK)}</td>
                    <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
                </tr>`).join('')}`;
    }).join('');

    return `
        <table class="rpt-table rpt-table-cont-sig rpt-mb-4">
            <colgroup>
                <col class="rpt-col-mes-cliente"><col class="rpt-col-mes-oferta"><col class="rpt-col-mes-importe">
            </colgroup>
  <thead>
      <tr class="rpt-font-bold">
        <th class="rpt-text-corporate rpt-text-start rpt-ps-2 rpt-fs-11pt">${_escapeHtml(umbralTexto)}</th>
        <th></th>
        <th class="rpt-text-corporate rpt-text-end rpt-pe-3 rpt-fs-9pt">Mensual</th>
      </tr>
    </thead>
            <tbody>${filaMesHtml}${bloquesHtml}</tbody>
        </table>`;
}

function _getHtmlEncabezado() {
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    return getHtmlEncabezadoBase({
        tituloCorporativo: '<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container rpt-d-none">Consejo Elecnor</span> <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>',
        textoBanner1: 'Elecnor',
        textoBanner2: `Contrataciones Significativas Mercado ${filtros.mercado || 'Nacional'}`,
        mes: filtros.mes, anio: filtros.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

function _escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: () => _renderCuerpoInforme(estado.informeGlobalData?.datos.filter(dir => 
            (estado.informeGlobalData?.datosMes || []).some(item => item.nombreDirNegocio === dir.nombreDirNegocio)
        )),
        modoAgrupacion: 'NONE',
        margenes: estado.margenes,
        nombreInforme: 'contrataciones_significativas_ri'
    });
}
