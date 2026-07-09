/**
 * Módulo para el informe Gerencias (Resumen) Nacional - Internacional.
 * 3 bloques: Total, Gerencia Nacional, Gerencia Internacional.
 * Cada bloque se divide en grupos jerárquicos definidos por SumarizaGerentes.
 * Patrón A: sábana única sin paginación real.
 */
import {
    RPT_CLASSES,
    formatCurrency,
    escapeHtml,
    getIpClass,
    getVarClass,
    getNombreMes,
    getMesCorto,
    actualizarEstadoPaginacion,
    inicializarEventListenersBase
} from './utils.js';
import {
    crearEstadoInforme,
    inicializarInforme,
    getHtmlEncabezadoBase,
    imprimirInformeUnificado,
    getStyleVars,
    MARGENES_ESTANDAR
} from './informes_unificados_utils.js';

const estado = crearEstadoInforme();
const NOMBRE_INFORME = 'gerencias_nacional_internacional';

const MARGENES_PROPIOS = {
    top: '6mm',
    bottom: '6mm',
    left: '10mm',
    right: '10mm'
};

export async function ejecutar({ anio, mes, nroPagina, mostrarTitulo }) {
    try {
        let url = `/api/GerenciasNacionalInternacional?anio=${anio}&mes=${mes}`;
        if (nroPagina) url += `&nroPagina=${nroPagina}`;
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
            margenes: MARGENES_PROPIOS
        });
    } catch (error) {
        console.error('Error al ejecutar Gerencias N/I:', error);
        throw error;
    }
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const data = estado.informeGlobalData || {};
    const primerBloque = data.total || {};

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="${NOMBRE_INFORME}"
             data-pagina-index="0" role="main"${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado(primerBloque)}
            <div class="report-body rpt-cmai-mt-standard">
                ${_renderContenido()}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(0, 1, '');
}

function _getHtmlEncabezado(bloque) {
    const linea1 = bloque?.linea1 || 'S.G. Instalaciones y Redes';
    const linea2 = bloque?.linea2 || 'Gerencias';
    return getHtmlEncabezadoBase({
        tituloCorporativo: `<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container">Informe de Contratación</span>`,
        textoBanner1: linea1,
        textoBanner2: linea2,
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: () => _renderContenido(true),
        modoAgrupacion: 'NONE',
        margenes: MARGENES_PROPIOS,
        nombreInforme: NOMBRE_INFORME
    });
}

function _renderContenido(esImpresion = false) {
    const data = estado.informeGlobalData;
    if (!data) return '<div class="rpt-align-center rpt-p-5">Cargando datos...</div>';

    const anio = data.meta?.filtros?.anio || '';
    const mes = data.meta?.filtros?.mes || 1;
    const anioAnterior = anio - 1;
    const mesAnterior = getMesCorto(mes - 1);
    const cartLabel = mesAnterior ? `Cart. (${mesAnterior})` : 'Cart.';

    const bloques = [data.total, data.nacional, data.internacional];
    const tieneDatos = bloques.some(b => b?.grupos?.length > 0);

    if (!tieneDatos) {
        return `
            <div class="${RPT_CLASSES.INFO_ALERT}" role="alert">
                <div class="rpt-info-alert-icon"><i class="fas fa-info-circle" aria-hidden="true"></i></div>
                <h5 class="rpt-info-alert-title">No hay datos disponibles</h5>
                <p class="rpt-info-alert-text">
                    No se encontraron registros para ${getNombreMes(mes)} ${anio}.
                </p>
            </div>`;
    }

    return `
        <div class="rpt-w-100 ${esImpresion ? '' : 'rpt-mb-4'}">
            ${_renderTabla(data.total, anioAnterior, cartLabel)}
            ${_renderTabla(data.nacional, anioAnterior, cartLabel)}
            ${_renderTabla(data.internacional, anioAnterior, cartLabel)}
        </div>
    `;
}

