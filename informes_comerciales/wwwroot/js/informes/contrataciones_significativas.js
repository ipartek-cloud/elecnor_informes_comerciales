/**
 * Informe Contrataciones Significativas
 * Filtros: Mercado y SubDirección General
 */
import {
    RPT_CLASSES, formatCurrency, getNombreMes,
    actualizarEstadoPaginacion, inicializarEventListenersBase
} from './utils.js';
import {
    crearEstadoInforme, inicializarInforme,
    getHtmlEncabezadoBase, imprimirInformeUnificado
} from './informes_unificados_utils.js';
import { ApiClient, GlobalUI } from '../site.js';

// --- Estado ---
const estado = crearEstadoInforme();

// --- Ejecución ---
export async function ejecutar(anio, mes, nroPagina, mercado = 'Nacional', codSubDirGeneral = null) {
    try {
        // 1. Verificar si el checkbox de generación está activado
        const chkGenerar = document.getElementById('chkGenerarRPTPrincipalesContrataciones');
        const debeGenerar = chkGenerar?.checked ?? false;

        // 2. Si checkbox activado, llamar al endpoint de generación
        if (debeGenerar) {
            GlobalUI.showLoading('Generando contrataciones significativas...');

            try {
                const genResp = await ApiClient.post('/api/ContratacionesSignificativas/generar', {
                    anio: anio,
                    mes: mes
                }, true);

                if (!genResp.ok) {
                    const errorText = await genResp.text();
                    GlobalUI.showAlert('Error al generar significativos: ' + errorText, 'danger');
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

        const subDir = codSubDirGeneral || '221';

        const url = `/api/ContratacionesSignificativas`
            + `?anio=${anio}&mes=${mes}`
            + `&mercado=${encodeURIComponent(mercado)}`
            + `&codSubDirGeneral=${encodeURIComponent(subDir)}`
            + `&_=${Date.now()}`;

        estado.nroPagina = nroPagina;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina:         _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion:        'Página',
            claveAgrupacion:          'datos'
        });

    } catch (error) {
        console.error('[ContratacionesSignificativas] Error:', error);
        GlobalUI.showAlert?.('Error al cargar los datos del informe', 'danger');
    }
}

// --- Renderizado ---
async function _renderizarPagina(index = 0) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const dataArr = estado.informeGlobalData?.datos || [];
    const direccion = dataArr[index];

    const cuerpoInformeHtml = await _renderCuerpoInforme(direccion);

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="contrataciones_significativas" role="main" data-pagina-index="${index}">
            ${_getHtmlEncabezado(direccion)}
            <div class="report-body">
                ${cuerpoInformeHtml}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(estado.paginaActual, estado.paginasTotales, 'Página');
}

/**
 * Renderiza el cuerpo: tabla principal con detalle mensual intercalado asilada a la direccion actual.
 */
async function _renderCuerpoInforme(direccion) {
    let html = _renderTablaDireccion(direccion);

    if (!html?.trim()) {
        return `<div class="text-center p-5 text-muted">No se han encontrado registros para el periodo seleccionado.</div>`;
    }

    return html;
}

function _getHtmlEncabezado() {
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    const mercado = filtros.mercado || 'Nacional';
    const mesNombre = getNombreMes(filtros.mes);
    const nroPagina = estado.nroPagina;

    return `
        <div class="${RPT_CLASSES.HEADER}">
            <div>
                <span class="rpt-text-orange-council fs-4">Consejo de Administración</span>
                <span class="rpt-info-complementary ms-2">Información complementaria</span>
            </div>
            <div class="d-flex flex-column align-items-end">
                ${nroPagina ? `<span class="rpt-page-number">${nroPagina}</span>` : ''}
                <img src="/images/logoElecnor.png" alt="Logo Elecnor" class="rpt-header-logo" loading="lazy">
            </div>
        </div>
        <div class="${RPT_CLASSES.BANNER}">
            <span>Elecnor</span>
            <span>Contrat. significativas Mercado ${mercado}</span>
        </div>
        <div class="${RPT_CLASSES.SUBTITLE}">
            Cierre de ${mesNombre} ${filtros.anio} | Miles de euros
        </div>
    `;
}

