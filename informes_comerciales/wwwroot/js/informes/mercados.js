/**
 * Módulo para el informe Mercados.
 * Renderiza el informe completo en una sola página tal y como requiere el diseño.
 */
import { RPT_CLASSES, formatCurrency, formatPercentage, getIpClass, getVarClass, actualizarEstadoPaginacion, inicializarEventListenersBase } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado } from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

export async function ejecutar(anio, mes, nroPagina) {
    try {
        let url = `/api/Mercados?anio=${anio}&mes=${mes}`;
        if (nroPagina) url += `&nroPagina=${nroPagina}`;
        url += `&_=${Date.now()}`;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: '',
            claveAgrupacion: 'NONE',
            margenes: { web: '1.5rem', pdf: '6.4mm', maxWidth: '1200px' }
        });
    } catch (error) {
        throw error;
    }
}

function _renderizarPagina(index) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="mercados" data-pagina-index="0" role="main">
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${_renderContructorCompleto()}
            </div>
        </div>
    `;

    container.scrollTop = 0;

    actualizarEstadoPaginacion(0, 1, '');
}

function _getHtmlEncabezado() {
    return getHtmlEncabezadoBase({
        tituloCorporativo: '<span class="rpt-text-orange-council fs-3">Consejo de Administración</span> <span class="ms-3 fs-6">Informe de Contratación</span>',
        textoBanner1: 'Elecnor',
        textoBanner2: 'Mercados',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.informeGlobalData?.meta?.filtros?.nroPagina
    });
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: () => _renderContructorCompleto(true),
        modoAgrupacion: 'NONE',
        margenes: { web: '1.5rem', pdf: '6.4mm', maxWidth: '1200px' }
    });
}

function _renderCabeceraCompartida(tituloCentral = 'Mercado') {
    const anioAnterior = (estado.informeGlobalData?.meta?.filtros?.anio - 1) || '2026';

    return `
        <colgroup>
            <col class="rpt-mercado-col-obj-m">
            <col class="rpt-mercado-col-contr-m">
            <col class="rpt-mercado-col-desc">
            <col class="rpt-mercado-col-obj-a">
            <col class="rpt-mercado-col-contr-a">
            <col class="rpt-mercado-col-ip">
            <col class="rpt-mercado-col-var">
        </colgroup>
        <thead>
            <tr class="fw-bold">
                <th colspan="2" class="text-center rpt-text-corporate fs-7">Mensual</th>
                <th></th>
                <th colspan="4" class="text-center rpt-text-corporate fs-7">Acumulado</th>
            </tr>
            <tr class="rpt-mercado-row-spacer">
                <th colspan="7"></th>
            </tr>
            <tr class="fw-bold">
                <th class="text-end pe-2 rpt-mercado-th-border rpt-text-corporate">Objet.</th>
                <th class="text-end pe-2 rpt-mercado-th-border rpt-text-corporate">Contr.</th>

                <th class="text-center text-white rpt-mercado-header-align">
                    <div class="rpt-mercado-header-badge">${tituloCentral}</div>
                </th>

                <th class="text-end pe-2 rpt-mercado-th-border rpt-text-corporate">Objet.</th>
                <th class="text-end pe-2 rpt-mercado-th-border rpt-text-corporate">Contr.</th>
                <th class="text-center rpt-mercado-th-border rpt-text-corporate">Ip</th>
                <th class="text-center rpt-mercado-th-border rpt-text-corporate">Var/${anioAnterior}</th>
            </tr>
        </thead>
    `;
}

function _renderCabeceraSubinforme(tituloCentral = 'Mercado') {
    const anioAnterior = (estado.informeGlobalData?.meta?.filtros?.anio - 1) || '2026';

    return `
        <colgroup>
            <col class="rpt-mercado-col-obj-m">
            <col class="rpt-mercado-col-contr-m">
            <col class="rpt-mercado-col-desc">
            <col class="rpt-mercado-col-obj-a">
            <col class="rpt-mercado-col-contr-a">
            <col class="rpt-mercado-col-ip">
            <col class="rpt-mercado-col-var">
        </colgroup>
        <thead>
            <tr class="fw-bold">
                <th class="text-end pe-2 rpt-mercado-th-border rpt-text-corporate">Objet.</th>
                <th class="text-end pe-2 rpt-mercado-th-border rpt-text-corporate">Contr.</th>

                <th class="text-center text-white rpt-mercado-header-align">
                    <div class="rpt-mercado-header-badge">${tituloCentral}</div>
                </th>

                <th class="text-end pe-2 rpt-mercado-th-border rpt-text-corporate">Objet.</th>
                <th class="text-end pe-2 rpt-mercado-th-border rpt-text-corporate">Contr.</th>
                <th class="text-center rpt-mercado-th-border rpt-text-corporate">Ip</th>
                <th class="text-center rpt-mercado-th-border rpt-text-corporate">Var/${anioAnterior}</th>
            </tr>
        </thead>
    `;
}

function _renderRptBanner(txtIzquierda, txtDerecha = "") {
    return `
        <div class="${RPT_CLASSES.BANNER} d-flex justify-content-between px-3 mt-4 mb-3">
            <span>${txtIzquierda}</span>
            <span>${txtDerecha}</span>
        </div>
    `;
}

function _renderContructorCompleto(esImpresion = false) {
    const data = estado.informeGlobalData;
    if (!data) return '';

    let html = `<div class="w-100 ${esImpresion ? '' : 'mb-4'}">`;

    // 1) BLOQUE GLOBAL: Mercado
    // El banner principal ya se incluye en el encabezado (_getHtmlEncabezado).
    html += `
        <div class="mb-4">
            <table class="rpt-table rpt-table-stackable rpt-mercado-layout mb-0 w-100">
                ${_renderCabeceraCompartida('Mercado')}
                <tbody>
    `;
    data.resumenGlobal.forEach(rg => {
        html += _construirHtmlFila(rg.nombre, rg.mensual, rg.acumulado);
    });
    html += `</tbody><tfoot class="fw-bold">`;
    html += _construirHtmlFila('', data.totalGlobal.mensual, data.totalGlobal.acumulado, true);
    html += `</tfoot></table></div>`;

    // 2) BLOQUES POR DIR. NEGOCIO
    data.dirNegocios.forEach(dn => {
        
        // El banner de la DG (Alineado a la derecha como requiere el diseño)
        html += _renderRptBanner("", dn.nombre);

        // Bloque A: DirNegocio (Nacional / Internacional)
        html += `
            <div class="mb-2">
                <table class="rpt-table rpt-table-stackable rpt-mercado-layout mb-0 w-100">
                    ${_renderCabeceraSubinforme(dn.nombre)}
                    <tbody>
        `;
        dn.mercados.forEach(m => {
            html += _construirHtmlFila(m.nombre, m.mensual, m.acumulado);
        });
        html += `</tbody><tfoot class="fw-bold">`;
        html += _construirHtmlFila('', dn.total.mensual, dn.total.acumulado, true);
        html += `</tfoot></table></div>`;

        // Bloque B: Unidades de Negocio
        html += `
            <div class="mb-5">
                <table class="rpt-table rpt-table-stackable rpt-mercado-layout mb-0 w-100">
                    ${_renderCabeceraSubinforme('Unidades de Negocio')}
                    <tbody>
        `;
        dn.unidades.forEach(u => {
            html += _construirHtmlFila(u.nombre, u.mensual, u.acumulado);
        });
        html += `</tbody><tfoot class="fw-bold">`;
        html += _construirHtmlFila('', dn.total.mensual, dn.total.acumulado, true);
        html += `</tfoot></table></div>`;
    });

    html += `</div>`;
    return html;
}

function _construirHtmlFila(tituloFila, mens, acu, esTotal = false) {
    if (!mens) mens = {};
    if (!acu) acu = {};

    const wrapTotal = (val, align = 'text-end') => {
        if (!esTotal) return val;
        return `<div class="${align} fw-bold rpt-text-corporate rpt-mercado-total-cell">${val}</div>`;
    };

    let midCellContent = tituloFila;
    let midCellClass = tituloFila ? '' : 'fw-bold';

    if (esTotal) {
        midCellContent = `<div class="rpt-mercado-total-line">&nbsp;</div>`;
        midCellClass = 'text-center p-0';
    } else {
        midCellClass += " ps-3";
    }

    return `
        <tr class="rpt-detail-row rpt-mercado-detail-row">
            <td class="rpt-number-cell pe-2" data-label="Obj. Mensual">${wrapTotal(formatCurrency(mens.importeObjetivo, 0))}</td>
            <td class="rpt-number-cell pe-2" data-label="Real Mensual">${wrapTotal(formatCurrency(mens.importeContratado, 0))}</td>
            
            <td class="${midCellClass} ${esTotal ? 'rpt-mercado-cell-total' : ''}" data-label="Descripción">${midCellContent}</td>

            <td class="rpt-number-cell pe-2" data-label="Obj. Acum.">${wrapTotal(formatCurrency(acu.importeObjetivo, 0))}</td>
            <td class="rpt-number-cell pe-2" data-label="Real Acum.">${wrapTotal(formatCurrency(acu.importeContratado, 0))}</td>
            <td class="text-center ${getIpClass(acu.indiceProduccion)}" 
                data-label="IP Acum." 
                role="img" 
                aria-label="Índice de producción: ${acu.indiceProduccion ?? 0}">
                ${wrapTotal(formatCurrency(acu.indiceProduccion, 2), 'text-center')}
            </td>
            <td class="text-center ${getVarClass(acu.variacion)}" 
                data-label="Var. %" 
                role="img" 
                aria-label="Variación porcentual: ${acu.variacion || '0%'}">
                ${wrapTotal(acu.variacion || '0%', 'text-center')}
            </td>
        </tr>
    `;
}
