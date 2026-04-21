/**
 * Informe: Actividades_Objetivos (Consejo Administración)
 * Módulo para renderizado dinámico del informe de actividades con objetivos e IP.
 */

import { RPT_CLASSES, formatCurrency, formatPercentage, actualizarEstadoPaginacion, inicializarEventListenersBase, getNombreMes, getVarClass } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars } from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

/**
 * Punto de entrada llamado por el gestor de informes.
 */
export async function ejecutar({ anio, mes, nroPagina, mostrarTitulo }) {
    try {
        const url = `/api/ActividadesObjetivos?anio=${anio}&mes=${mes}&_=${Date.now()}`;
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
        console.error("Error al ejecutar informe Actividades_Objetivos:", error);
    }
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="actividades_objetivos" role="main" ${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${_renderCuerpoInforme()}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(0, 1, '');
}

function _getHtmlEncabezado() {
    return getHtmlEncabezadoBase({
        tituloCorporativo: 'Informe de Contratación',
        textoBanner1: 'Elecnor',
        textoBanner2: 'Actividades Objetivos',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

function _renderCuerpoInforme() {
    const data = estado.informeGlobalData;
    if (!data || !data.paises) return '';

    return data.paises.map(pais => _renderBloquePais(pais)).join('');
}

function _renderBloquePais(pais) {
    const anioActual = estado.informeGlobalData.meta.filtros.anio;
    const anioAnterior = anioActual - 1;
    const mesAnterior = _mesAnteriorCorto(estado.informeGlobalData.meta.filtros.mes);

    const tableHeader = `
        <thead>
            <tr class="rpt-th-year">
                <th colspan="2" class="text-center p-0">Cierre ${anioAnterior}</th>
                <th class="rpt-col-act-nombre"></th>
                <th colspan="5" class="text-center p-0">${anioActual}</th>
            </tr>
            <tr class="rpt-act-row-spacer">
                <th colspan="8"></th>
            </tr>
            <tr class="rpt-th-blue">
                <th class="rpt-col-act-porc-ant text-center rpt-act-th-border-bottom">
                    % s/Merc
                </th>
                <th class="rpt-col-act-imp-ant text-end pe-3 rpt-act-th-border-bottom">
                    Contr.
                </th>
                <th class="rpt-col-act-nombre text-start rpt-header-align-middle px-4">
                    <div class="rpt-act-badge text-uppercase">${pais.nombrePais}</div>
                </th>
                <th class="rpt-col-act-obj text-end pe-3 rpt-act-th-border-bottom">
                    Obj.
                </th>
                <th class="rpt-col-act-imp-act text-end pe-3 rpt-act-th-border-bottom">
                    Contr.
                </th>
                <th class="rpt-col-act-ip text-center rpt-act-th-border-bottom">
                    Ip
                </th>
                <th class="rpt-col-act-var text-center rpt-act-th-border-bottom">
                    % ${mesAnterior || anioAnterior}
                </th>
                <th class="rpt-col-act-porc-act text-center rpt-act-th-border-bottom">
                    % s/Merc
                </th>
            </tr>
        </thead>
    `;

    const filasHtml = pais.detalle.map(d => `
        <tr class="rpt-detail-row">
            <td class="rpt-col-act-porc-ant text-center">${formatPercentage(d.porcentajeAnteriorMercado, 0)}</td>
            <td class="rpt-col-act-imp-ant text-end pe-3">${formatCurrency(d.importeAnterior, 0)}</td>
            <td class="rpt-col-act-nombre ps-3">${d.actividad}</td>
            <td class="rpt-col-act-obj text-end pe-3">${formatCurrency(d.importeObjetivos, 0)}</td>
            <td class="rpt-col-act-imp-act text-end pe-3">${formatCurrency(d.importeActual / 1000, 0)}</td>
            <td class="rpt-col-act-ip text-center">${formatCurrency(d.ip, 2)}</td>
            <td class="rpt-col-act-var text-center ${getVarClass(d.variacionPorcentaje)}">${d.variacionPorcentaje}</td>
            <td class="rpt-col-act-porc-act text-center">${formatPercentage(d.porcentajeActualMercado, 0)}</td>
        </tr>
    `).join('');

    const totalesHtml = `
        <tr class="rpt-total-row">
            <td class="rpt-col-act-porc-ant text-center rpt-act-total-border-top">
                100%
            </td>
            <td class="rpt-col-act-imp-ant text-end pe-3 rpt-act-total-border-top">
                ${formatCurrency(pais.totales.importeAnterior, 0)}
            </td>
            <td class="rpt-col-act-nombre">
                &nbsp;
            </td>
            <td class="rpt-col-act-obj text-end pe-3 rpt-act-total-border-top">
                ${formatCurrency(pais.totales.importeObjetivos, 0)}
            </td>
            <td class="rpt-col-act-imp-act text-end pe-3 rpt-act-total-border-top">
                ${formatCurrency(pais.totales.importeActual / 1000, 0)}
            </td>
            <td class="rpt-col-act-ip text-center rpt-act-total-border-top">
                ${formatCurrency(pais.totales.ip, 2)}
            </td>
            <td class="rpt-col-act-var text-center rpt-act-total-border-top">
                
            </td>
            <td class="rpt-col-act-porc-act text-center rpt-act-total-border-top">
                100%
            </td>
        </tr>
    `;

    return `
        <div class="rpt-bloque-actividad">
            <table class="rpt-table rpt-table-actividades">
                ${tableHeader}
                <tbody>
                    ${filasHtml}
                    ${totalesHtml}
                </tbody>
            </table>
        </div>
    `;
}

function _mesAnteriorCorto(mes) {
    const meses = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"];
    return mes > 1 ? meses[mes - 2] : '';
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: _renderCuerpoInforme,
        modoAgrupacion: 'NONE',
        margenes: estado.margenes
    });
}