function _renderTabla(bloque, anioAnterior, cartLabel) {
    if (!bloque || !bloque.grupos || bloque.grupos.length === 0) return '';

    const tituloBadge = bloque.tituloBloque || 'Gerencia';
    const filasGrupos = bloque.grupos.map(g => _renderGrupo(g)).join('');

    return `
        <div class="rpt-gni-table-container">
            <table class="rpt-table rpt-gni-layout rpt-mb-0 rpt-w-100">
                <colgroup>
                    <col class="rpt-gni-col-m">
                    <col class="rpt-gni-col-m">
                    <col class="rpt-gni-col-desc">
                    <col class="rpt-gni-col-a">
                    <col class="rpt-gni-col-a">
                    <col class="rpt-gni-col-ip">
                    <col class="rpt-gni-col-v-contr">
                    <col class="rpt-gni-col-v-cart">
                </colgroup>
                <thead>
                    <tr class="rpt-gni-header-row-main rpt-va-bottom">
                        <th colspan="2" class="rpt-align-center">
                            <div class="rpt-text-corporate rpt-gni-group-header rpt-mb-1">Mensual</div>
                        </th>
                        <th class="rpt-align-center rpt-p-0">
                            &nbsp;
                        </th>
                        <th colspan="3" class="rpt-align-center">
                            <div class="rpt-text-corporate rpt-gni-group-header rpt-mb-1">Acumulado</div>
                        </th>
                        <th colspan="2" class="rpt-align-center">
                            <div class="rpt-text-corporate rpt-gni-group-header rpt-mb-1">Var/${anioAnterior}</div>
                        </th>
                    </tr>
                    <tr class="rpt-gni-header-row-sub">
                        <th class="rpt-p-0"><div class="rpt-gni-header-line rpt-align-end rpt-gni-line-union-start">Objet.</div></th>
                        <th class="rpt-p-0"><div class="rpt-gni-header-line rpt-align-end rpt-gni-line-union-end">Contr.</div></th>
                        <th class="rpt-p-0">
                            <div class="rpt-gni-badge">${escapeHtml(tituloBadge)}</div>
                        </th>
                        <th class="rpt-p-0"><div class="rpt-gni-header-line rpt-align-end rpt-gni-line-union-start">Objet.</div></th>
                        <th class="rpt-p-0"><div class="rpt-gni-header-line rpt-align-end rpt-gni-line-union-mid">Contr.</div></th>
                        <th class="rpt-p-0"><div class="rpt-gni-header-line rpt-align-center rpt-gni-line-union-end">Ip</div></th>
                        <th class="rpt-p-0"><div class="rpt-gni-header-line rpt-align-center rpt-gni-line-union-start">Contr.</div></th>
                        <th class="rpt-p-0"><div class="rpt-gni-header-line rpt-align-center rpt-gni-line-union-end">${cartLabel}</div></th>
                    </tr>
                </thead>
                <tbody>
                    ${filasGrupos}
                </tbody>
                <tr class="rpt-spacer-row-totales"><td colspan="8" class="rpt-spacer-cell-totales"></td></tr>
                <tfoot class="rpt-font-bold">
                    ${_renderTotalRow(bloque.totalBloque)}
                </tfoot>
            </table>
        </div>
    `;
}

function _renderTotalRow(totalBloque) {
    const wrapT = (val, align = 'rpt-align-end', extraClass = '') => {
        return `<div class="${align} rpt-gni-total-cell ${extraClass}">${val}</div>`;
    };

    return `
    <tr class="rpt-gni-total-row">
        <td class="rpt-p-0 rpt-va-top" data-label="Objet. Mensual">
            ${wrapT(formatCurrency(totalBloque.objetivoMensual, 0), 'rpt-align-end', 'rpt-gni-line-union-start')}
        </td>
        <td class="rpt-p-0 rpt-va-top" data-label="Contr. Mensual">
            ${wrapT(formatCurrency(totalBloque.contratacionMensual, 0), 'rpt-align-end', 'rpt-gni-line-union-end')}
        </td>
        <td class="rpt-p-0 rpt-va-top" data-label="Gerencia">
            ${wrapT('Total', 'rpt-align-left rpt-font-bold rpt-gni-total-literal')}
        </td>
        <td class="rpt-p-0 rpt-va-top" data-label="Objet. Acum.">
            ${wrapT(formatCurrency(totalBloque.objetivoAnual, 0), 'rpt-align-end', 'rpt-gni-line-union-start')}
        </td>
        <td class="rpt-p-0 rpt-va-top" data-label="Contr. Acum.">
            ${wrapT(formatCurrency(totalBloque.contratacionAcumulada, 0), 'rpt-align-end', 'rpt-gni-line-union-mid')}
        </td>
        <td class="rpt-p-0 rpt-va-top" data-label="IP">
            ${wrapT(formatCurrency(totalBloque.indiceProduccion, 2), 'rpt-align-center', 'rpt-gni-line-union-end')}
        </td>
        <td class="rpt-p-0 rpt-va-top" data-label="Var. Contr.">
            ${wrapT(totalBloque.variacionContratacion || '0%', 'rpt-align-center', 'rpt-gni-line-union-start')}
        </td>
        <td class="rpt-p-0 rpt-va-top" data-label="Var. Cartera">
            ${wrapT(totalBloque.variacionCartera || '0%', 'rpt-align-center', 'rpt-gni-line-union-end')}
        </td>
    </tr>
    `;
}

