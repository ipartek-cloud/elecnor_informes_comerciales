/**
 * Módulo para el informe Gerentes Actividad (Gerente × Mercado × DN × Centro).
 * Primer gerente implementado: Electricidad. La arquitectura permite añadir los 10 restantes
 * (Construcción, Fotovoltaica, Gas, etc.) con cambios mínimos.
 *
 * Patrón: Híbrido A + B (sábana única en web + Tabla Maestra con Outer Table en PDF).
 * Benchmark: gerencias_totales_cruces.js (mismo SP, mismo framework).
 *
 * Jerarquía visual (basada en JSON extraído de Access `Gerencias_Totales`):
 *   1. EncabezadoGrupo0: Nombre del Gerente (verde, badge)
 *   2. EncabezadoGrupo2: Cabecera columnas + Cabecera DN (azul corporativo)
 *   3. Detalle: Filas de cada centro
 *   4. PieGrupo2: Subtotal DN (sin etiqueta visible) + Nota DN 800 condicional
 *   5. (Repetir 2-4 para cada DN del mismo Mercado)
 *   6. PieGrupo1: Subtotal "Subtotal Nacional" / "Subtotal Internacional" (azul corporativo)
 *   7. (Repetir 2-6 para el otro Mercado)
 *   8. PieGrupo0: Gran Total "Total Nacional+Internacional" (azul corporativo)
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
const NOMBRE_INFORME = 'gerencias_actividad';

export async function ejecutar({ anio, mes, nroPagina, mostrarTitulo, nombreGerente, isPdf }) {
    try {
        // En modo HTML Portable (offline), los IIFEs de HtmlAssemblerService
        // no propagan filtros específicos del informe (como nombreGerente).
        // Rescatamos el valor del JSON embebido __PORTABLE_DATA__ como fallback.
        if (!nombreGerente && typeof window !== 'undefined' && window.__PORTABLE_DATA__ && window.__PORTABLE_DATA__.data) {
            const dataAny = window.__PORTABLE_DATA__.data;
            const mesKey = dataAny[String(mes)] ? String(mes) : Object.keys(dataAny)[0];
            const datosMes = dataAny[mesKey];
            if (datosMes && datosMes.meta && datosMes.meta.filtros && datosMes.meta.filtros.nombreGerente) {
                nombreGerente = datosMes.meta.filtros.nombreGerente;
            }
        }

        if (!nombreGerente) {
            console.error('gerencias_actividad: nombreGerente es obligatorio (no se recibió del caller ni del __PORTABLE_DATA__)');
            return;
        }

        let url = `/api/GerenciasActividad?anio=${anio}&mes=${mes}&nombreGerente=${encodeURIComponent(nombreGerente)}`;
        if (nroPagina) url += `&nroPagina=${nroPagina}`;
        url += `&_=${Date.now()}`;

        estado.isPdf = isPdf;
        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;
        estado.nombreGerente = nombreGerente;

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
        console.error('Error al ejecutar Gerencias Actividad:', error);
        throw error;
    }
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const data = estado.informeGlobalData || {};

    if (estado.isPdf) {
        // Render para impresión PDF con Tabla Maestra + Outer Table
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
                                    ${_renderContenido()}
                                </div>
                            </td>
                        </tr>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td class="rpt-print-td-footer">
                                &nbsp;
                            </td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        `;
    } else {
        // Render web normal (sábana única)
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

function _renderContenido() {
    const data = estado.informeGlobalData;
    if (!data || !data.gruposGerente || data.gruposGerente.length === 0) {
        return `
            <div class="${RPT_CLASSES.INFO_ALERT}" role="alert">
                <div class="rpt-info-alert-icon"><i class="fas fa-info-circle" aria-hidden="true"></i></div>
                <h5 class="rpt-info-alert-title">No hay datos disponibles</h5>
                <p class="rpt-info-alert-text">
                    No se encontraron registros para ${escapeHtml(data?.meta?.filtros?.nombreGerente || '')} en
                    ${getNombreMes(data?.meta?.filtros?.mes || 1)} ${data?.meta?.filtros?.anio || ''}.
                </p>
            </div>`;
    }

    const anio = data.meta?.filtros?.anio || '';
    const anioAnterior = anio - 1;
    const mes = data.meta?.filtros?.mes || 1;
    const mesAnterior = getMesCorto(mes - 1);
    const cartLabel = mesAnterior ? `Cart.(${mesAnterior})` : 'Cart.';

    const htmlGrupos = data.gruposGerente.map(ger =>
        _renderGrupoGerente(ger, anioAnterior, cartLabel)
    ).join('');

    const granTotal = data.totalGeneral ? _renderGranTotal(data.totalGeneral) : '';

    return `
        <div class="rpt-w-100">
            ${htmlGrupos}
            ${granTotal}
        </div>
    `;
}

function _renderGrupoGerente(ger, anioAnterior, cartLabel) {
    const tituloHtml = `<div class="rpt-ga-gerente-name">${escapeHtml(ger.nombreGerente)}</div>`;

    const htmlMercados = (ger.gruposMercado || []).map(gMer =>
        _renderGrupoMercado(gMer, anioAnterior, cartLabel)
    ).join('');

    return tituloHtml + htmlMercados;
}

function _renderGrupoMercado(gMer, anioAnterior, cartLabel) {
    const htmlBloquesDN = (gMer.direccionesNegocio || []).map(bloque =>
        _renderBloqueDN(bloque, anioAnterior, cartLabel)
    ).join('');

    const subtotalMercado = _renderSubtotalMercado(gMer.totalMercado, gMer.mercado);

    return htmlBloquesDN + subtotalMercado;
}

function _renderBloqueDN(bloque, anioAnterior, cartLabel) {
    const cabeceras = _renderCabecerasColumnas(bloque.nombreDirNegocio, anioAnterior, cartLabel);

    const filasCentros = (bloque.centros || []).map(c => _renderFilaCentro(c)).join('');

    const notaDN800 = bloque.mostrarNotaDN800
        ? `<tr class="rpt-ga-note-dn800-row"><td colspan="11" class="rpt-ga-note-dn800-cell"><em>(*) Incluye 20.000 de internacional</em></td></tr>`
        : '';

    const subtotalDN = _renderSubtotalDN(bloque.totalDN);

    return `
        <div class="rpt-ga-table-container">
            <table class="rpt-table rpt-ga-layout rpt-w-100">
                <colgroup>
                    <col class="rpt-ga-col-obj-m">
                    <col class="rpt-ga-col-contr-m">
                    <col class="rpt-ga-col-sep">
                    <col class="rpt-ga-col-centro">
                    <col class="rpt-ga-col-sep">
                    <col class="rpt-ga-col-obj-a">
                    <col class="rpt-ga-col-contr-a">
                    <col class="rpt-ga-col-ip">
                    <col class="rpt-ga-col-spacer">
                    <col class="rpt-ga-col-var-contr">
                    <col class="rpt-ga-col-var-cart">
                </colgroup>
                <thead>
                    ${cabeceras}
                </thead>
                <tbody>
                    ${filasCentros}
                    ${notaDN800}
                    ${subtotalDN}
                </tbody>
            </table>
        </div>
    `;
}

function _renderCabecerasColumnas(nombreDirNegocio, anioAnterior, cartLabel) {
    return `
        <tr class="rpt-ga-header-row-main rpt-va-bottom">
            <th colspan="2" class="rpt-align-center">
                <div class="rpt-text-corporate rpt-ga-group-header rpt-mb-1">Mensual</div>
            </th>
            <th class="rpt-ga-col-sep"></th>
            <th class="rpt-ga-col-centro-hdr-empty"></th>
            <th class="rpt-ga-col-sep"></th>
            <th colspan="3" class="rpt-align-center">
                <div class="rpt-text-corporate rpt-ga-group-header rpt-mb-1">Acumulado</div>
            </th>
            <th></th>
            <th colspan="2" class="rpt-align-center">
                <div class="rpt-text-corporate rpt-ga-group-header rpt-mb-1">Var/${anioAnterior}</div>
            </th>
        </tr>
        <tr class="rpt-ga-header-row-sub">
            <th class="rpt-ga-th-num rpt-text-corporate rpt-fs-8pt">Objet.</th>
            <th class="rpt-ga-th-num rpt-text-corporate rpt-fs-8pt">Contr.</th>
            <th class="rpt-ga-col-sep"></th>
            <th class="rpt-ga-dn-banner-cell rpt-align-center">
                <div class="rpt-ga-dn-banner-text">${escapeHtml(nombreDirNegocio || '')}</div>
            </th>
            <th class="rpt-ga-col-sep"></th>
            <th class="rpt-ga-th-num rpt-text-corporate rpt-fs-8pt">Objet.</th>
            <th class="rpt-ga-th-num rpt-text-corporate rpt-fs-8pt">Contr.</th>
            <th class="rpt-align-center rpt-text-corporate rpt-fs-8pt">Ip</th>
            <th></th>
            <th class="rpt-ga-th-num rpt-text-corporate rpt-fs-8pt">Contr.</th>
            <th class="rpt-ga-th-num rpt-text-corporate rpt-fs-8pt">${cartLabel || 'Cart.'}</th>
        </tr>
        <tr class="rpt-ga-header-line-row">
            <th class="rpt-ga-header-line" colspan="2"></th>
            <th class="rpt-ga-col-sep"></th>
            <th class="rpt-ga-total-no-border"></th>
            <th class="rpt-ga-col-sep"></th>
            <th class="rpt-ga-header-line" colspan="3"></th>
            <th></th>
            <th class="rpt-ga-header-line" colspan="2"></th>
        </tr>
    `;
}

function _renderFilaCentro(c) {
    return `
    <tr class="rpt-detail-row rpt-ga-detail-row">
        <td class="rpt-number-cell" data-label="Objet. Mensual">${formatCurrency(c.objetivoMensual, 0)}</td>
        <td class="rpt-number-cell" data-label="Contr. Mensual">${formatCurrency(c.contratacionMensual, 0)}</td>
        <td class="rpt-ga-col-sep"></td>
        <td class="rpt-ga-cell-centro" data-label="Centro">
            <span class="rpt-ga-cod-centro">${escapeHtml(c.codCentro)}</span>
            <span class="rpt-ga-nombre-centro">${escapeHtml(c.nombreCentro)}</span>
        </td>
        <td class="rpt-ga-col-sep"></td>
        <td class="rpt-number-cell" data-label="Objet. Acum.">${formatCurrency(c.objetivoAnual, 0)}</td>
        <td class="rpt-number-cell" data-label="Contr. Acum.">${formatCurrency(c.contratacionAcumulada, 0)}</td>
        <td class="rpt-align-center ${getIpClass(c.indiceProduccion)}"
            role="img" aria-label="Índice de producción: ${c.indiceProduccion}"
            data-label="IP">${formatCurrency(c.indiceProduccion, 2)}</td>
        <td class="rpt-ga-col-spacer"></td>
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
    if (!total) return '';
    return `
    <tr class="rpt-ga-subtotal-dn-row">
        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Objet. Mensual">${formatCurrency(total.objetivoMensual, 0)}</td>
        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Contr. Mensual">${formatCurrency(total.contratacionMensual, 0)}</td>
        <td class="rpt-ga-col-sep"></td>
        <td class="rpt-p-0 rpt-ga-subtotal-dn-label rpt-ga-total-border-top" data-label="DN">&nbsp;</td>
        <td class="rpt-ga-col-sep"></td>
        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Objet. Acum.">${formatCurrency(total.objetivoAnual, 0)}</td>
        <td class="rpt-p-0 rpt-number-cell rpt-td-total" data-label="Contr. Acum.">${formatCurrency(total.contratacionAcumulada, 0)}</td>
        <td class="rpt-p-0 rpt-align-center rpt-td-total ${getIpClass(total.indiceProduccion)}" data-label="IP">${formatCurrency(total.indiceProduccion, 2)}</td>
        <td class="rpt-ga-col-spacer"></td>
        <td class="rpt-p-0 rpt-number-cell rpt-td-total ${getVarClass(total.variacionContratacion)}" data-label="Var. Contr.">${total.variacionContratacion || '0%'}</td>
        <td class="rpt-p-0 rpt-number-cell rpt-td-total ${getVarClass(total.variacionCartera)}" data-label="Var. Cart.">${total.variacionCartera || '0%'}</td>
    </tr>
    `;
}

function _renderSubtotalMercado(total, mercado) {
    if (!total) return '';
    return `
    <div class="rpt-ga-table-container rpt-ga-subtotal-mercado-container">
        <table class="rpt-table rpt-ga-layout rpt-w-100">
            <colgroup>
                <col class="rpt-ga-col-obj-m">
                <col class="rpt-ga-col-contr-m">
                <col class="rpt-ga-col-sep">
                <col class="rpt-ga-col-centro">
                <col class="rpt-ga-col-sep">
                <col class="rpt-ga-col-obj-a">
                <col class="rpt-ga-col-contr-a">
                <col class="rpt-ga-col-ip">
                <col class="rpt-ga-col-spacer">
                <col class="rpt-ga-col-var-contr">
                <col class="rpt-ga-col-var-cart">
            </colgroup>
            <tfoot class="rpt-font-bold">
                <tr class="rpt-ga-subtotal-mercado-row">
                    <td class="rpt-p-0 rpt-number-cell" data-label="Objet. Mensual">${formatCurrency(total.objetivoMensual, 0)}</td>
                    <td class="rpt-p-0 rpt-number-cell" data-label="Contr. Mensual">${formatCurrency(total.contratacionMensual, 0)}</td>
                    <td class="rpt-ga-col-sep"></td>
                    <td class="rpt-p-0 rpt-ga-subtotal-mercado-label" data-label="Mercado">Subtotal ${escapeHtml(mercado || '')}</td>
                    <td class="rpt-ga-col-sep"></td>
                    <td class="rpt-p-0 rpt-number-cell" data-label="Objet. Acum.">${formatCurrency(total.objetivoAnual, 0)}</td>
                    <td class="rpt-p-0 rpt-number-cell" data-label="Contr. Acum.">${formatCurrency(total.contratacionAcumulada, 0)}</td>
                    <td class="rpt-p-0 rpt-align-center" data-label="IP">${formatCurrency(total.indiceProduccion, 2)}</td>
                    <td class="rpt-ga-col-spacer"></td>
                    <td class="rpt-p-0 rpt-number-cell" data-label="Var. Contr.">${total.variacionContratacion || '0%'}</td>
                    <td class="rpt-p-0 rpt-number-cell" data-label="Var. Cart.">${total.variacionCartera || '0%'}</td>
                </tr>
            </tfoot>
        </table>
    </div>
    `;
}

function _renderGranTotal(total) {
    if (!total || (total.objetivoAnual === 0 && total.contratacionAcumulada === 0)) return '';

    return `
    <div class="rpt-ga-table-container rpt-ga-gran-total-container">
        <table class="rpt-table rpt-ga-layout rpt-w-100">
            <colgroup>
                <col class="rpt-ga-col-obj-m">
                <col class="rpt-ga-col-contr-m">
                <col class="rpt-ga-col-sep">
                <col class="rpt-ga-col-centro">
                <col class="rpt-ga-col-sep">
                <col class="rpt-ga-col-obj-a">
                <col class="rpt-ga-col-contr-a">
                <col class="rpt-ga-col-ip">
                <col class="rpt-ga-col-spacer">
                <col class="rpt-ga-col-var-contr">
                <col class="rpt-ga-col-var-cart">
            </colgroup>
            <tfoot class="rpt-font-bold">
                <tr class="rpt-ga-gran-total-row">
                    <td class="rpt-p-0 rpt-number-cell" data-label="Objet. Mensual">${formatCurrency(total.objetivoMensual, 0)}</td>
                    <td class="rpt-p-0 rpt-number-cell" data-label="Contr. Mensual">${formatCurrency(total.contratacionMensual, 0)}</td>
                    <td class="rpt-ga-col-sep"></td>
                    <td class="rpt-p-0 rpt-ga-gran-total-label" data-label="Total">Total Nacional+Internacional</td>
                    <td class="rpt-ga-col-sep"></td>
                    <td class="rpt-p-0 rpt-number-cell" data-label="Objet. Acum.">${formatCurrency(total.objetivoAnual, 0)}</td>
                    <td class="rpt-p-0 rpt-number-cell" data-label="Contr. Acum.">${formatCurrency(total.contratacionAcumulada, 0)}</td>
                    <td class="rpt-p-0 rpt-align-center" data-label="IP">${formatCurrency(total.indiceProduccion, 2)}</td>
                    <td class="rpt-ga-col-spacer"></td>
                    <td class="rpt-p-0 rpt-number-cell" data-label="Var. Contr.">${total.variacionContratacion || '0%'}</td>
                    <td class="rpt-p-0 rpt-number-cell" data-label="Var. Cart.">${total.variacionCartera || '0%'}</td>
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
    const styleVars = getStyleVars(MARGENES_ESTANDAR);

    // Crear capa de impresión manual para usar la técnica de Outer Table (Tabla Maestra)
    const capaPrint = document.createElement('div');
    capaPrint.className = 'rpt-print-layer';

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
                                ${_renderContenido()}
                            </div>
                        </td>
                    </tr>
                </tbody>
                <tfoot>
                    <tr>
                        <td class="rpt-print-td-footer">
                            &nbsp;
                        </td>
                    </tr>
                </tfoot>
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