function _renderTablaDireccion(direccion) {
    if (!direccion) return '';

    const dataMes = estado.informeGlobalData?.datosMes || [];
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    const nombreMes = getNombreMes(filtros.mes);

    // Cabecera de Dirección de Negocio y fila del Mes
    let bloqueHtml = `
    <tr>
        <td colspan="3" class="rpt-cont-sig-group-header" style="border-top: none;">
            <span class="rpt-cont-sig-group-title">${_escapeHtml(direccion.nombreDirNegocio)}</span>
        </td>
    </tr>
    <tr class="rpt-detail-row rpt-cont-sig-month-row">
        <td colspan="3" class="rpt-cont-sig-mes-label fw-bold">
            ${_escapeHtml(nombreMes)}
        </td>
    </tr>
    `;

    // Filtrar e inyectar los contratos correspondientes a esta Dirección de Negocio
    const contratosDelGrupo = dataMes.filter(item => 
        item.nombreDirNegocio === direccion.nombreDirNegocio
    );
    
    if (contratosDelGrupo.length > 0) {
        bloqueHtml += contratosDelGrupo.map(item => `
    <tr class="${RPT_CLASSES.DETAIL_ROW} rpt-cont-sig-mes-item">
        <td class="rpt-col-mes-cliente">${_escapeHtml(_limpiarCliente(item.nombreCliente_OK))}</td>
        <td class="rpt-col-mes-oferta">${_escapeHtml(item.descripcionOferta_OK)}</td>
        <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
    </tr>
        `).join('');
    }

    // Filtrar e inyectar los contratos de Meses Anteriores
    const dataMesesAnteriores = estado.informeGlobalData?.datosMesesAnteriores || [];
    const contratosAnterioresDelGrupo = dataMesesAnteriores.filter(item => 
        item.nombreDirNegocio === direccion.nombreDirNegocio
    );

    if (contratosAnterioresDelGrupo.length > 0) {
        bloqueHtml += `
    <tr class="rpt-cont-sig-anterior-label">
        <td colspan="3" class="rpt-text-muted-gray">Anterior</td>
    </tr>
        `;

        bloqueHtml += contratosAnterioresDelGrupo.map(item => `
    <tr class="${RPT_CLASSES.DETAIL_ROW} rpt-cont-sig-mes-item rpt-cont-sig-hist-row">
        <td class="rpt-col-mes-cliente">${_escapeHtml(_limpiarCliente(item.nombreCliente_OK))}</td>
        <td class="rpt-col-mes-oferta">${_escapeHtml(item.descripcionOferta_OK)}</td>
        <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
    </tr>
        `).join('');
    }

    return `
        <table class="rpt-table rpt-table-cont-sig mb-4">
            <colgroup>
                <col class="rpt-col-mes-cliente">
                <col class="rpt-col-mes-oferta">
                <col class="rpt-col-mes-importe">
            </colgroup>
            <thead class="border-0">
                <tr class="fw-bold border-0">
                    <th class="rpt-text-corporate text-start ps-3 border-0 fs-6">Contratación &gt;1M</th>
                    <th class="border-0"></th>
                    <th class="rpt-text-corporate text-end pe-3 border-0 fs-6">Mensual</th>
                </tr>
            </thead>
            <tbody>
                ${bloqueHtml}
            </tbody>
        </table>
    `;
}

/**
 * Limpia el prefijo ZZ_ del cliente (Regla Access: FGSUSTITUYE).
 */
function _limpiarCliente(nombre) {
    if (!nombre) return '';
    return nombre.replace(/^ZZ_/, '');
}

function _escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// --- Eventos e Impresión ---
function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido:   (direccion) => _renderTablaDireccion(direccion),
        modoAgrupacion:    'datos' 
    });
}