function _renderGrupo(grupo) {
    // Un grupo con varias gerencias muestra subtotal en negrita + detalle indentado debajo.
    // Un grupo con una sola gerencia cuyo nombre coincide con el grupo se renderiza como fila simple sin negrita.
    const esGrupoConDetalle = grupo.gerencias.length > 1 ||
        (grupo.gerencias.length === 1 && grupo.gerencias[0].actividad !== grupo.nombreGrupo);

    if (!esGrupoConDetalle) {
        // Grupo simple = fila normal sin negrita ni border-top
        const g = grupo.gerencias[0];
        return _construirHtmlFila(g, false);
    }

    // Grupo con sub-gerencias: fila de grupo en negrita + filas de detalle indentadas
    const filasDetalle = grupo.gerencias.map(g => _construirHtmlFila(g, true)).join('');

    return `
        <tr class="rpt-gni-group-header-row">
            <td class="rpt-p-0 rpt-number-cell" data-label="Objet. Mensual">${formatCurrency(grupo.subtotal.objetivoMensual, 0)}</td>
            <td class="rpt-p-0 rpt-number-cell" data-label="Contr. Mensual">${formatCurrency(grupo.subtotal.contratacionMensual, 0)}</td>
            <td class="rpt-p-0 rpt-gni-group-name-cell" data-label="Gerencia">${escapeHtml(grupo.nombreGrupo)}</td>
            <td class="rpt-p-0 rpt-number-cell" data-label="Objet. Acum.">${formatCurrency(grupo.subtotal.objetivoAnual, 0)}</td>
            <td class="rpt-p-0 rpt-number-cell" data-label="Contr. Acum.">${formatCurrency(grupo.subtotal.contratacionAcumulada, 0)}</td>
            <td class="rpt-p-0 rpt-align-center ${getIpClass(grupo.subtotal.indiceProduccion)}" data-label="IP">${formatCurrency(grupo.subtotal.indiceProduccion, 2)}</td>
            <td class="rpt-p-0 rpt-align-center ${getVarClass(grupo.subtotal.variacionContratacion)}" data-label="Var. Contr.">${grupo.subtotal.variacionContratacion || '0%'}</td>
            <td class="rpt-p-0 rpt-align-center ${getVarClass(grupo.subtotal.variacionCartera)}" data-label="Var. Cartera">${grupo.subtotal.variacionCartera || '0%'}</td>
        </tr>
        ${filasDetalle}
    `;
}

function _construirHtmlFila(g, esDetalleGrupo = false) {
    return `
    <tr class="rpt-detail-row rpt-gni-detail-row">
        <td class="rpt-number-cell" data-label="Objet. Mensual">${formatCurrency(g.objetivoMensual, 0)}</td>
        <td class="rpt-number-cell" data-label="Contr. Mensual">${formatCurrency(g.contratacionMensual, 0)}</td>
        <td class="${esDetalleGrupo ? 'rpt-gni-detail-indented' : 'rpt-ps-2'}" data-label="Gerencia">${escapeHtml(g.actividad)}</td>
        <td class="rpt-number-cell" data-label="Objet. Acum.">${formatCurrency(g.objetivoAnual, 0)}</td>
        <td class="rpt-number-cell" data-label="Contr. Acum.">${formatCurrency(g.contratacionAcumulada, 0)}</td>
        <td class="rpt-align-center ${getIpClass(g.indiceProduccion)}" data-label="IP">
            ${formatCurrency(g.indiceProduccion, 2)}
        </td>
        <td class="rpt-align-center ${getVarClass(g.variacionContratacion)}" data-label="Var. Contr.">
            ${g.variacionContratacion || '0%'}
        </td>
        <td class="rpt-align-center ${getVarClass(g.variacionCartera)}" data-label="Var. Cartera">
            ${g.variacionCartera || '0%'}
        </td>
    </tr>
    `;
}
