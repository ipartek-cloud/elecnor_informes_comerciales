/**
 * Módulo para el informe Gerencias (Detalle) x DN x Delegaciones.
 * Jerarquía: Orden → Gerente(+Mercado) → DN → Centro con subtotales.
 * Patrón A: sábana única sin paginación real.
 * Benchmark: gerencias_nacional_internacional.js (mismo SP, mismo Patrón A).
 */
import {
    RPT_CLASSES, formatCurrency, escapeHtml,
    getIpClass, getVarClass, getNombreMes, getMesCorto,
    actualizarEstadoPaginacion, inicializarEventListenersBase
} from './utils.js';
import {
    crearEstadoInforme, inicializarInforme,
    getHtmlEncabezadoBase, imprimirInformeUnificado,
    getStyleVars, MARGENES_ESTANDAR
} from './informes_unificados_utils.js';

const estado = crearEstadoInforme();
const NOMBRE_INFORME = 'gerencias_totales_cruces';

const MARGENES_PROPIOS = {
    web: '6mm 10mm',
    pdf: '6mm 10mm',
    maxWidth: '1050px'
};

export async function ejecutar({ anio, mes, nroPagina, mostrarTitulo, codSubDir, isPdf }) {
    try {
        const sdg = codSubDir || '221';
        let url = `/api/GerenciasTotalesCruces?anio=${anio}&mes=${mes}&codSubDirGeneral=${sdg}`;
        if (nroPagina) url += `&nroPagina=${nroPagina}`;
        url += `&_=${Date.now()}`;

        estado.isPdf = isPdf;
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
        console.error('Error al ejecutar Gerencias Totales Cruces:', error);
        throw error;
    }
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const data = estado.informeGlobalData || {};

    if (estado.isPdf) {
        const styleVars = getStyleVars(estado.margenes);
        container.innerHTML = `
            <div class="${RPT_CLASSES.PAPER} rpt-paper--print rpt-paper--${NOMBRE_INFORME}" data-informe="${NOMBRE_INFORME}"${styleVars}>
                <table class="rpt-print-outer-table">
                    <thead>
                        <tr>
                            <td class="rpt-print-td-header">
                                ${_getHtmlEncabezado()}
                            </td>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="rpt-print-td-body">
                                <div class="report-body rpt-cmai-mt-standard">
                                    ${_renderContenido(true)}
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        `;
    } else {
        container.innerHTML = `
            <div class="${RPT_CLASSES.PAPER}" data-informe="${NOMBRE_INFORME}"
                 data-pagina-index="0" role="main"${getStyleVars(estado.margenes)}>
                ${_getHtmlEncabezado()}
                <div class="report-body rpt-cmai-mt-standard">
                    ${_renderContenido()}
                </div>
            </div>
        `;
    }

    container.scrollTop = 0;
    actualizarEstadoPaginacion(0, 1, '');
}

