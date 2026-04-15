/**
 * Informe Contrataciones Significativas (Resto Informes)
 * Filtros: Mercado y SubDirección General
 * Variante sin histórico de meses anteriores.
 */
import {
    RPT_CLASSES, formatCurrency, getNombreMes,
    actualizarEstadoPaginacion, inicializarEventListenersBase,
    ocultarControlesPaginacion
} from './utils.js';
import {
    crearEstadoInforme, inicializarInforme,
    getHtmlEncabezadoBase, imprimirInformeUnificado
} from './informes_unificados_utils.js';
import { ApiClient, GlobalUI } from '../site.js';

// --- Estado ---
const estado = crearEstadoInforme();

// --- Ejecución ---
export async function ejecutar(anio, mes, nroPagina, mercado = 'Nacional', codSubDirGeneral = '221', mostrarTitulo = true) {
    try {
        // 1. Verificar si el checkbox de generación está activado
        const chkGenerar = document.getElementById('chkGenerarRPTPrincipalesContrataciones_ri');
        const debeGenerar = chkGenerar?.checked ?? false;

        // 2. Si checkbox activado, llamar al endpoint de generación
        if (debeGenerar) {
            GlobalUI.showLoading('Generando contrataciones significativas...');

            try {
                // LLamada al controlador que se implementará posteriormente en otra fase
                const genResp = await ApiClient.post('/api/ContratacionesSignificativasRi/generar', {
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

        // LLamada al controlador que se implementará posteriormente en otra fase
        const url = `/api/ContratacionesSignificativasRi`
            + `?anio=${anio}&mes=${mes}`
            + `&mercado=${encodeURIComponent(mercado)}`
            + `&codSubDirGeneral=${encodeURIComponent(subDir)}`
            + `&_=${Date.now()}`;

        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina:         _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion:        'Página',
            claveAgrupacion:          'NONE'
        });

    } catch (error) {
        console.error('[ContratacionesSignificativas RI] Error:', error);
        GlobalUI.showAlert?.('Error al cargar los datos del informe', 'danger');
    }
}

// --- Renderizado ---
async function _renderizarPagina(index = 0) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const dataArr = estado.informeGlobalData?.datos || [];
    const dataMes = estado.informeGlobalData?.datosMes || [];
    
    // Filtrar solo las direcciones que tienen al menos un contrato significativo
    const direccionesConDatos = dataArr.filter(direccion => 
        dataMes.some(item => item.nombreDirNegocio === direccion.nombreDirNegocio)
    );

    // Si no hay ninguna dirección con datos, mostrar mensaje
    if (direccionesConDatos.length === 0) {
        container.innerHTML = `
            <div class="${RPT_CLASSES.PAPER}" data-informe="contrataciones_significativas_ri" role="main">
                ${_getHtmlEncabezado()}
                <div class="report-body">
                    <div class="text-center p-5 text-muted">No se han encontrado registros para el periodo seleccionado.</div>
                </div>
            </div>
        `;
        container.scrollTop = 0;
        ocultarControlesPaginacion();
        return;
    }

    // Renderizar TODAS las direcciones en una sabana continua
    const cuerpoHtml = _renderCuerpoInforme();

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="contrataciones_significativas_ri" role="main">
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${cuerpoHtml}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    ocultarControlesPaginacion();
}

/**
 * Renderiza el cuerpo: tabla principal con todas las direcciones en una sabana.
 * Modelo similar a Ranking Contratación - una sola página con thead que se repite.
 */
function _renderCuerpoInforme() {
    const dataArr = estado.informeGlobalData?.datos || [];
    const dataMes = estado.informeGlobalData?.datosMes || [];
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    const nombreMes = getNombreMes(filtros.mes);
    const umbralTexto = estado.informeGlobalData?.meta?.umbralTexto || 'Contratación > 2M';

    // Filtrar solo las direcciones que tienen al menos un contrato significativo
    const direccionesConDatos = dataArr.filter(direccion => 
        dataMes.some(item => item.nombreDirNegocio === direccion.nombreDirNegocio)
    );

    if (direccionesConDatos.length === 0) {
        return `<div class="text-center p-5 text-muted">No se han encontrado registros para el periodo seleccionado.</div>`;
    }

    // Generar el contenido de cada dirección
    const bloquesHtml = direccionesConDatos.map(direccion => {
        const contratosDelGrupo = dataMes.filter(item => 
            item.nombreDirNegocio === direccion.nombreDirNegocio
        );

        if (contratosDelGrupo.length === 0) return '';

        // Cabecera de Dirección de Negocio y fila del Mes
        let bloque = `
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

        // Añadir los contratos
        bloque += contratosDelGrupo.map(item => `
        <tr class="${RPT_CLASSES.DETAIL_ROW} rpt-cont-sig-mes-item">
            <td class="rpt-col-mes-cliente">${_escapeHtml(_limpiarCliente(item.nombreCliente_OK))}</td>
            <td class="rpt-col-mes-oferta">${_escapeHtml(item.descripcionOferta_OK)}</td>
            <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
        </tr>
        `).join('');

        return bloque;
    }).join('');

    // Devolver una única tabla con thead que se repetirá en cada página del PDF
    return `
        <table class="rpt-table rpt-table-cont-sig mb-4">
            <colgroup>
                <col class="rpt-col-mes-cliente">
                <col class="rpt-col-mes-oferta">
                <col class="rpt-col-mes-importe">
            </colgroup>
            <thead class="border-0">
                <tr class="fw-bold border-0">
                    <th class="rpt-text-corporate text-start ps-3 border-0 fs-6">${_escapeHtml(umbralTexto)}</th>
                    <th class="border-0"></th>
                    <th class="rpt-text-corporate text-end pe-3 border-0 fs-6">Mensual</th>
                </tr>
            </thead>
            <tbody>
                ${bloquesHtml}
            </tbody>
        </table>
    `;
}

function _getHtmlEncabezado() {
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    const mercado = filtros.mercado || 'Nacional';
    
    return getHtmlEncabezadoBase({
        tituloCorporativo: '<span class="rpt-info-complementary ms-2">Información complementaria</span>',
        textoBanner1: 'Elecnor',
        textoBanner2: `Contrat. significativas Mercado ${mercado}`,
        mes: filtros.mes,
        anio: filtros.anio,
        nroPagina: estado.nroPagina || null,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

function _renderTablaDireccion(direccion) {
    if (!direccion) return '';

    const dataMes = estado.informeGlobalData?.datosMes || [];
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    const nombreMes = getNombreMes(filtros.mes);

    // Filtrar los contratos correspondientes a esta Dirección de Negocio
    const contratosDelGrupo = dataMes.filter(item => 
        item.nombreDirNegocio === direccion.nombreDirNegocio
    );
    
    // Si no hay contratos significativos para esta dirección, no mostrar nada
    if (contratosDelGrupo.length === 0) {
        return '';
    }

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

    // Añadir los contratos (ya sabemos que hay al menos uno)
    bloqueHtml += contratosDelGrupo.map(item => `
    <tr class="${RPT_CLASSES.DETAIL_ROW} rpt-cont-sig-mes-item">
        <td class="rpt-col-mes-cliente">${_escapeHtml(_limpiarCliente(item.nombreCliente_OK))}</td>
        <td class="rpt-col-mes-oferta">${_escapeHtml(item.descripcionOferta_OK)}</td>
        <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
    </tr>
    `).join('');

    const umbralTexto = estado.informeGlobalData?.meta?.umbralTexto || 'Contratación > 2M';

    return `
        <table class="rpt-table rpt-table-cont-sig mb-4">
            <colgroup>
                <col class="rpt-col-mes-cliente">
                <col class="rpt-col-mes-oferta">
                <col class="rpt-col-mes-importe">
            </colgroup>
            <thead class="border-0">
                <tr class="fw-bold border-0">
                    <th class="rpt-text-corporate text-start ps-3 border-0 fs-6">${_escapeHtml(umbralTexto)}</th>
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
    const contenidoHtml = _renderCuerpoInforme();
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: () => contenidoHtml,
        modoAgrupacion: 'NONE'
    });
}