function _getHtmlEncabezado() {
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    return getHtmlEncabezadoBase({
        tituloCorporativo: `<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container rpt-d-none">Consejo Elecnor</span> <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>`,
        textoBanner1: 'Elecnor',
        textoBanner2: 'Gerencias',
        mes: filtros.mes,
        anio: filtros.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

function _renderContenido(esImpresion = false) {
    const data = estado.informeGlobalData;
    if (!data || !data.gruposOrden || data.gruposOrden.length === 0) {
        return `
            <div class="${RPT_CLASSES.INFO_ALERT}" role="alert">
                <div class="rpt-info-alert-icon"><i class="fas fa-info-circle" aria-hidden="true"></i></div>
                <h5 class="rpt-info-alert-title">No hay datos disponibles</h5>
                <p class="rpt-info-alert-text">
                    No se encontraron registros para ${getNombreMes(data?.meta?.filtros?.mes || 1)} ${data?.meta?.filtros?.anio || ''}.
                </p>
            </div>`;
    }

    const anio = data.meta?.filtros?.anio || '';
    const anioAnterior = anio - 1;
    const mes = data.meta?.filtros?.mes || 1;
    const mesAnterior = getMesCorto(mes - 1);
    const cartLabel = mesAnterior ? `Cart.(${mesAnterior})` : 'Cart.'; // Quitar espacio antes del paréntesis para coincidir con mercados

    let htmlGrupos = '';
    if (esImpresion) {
        // En impresión, aplanamos a nivel de Gerente para que cada Gerente empiece en su propia página
        const todasGerencias = [];
        data.gruposOrden.forEach(grupo => {
            grupo.gerencias.forEach(ger => todasGerencias.push(ger));
        });

        htmlGrupos = todasGerencias.map((ger, idx) => {
            const htmlGer = _renderGerencia(ger, anioAnterior, cartLabel);
            return idx < todasGerencias.length - 1
                ? `${htmlGer}<div class="rpt-page-break"></div>`
                : htmlGer;
        }).join('');
    } else {
        htmlGrupos = data.gruposOrden.map(grupoOrden =>
            _renderGrupoOrden(grupoOrden, anioAnterior, cartLabel)
        ).join('');
    }

    return `
        <div class="rpt-w-100 ${esImpresion ? '' : 'rpt-mb-4'}">
            ${htmlGrupos}
        </div>
    `;
}

function _renderGrupoOrden(grupoOrden, anioAnterior, cartLabel) {
    const htmlGerencias = grupoOrden.gerencias.map(ger =>
        _renderGerencia(ger, anioAnterior, cartLabel)
    ).join('');

    return htmlGerencias;
}

function _renderGerencia(ger, anioAnterior, cartLabel) {
    const titleHtml = `<div class="rpt-gtc-sdg-titulo">${escapeHtml(ger.nombreGerente)}</div>`;

    const htmlBloquesDN = ger.bloquesDN.map((bloque, idx) => {
        const isLastDN = (idx === ger.bloquesDN.length - 1);
        return _renderBloqueDN(bloque, anioAnterior, cartLabel, isLastDN ? ger.totalGerencia : null);
    }).join('');

    return titleHtml + htmlBloquesDN;
}

function _renderCabecerasColumnas(nombreDirNegocio, cartLabel) {
    return `
        <tr class="rpt-gtc-header-row-main rpt-va-bottom">
            <th colspan="2" class="rpt-align-center">
                <div class="rpt-text-corporate rpt-gtc-group-header rpt-mb-1">Mensual</div>
            </th>
            <th class="rpt-gtc-col-sep"></th> <!-- Sep 1 -->
            <th class="rpt-align-center rpt-p-0">&nbsp;</th>
            <th class="rpt-gtc-col-sep"></th> <!-- Sep 2 -->
            <th colspan="3" class="rpt-align-center">
                <div class="rpt-text-corporate rpt-gtc-group-header rpt-mb-1">Acumulado</div>
            </th>
            <th></th> <!-- Spacer -->
            <th colspan="2" class="rpt-align-center">
                <div class="rpt-text-corporate rpt-gtc-group-header rpt-mb-1">Var/${estado.informeGlobalData?.meta?.filtros?.anio - 1}</div>
            </th>
        </tr>
        <tr class="rpt-gtc-header-row-sub">
            <th class="rpt-gtc-th-num rpt-text-corporate rpt-fs-8pt">Objet.</th>
            <th class="rpt-gtc-th-num rpt-text-corporate rpt-fs-8pt">Contr.</th>
            <th class="rpt-gtc-col-sep"></th> <!-- Sep 1 -->
            <th class="rpt-gtc-header-center-name">${escapeHtml(nombreDirNegocio)}</th>
            <th class="rpt-gtc-col-sep"></th> <!-- Sep 2 -->
            <th class="rpt-gtc-th-num rpt-text-corporate rpt-fs-8pt">Objet.</th>
            <th class="rpt-gtc-th-num rpt-text-corporate rpt-fs-8pt">Contr.</th>
            <th class="rpt-align-center rpt-text-corporate rpt-fs-8pt">Ip</th>
            <th></th> <!-- Spacer -->
            <th class="rpt-gtc-th-num rpt-text-corporate rpt-fs-8pt">Contr.</th>
            <th class="rpt-gtc-th-num rpt-text-corporate rpt-fs-8pt">${cartLabel || 'Cart.'}</th>
        </tr>
        <tr class="rpt-gtc-header-line-row">
            <th class="rpt-gtc-header-line" colspan="2"></th>
            <th class="rpt-gtc-col-sep"></th> <!-- Sep 1 -->
            <th class="rpt-gtc-total-no-border"></th> <!-- Centro vacío -->
            <th class="rpt-gtc-col-sep"></th> <!-- Sep 2 -->
            <th class="rpt-gtc-header-line" colspan="3"></th>
            <th></th> <!-- Spacer sin línea -->
            <th class="rpt-gtc-header-line" colspan="2"></th>
        </tr>
    `;
}

function _renderBloqueDN(bloque, anioAnterior, cartLabel, totalGerencia) {
    const cabeceras = _renderCabecerasColumnas(bloque.nombreDirNegocio, cartLabel);

    const filasCentros = bloque.centros.map(c => _renderFilaCentro(c)).join('');

    const notaDN800 = bloque.mostrarNotaDN800
        ? `<tr class="rpt-gtc-note-row"><td colspan="11" class="rpt-gtc-note-cell"><em>(*) Incluye 20.000 de internacional</em></td></tr>`
        : '';

    const subtotalDN = _renderSubtotalDN(bloque.totalDN);
    const subtotalGerente = totalGerencia ? _renderSubtotalGerente(totalGerencia) : '';

    return `
        <div class="rpt-gtc-table-container">
            <table class="rpt-table rpt-gtc-layout rpt-w-100">
                <colgroup>
                    <col class="rpt-gtc-col-obj-m">
                    <col class="rpt-gtc-col-contr-m">
                    <col class="rpt-gtc-col-sep">
                    <col class="rpt-gtc-col-centro">
                    <col class="rpt-gtc-col-sep">
                    <col class="rpt-gtc-col-obj-a">
                    <col class="rpt-gtc-col-contr-a">
                    <col class="rpt-gtc-col-ip">
                    <col class="rpt-gtc-col-spacer">
                    <col class="rpt-gtc-col-var-contr">
                    <col class="rpt-gtc-col-var-cart">
                </colgroup>
                <thead>
                    ${cabeceras}
                </thead>
                <tbody>
                    ${filasCentros}
                    ${notaDN800}
                    ${subtotalDN}
                    ${subtotalGerente}
                </tbody>
            </table>
        </div>
    `;
}

function _renderFilaCentro(c) {
    return `
    <tr class="rpt-detail-row rpt-gtc-detail-row">
        <td class="rpt-number-cell" data-label="Objet. Mensual">${formatCurrency(c.objetivoMensual, 0)}</td>
        <td class="rpt-number-cell" data-label="Contr. Mensual">${formatCurrency(c.contratacionMensual, 0)}</td>
        <td class="rpt-gtc-col-sep"></td> <!-- Sep 1 -->
        <td class="rpt-gtc-cell-centro" data-label="Centro">
            <span class="rpt-gtc-cod-centro">${escapeHtml(c.codCentro)}</span>
            <span class="rpt-gtc-nombre-centro">${escapeHtml(c.nombreCentro)}</span>
        </td>
        <td class="rpt-gtc-col-sep"></td> <!-- Sep 2 -->
        <td class="rpt-number-cell" data-label="Objet. Acum.">${formatCurrency(c.objetivoAnual, 0)}</td>
        <td class="rpt-number-cell" data-label="Contr. Acum.">${formatCurrency(c.contratacionAcumulada, 0)}</td>
        <td class="rpt-align-center ${getIpClass(c.indiceProduccion)}"
            role="img" aria-label="Índice de producción: ${c.indiceProduccion}"
            data-label="IP">${formatCurrency(c.indiceProduccion, 2)}</td>
        <td class="rpt-gtc-col-spacer"></td> <!-- Spacer -->
        <td class="rpt-number-cell ${getVarClass(c.variacionContratacion)}"
            role="img" aria-label="Variación porcentual: ${c.variacionContratacion}"
            data-label="Var. Contr.">${c.variacionContratacion || '0%'}</td>
        <td class="rpt-number-cell ${getVarClass(c.variacionCartera)}"
            role="img" aria-label="Variación de cartera: ${c.variacionCartera}"
            data-label="Var. Cart.">${c.variacionCartera || '0%'}</td>
    </tr>
    `;
}

function _renderSubtotalDN(total) {
    return `
    <tr class="rpt-gtc-subtotal-dn-row">
        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Objet. Mensual">${formatCurrency(total.objetivoMensual, 0)}</td>
        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Contr. Mensual">${formatCurrency(total.contratacionMensual, 0)}</td>
        <td class="rpt-gtc-col-sep"></td> <!-- Sep 1 -->
        <td class="rpt-p-0 rpt-gtc-subtotal-label rpt-gtc-total-border-top" data-label="DN">&nbsp;</td>
        <td class="rpt-gtc-col-sep"></td> <!-- Sep 2 -->
        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Objet. Acum.">${formatCurrency(total.objetivoAnual, 0)}</td>
        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Contr. Acum.">${formatCurrency(total.contratacionAcumulada, 0)}</td>
        <td class="rpt-p-0 rpt-align-center rpt-td-total ${getIpClass(total.indiceProduccion)}" data-label="IP">${formatCurrency(total.indiceProduccion, 2)}</td>
        <td class="rpt-gtc-col-spacer"></td> <!-- Spacer -->
        <td class="rpt-p-0 rpt-number-cell rpt-td-total ${getVarClass(total.variacionContratacion)}" data-label="Var. Contr.">${total.variacionContratacion || '0%'}</td>
        <td class="rpt-p-0 rpt-number-cell rpt-td-total ${getVarClass(total.variacionCartera)}" data-label="Var. Cart.">${total.variacionCartera || '0%'}</td>
    </tr>
    `;
}

function _renderSubtotalGerente(total) {
    return `
    <tr class="rpt-gtc-subtotal-gerente-row">
        <td class="rpt-p-0 rpt-number-cell" data-label="Objet. Mensual">${formatCurrency(total.objetivoMensual, 0)}</td>
        <td class="rpt-p-0 rpt-number-cell" data-label="Contr. Mensual">${formatCurrency(total.contratacionMensual, 0)}</td>
        <td class="rpt-gtc-col-sep"></td> <!-- Sep 1 -->
        <td class="rpt-p-0 rpt-gtc-subtotal-gerente-label" data-label="Gerente">Total</td>
        <td class="rpt-gtc-col-sep"></td> <!-- Sep 2 -->
        <td class="rpt-p-0 rpt-number-cell" data-label="Objet. Acum.">${formatCurrency(total.objetivoAnual, 0)}</td>
        <td class="rpt-p-0 rpt-number-cell" data-label="Contr. Acum.">${formatCurrency(total.contratacionAcumulada, 0)}</td>
        <td class="rpt-p-0 rpt-align-center ${getIpClass(total.indiceProduccion)}" data-label="IP">${formatCurrency(total.indiceProduccion, 2)}</td>
        <td class="rpt-gtc-col-spacer"></td> <!-- Spacer -->
        <td class="rpt-p-0 rpt-number-cell ${getVarClass(total.variacionContratacion)}" data-label="Var. Contr.">${total.variacionContratacion || '0%'}</td>
        <td class="rpt-p-0 rpt-number-cell ${getVarClass(total.variacionCartera)}" data-label="Var. Cart.">${total.variacionCartera || '0%'}</td>
    </tr>
    `;
}

function _renderTotalGeneral(total, anioAnterior, cartLabel) {
    if (!total || (total.objetivoAnual === 0 && total.contratacionAcumulada === 0)) return '';

    return `
        <div class="rpt-gtc-table-container rpt-gtc-total-general-container">
            <table class="rpt-table rpt-gtc-layout rpt-w-100">
                <colgroup>
                    <col class="rpt-gtc-col-obj-m">
                    <col class="rpt-gtc-col-contr-m">
                    <col class="rpt-gtc-col-sep">
                    <col class="rpt-gtc-col-centro">
                    <col class="rpt-gtc-col-sep">
                    <col class="rpt-gtc-col-obj-a">
                    <col class="rpt-gtc-col-contr-a">
                    <col class="rpt-gtc-col-ip">
                    <col class="rpt-gtc-col-spacer">
                    <col class="rpt-gtc-col-var-contr">
                    <col class="rpt-gtc-col-var-cart">
                </colgroup>
                <tfoot class="rpt-font-bold">
                    <tr class="rpt-gtc-total-general-row">
                        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Objet. Mensual">${formatCurrency(total.objetivoMensual, 0)}</td>
                        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Contr. Mensual">${formatCurrency(total.contratacionMensual, 0)}</td>
                        <td class="rpt-gtc-col-sep"></td> <!-- Sep 1 -->
                        <td class="rpt-p-0 rpt-gtc-total-general-label rpt-gtc-total-border-top" data-label="Total">&nbsp;</td>
                        <td class="rpt-gtc-col-sep"></td> <!-- Sep 2 -->
                        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Objet. Acum.">${formatCurrency(total.objetivoAnual, 0)}</td>
                        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Contr. Acum.">${formatCurrency(total.contratacionAcumulada, 0)}</td>
                        <td class="rpt-p-0 rpt-align-center rpt-td-total ${getIpClass(total.indiceProduccion)}" data-label="IP">${formatCurrency(total.indiceProduccion, 2)}</td>
                        <td class="rpt-gtc-col-spacer"></td> <!-- Spacer -->
                        <td class="rpt-p-0 rpt-number-cell rpt-td-total ${getVarClass(total.variacionContratacion)}" data-label="Var. Contr.">${total.variacionContratacion || '0%'}</td>
                        <td class="rpt-p-0 rpt-number-cell rpt-td-total ${getVarClass(total.variacionCartera)}" data-label="Var. Cart.">${total.variacionCartera || '0%'}</td>
                    </tr>
                </tfoot>
            </table>
        </div>
    `;
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    const styleVars = getStyleVars(MARGENES_PROPIOS);
    
    // Crear capa de impresión manual para usar la técnica de Outer Table
    const capaPrint = document.createElement('div');
    capaPrint.className = 'rpt-print-layer';
    
    // La Outer Table permite que el thead se repita en cada página física del PDF
    const html = `
        <div class="rpt-paper rpt-paper--print rpt-paper--${NOMBRE_INFORME}" data-informe="${NOMBRE_INFORME}"${styleVars}>
            <table class="rpt-print-outer-table">
                <thead>
                    <tr>
                        <td class="rpt-print-td-header">
                            ${_getHtmlEncabezado()}
                        </td>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="rpt-print-td-body">
                            <div class="report-body rpt-cmai-mt-standard">
                                ${_renderContenido(true)}
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    `;
    
    capaPrint.innerHTML = html;
    document.body.appendChild(capaPrint);

    try {
        await new Promise(resolve => setTimeout(resolve, 250));
        window.print();
    } finally {
        if (document.body.contains(capaPrint)) {
            document.body.removeChild(capaPrint);
        }
    }
}
