/**
 * Informe "DG - Unidades Negocio - Mercado" (SDG 221).
 * Sábana única con 2 bloques:
 *   1. Resumen por Mercado (Nacional/Internacional) + Total Global.
 *   2. Detalle por Dirección de Negocio (banner intercalado por DN).
 */
import { RPT_CLASSES, formatCurrency, getIpClass, getVarClass,
         actualizarEstadoPaginacion, inicializarEventListenersBase }
    from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase,
         imprimirInformeUnificado, getStyleVars, MARGENES_ESTANDAR }
    from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

export async function ejecutar({ anio, mes, nroPagina, codSubDir, mostrarTitulo }) {
    try {
        const url = `/api/ContratacionMercadosSDGDN?anio=${anio}&mes=${mes}&subdireccion=${codSubDir || ''}&_=${Date.now()}`;

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
            margenes: MARGENES_ESTANDAR
        });
    } catch (error) {
        console.error("Error al ejecutar informe Contratacion Mercados SDG DN:", error);
        throw error;
    }
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="contratacion_mercados_sdg_dn"
             data-pagina-index="0" role="main"${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body rpt-cmai-mt-standard">
                ${_renderContenidoCompleto()}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(0, 1, '');
}

function _getHtmlEncabezado() {
    const subdireccion = estado.informeGlobalData?.meta?.filtros?.subdireccion;
    const bannerText = subdireccion === '286' ? 'DG. Elecnor Proyectos' : 'DG. Elecnor Servicios';

    return getHtmlEncabezadoBase({
        // Span vacio: el botón Index define data-mostrar-titulo="false" para no mostrar el titulo.
        tituloCorporativo: '<span class="rpt-d-none">Consejo Elecnor</span>',
        textoBanner1: bannerText,
        textoBanner2: 'Mercados',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

// ═══════════════════════════════════════════════════════════════
// RENDERIZADO
// ═══════════════════════════════════════════════════════════════

function _renderContenidoCompleto() {
    const data = estado.informeGlobalData;
    if (!data) return '';

    return `
        <div class="rpt-w-100 rpt-mb-4">
            ${_renderBloqueResumen(data.resumenPorMercado, data.totalGlobal)}
            ${_renderBloqueDetalle(data.detallesPorDN)}
        </div>
    `;
}

/**
 * <colgroup> + <thead> con la rejilla de 10 columnas.
 * mostrarUmbral=true  -> columna Var/{anio-1} (gris) en el resumen.
 * mostrarUmbral=false -> columna Contr. adicional (bloque detalle DN).
 */
function _renderCabeceraColumnas(bannerCentral, mostrarUmbral = true) {
    const anioAnterior = estado.informeGlobalData.meta.filtros.anio - 1;

    return `
        <colgroup>
            <col class="rpt-cmsdg-col-obj-m">
            <col class="rpt-cmsdg-col-contr-m">
            <col class="rpt-cmsdg-col-spacer-1">
            <col class="rpt-cmsdg-col-mercado">
            <col class="rpt-cmsdg-col-spacer-2">
            <col class="rpt-cmsdg-col-obj-a">
            ${mostrarUmbral ? '<col class="rpt-cmsdg-col-var-u">' : '<col class="rpt-cmsdg-col-contr-a">'}
            ${mostrarUmbral ? '<col class="rpt-cmsdg-col-contr-a">' : '<col class="rpt-cmsdg-col-ip">'}
            <col class="rpt-cmsdg-col-ip">
            <col class="rpt-cmsdg-col-var-r">
        </colgroup>
        <thead>
            <tr class="rpt-cmsdg-superheader-row">
                <th colspan="2" class="rpt-align-center rpt-fs-8pt rpt-text-corporate">Mensual</th>
                <th class="rpt-cmsdg-spacer-cell-col"></th>
                <th></th>
                <th class="rpt-cmsdg-spacer-cell-col"></th>
                <th colspan="4" class="rpt-align-center rpt-fs-8pt rpt-text-corporate">Acumulado</th>
            </tr>
            <tr class="rpt-cmsdg-column-headers-row">
                <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Objet.</th>
                <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Contr.</th>
                <th class="rpt-cmsdg-spacer-cell-col"></th>
                <th class="rpt-align-start rpt-text-white rpt-cmsdg-header-banner-cell">
                    <div class="rpt-mercado-header-badge">${bannerCentral}</div>
                </th>
                <th class="rpt-cmsdg-spacer-cell-col"></th>
                <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Objet.</th>
                ${mostrarUmbral
                    ? `<th class="rpt-align-end rpt-fs-8pt rpt-cmsdg-col-umbral-cell">Var/${anioAnterior}</th>
                       <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Contr.</th>`
                    : `<th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Contr.</th>
                       <th></th>`}
                <th class="rpt-align-center rpt-fs-8pt rpt-text-corporate">Ip</th>
                <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Var/${anioAnterior}</th>
            </tr>
        </thead>
    `;
}

/** Bloque 1: Resumen por Mercado + Total Global. */
function _renderBloqueResumen(resumenes, totalGlobal) {
    if (!resumenes || resumenes.length === 0) return '';

    const subdireccion = estado.informeGlobalData?.meta?.filtros?.subdireccion;
    const bannerText = subdireccion === '286' ? 'DG. Elecnor Proyectos' : 'DG. Elecnor Servicios';

    return `
    <div class="rpt-cmsdg-table-container rpt-mt-2 rpt-mb-4">
        <table class="rpt-table rpt-cmsdg-tabla rpt-w-100">
            ${_renderCabeceraColumnas(bannerText, true)}
            <tbody>
                ${resumenes.map(r => _renderFilaResumen(r)).join('')}
            </tbody>
            <tr class="rpt-spacer-row-totales"><td colspan="10" class="rpt-spacer-cell-totales"></td></tr>
            <tfoot class="rpt-font-bold">
                ${_renderFilaTotalGlobal(totalGlobal)}
            </tfoot>
        </table>
    </div>`;
}

function _renderFilaResumen(r) {
    const ipClass = getIpClass(r.ip);
    const varClass = getVarClass(r.variacionContratacion);
    return `
    <tr class="rpt-detail-row rpt-cmsdg-detail-row">
        <td class="rpt-number-cell" data-label="Objet. Mensual">${formatCurrency(r.objetivoMensual, 0)}</td>
        <td class="rpt-number-cell" data-label="Contr. Mensual">${formatCurrency(r.contratacionMensual, 0)}</td>
        <td class="rpt-cmsdg-spacer-cell-col"></td>
        <td class="rpt-cmsdg-col-mercado-cell" data-label="Mercado">${r.pais}</td>
        <td class="rpt-cmsdg-spacer-cell-col"></td>
        <td class="rpt-number-cell" data-label="Objet. Anual">${formatCurrency(r.objetivoAnual, 0)}</td>
        <td class="rpt-number-cell rpt-cmsdg-col-umbral-cell" data-label="Var. Umbral">${r.umbralTexto}</td>
        <td class="rpt-number-cell" data-label="Contr. Acum.">${formatCurrency(r.contratacionAcumulado, 0)}</td>
        <td class="rpt-number-cell rpt-align-center ${ipClass}" data-label="IP">${formatCurrency(r.ip, 2)}</td>
        <td class="rpt-align-end ${varClass}" data-label="Var. %">${r.variacionContratacion}</td>
    </tr>`;
}

function _renderFilaTotalGlobal(t) {
    const ipClass = getIpClass(t.ip);
    const varClass = getVarClass(t.variacionContratacion);
    const subdir = estado.informeGlobalData?.meta?.filtros?.subdireccion;
    const totalUmbralText = subdir === '286' ? '-17%' : '-6%';

    return `
    <tr class="rpt-cmsdg-total-row rpt-font-bold rpt-text-corporate">
        <td class="rpt-number-cell rpt-td-total" data-label="Total Obj. Mensual">${formatCurrency(t.objetivoMensual, 0)}</td>
        <td class="rpt-number-cell rpt-td-total" data-label="Total Contr. Mensual">${formatCurrency(t.contratacionMensual, 0)}</td>
        <td class="rpt-cmsdg-spacer-cell-col"></td>
        <td class="rpt-td-total rpt-align-center" data-label="Total Label">&nbsp;</td>
        <td class="rpt-cmsdg-spacer-cell-col"></td>
        <td class="rpt-number-cell rpt-td-total" data-label="Total Obj. Anual">${formatCurrency(t.objetivoAnual, 0)}</td>
        <td class="rpt-number-cell rpt-td-total rpt-cmsdg-col-umbral-cell" data-label="Total Var. Umbral">${totalUmbralText}</td>
        <td class="rpt-number-cell rpt-td-total" data-label="Total Contr. Acum.">${formatCurrency(t.contratacionAcumulado, 0)}</td>
        <td class="rpt-number-cell rpt-align-center ${ipClass} rpt-td-total" data-label="Total IP">${formatCurrency(t.ip, 2)}</td>
        <td class="rpt-align-end ${varClass} rpt-td-total" data-label="Total Var. %">${t.variacionContratacion}</td>
    </tr>`;
}

function _renderBloqueDetalle(detalles) {
    if (!detalles || detalles.length === 0) return '';

    const htmlRows = [];
    let dnActual = '';

    for (let i = 0; i < detalles.length; i++) {
        const d = detalles[i];

        if (d.nombreDirNegocio !== dnActual) {
            dnActual = d.nombreDirNegocio;

            // Fila espaciadora entre bloques de DN (omitida en la primera).
            if (htmlRows.length > 0) {
                htmlRows.push(`
                    <tr class="rpt-cmsdg-spacer-row-dn">
                        <td colspan="9" class="rpt-cmsdg-spacer-cell-dn"></td>
                    </tr>
                `);
            }

            // Cabecera intercalada con el nombre de la DN como banner central.
            htmlRows.push(`
                <tr class="rpt-cmsdg-dn-header-row">
                    <td class="rpt-cmsdg-dn-header-side rpt-align-end">Objet.</td>
                    <td class="rpt-cmsdg-dn-header-side rpt-align-end">Contr.</td>
                    <td class="rpt-cmsdg-spacer-cell-col"></td>
                    <td class="rpt-align-start rpt-text-white">
                        <div class="rpt-mercado-header-badge">${d.nombreDirNegocio}</div>
                    </td>
                    <td class="rpt-cmsdg-spacer-cell-col"></td>
                    <td class="rpt-cmsdg-dn-header-side rpt-align-end">Objet.</td>
                    <td class="rpt-cmsdg-dn-header-side rpt-align-end">Contr.</td>
                    <td class="rpt-cmsdg-dn-header-side rpt-align-center">Ip</td>
                    <td class="rpt-cmsdg-dn-header-side rpt-align-end">Var/${(estado.informeGlobalData.meta.filtros.anio - 1)}</td>
                </tr>
            `);
        }

        if (d.esSubtotal) {
            // Fila de Subtotal de Dirección de Negocio.
            const ipClass = getIpClass(d.ip);
            const varClass = getVarClass(d.variacionContratacion);
            htmlRows.push(`
                <tr class="rpt-cmsdg-subtotal-row rpt-font-bold">
                    <td class="rpt-number-cell rpt-td-subtotal">${formatCurrency(d.objetivoMensual, 0)}</td>
                    <td class="rpt-number-cell rpt-td-subtotal">${formatCurrency(d.contratacionMensual, 0)}</td>
                    <td class="rpt-cmsdg-spacer-cell-col"></td>
                    <td class="rpt-td-subtotal-spacer"></td>
                    <td class="rpt-cmsdg-spacer-cell-col"></td>
                    <td class="rpt-number-cell rpt-td-subtotal">${formatCurrency(d.objetivoAnual, 0)}</td>
                    <td class="rpt-number-cell rpt-td-subtotal">${formatCurrency(d.contratacionAcumulado, 0)}</td>
                    <td class="rpt-number-cell rpt-align-center ${ipClass} rpt-td-subtotal">${formatCurrency(d.ip, 2)}</td>
                    <td class="rpt-align-end ${varClass} rpt-td-subtotal">${d.variacionContratacion}</td>
                </tr>
            `);
        } else {
            // Fila de detalle (Nacional / Internacional).
            const ipClass = getIpClass(d.ip);
            const varClass = getVarClass(d.variacionContratacion);
            const sup = d.superaUmbral ? ' rpt-cmsdg-row-supera-umbral' : '';
            htmlRows.push(`
                <tr class="rpt-detail-row rpt-cmsdg-detail-row${sup}">
                    <td class="rpt-number-cell" data-label="Objet. Mensual">${formatCurrency(d.objetivoMensual, 0)}</td>
                    <td class="rpt-number-cell" data-label="Contr. Mensual">${formatCurrency(d.contratacionMensual, 0)}</td>
                    <td class="rpt-cmsdg-spacer-cell-col"></td>
                    <td class="rpt-cmsdg-col-mercado-cell" data-label="Mercado">${d.pais}</td>
                    <td class="rpt-cmsdg-spacer-cell-col"></td>
                    <td class="rpt-number-cell" data-label="Objet. Anual">${formatCurrency(d.objetivoAnual, 0)}</td>
                    <td class="rpt-number-cell" data-label="Contr. Acum.">${formatCurrency(d.contratacionAcumulado, 0)}</td>
                    <td class="rpt-number-cell rpt-align-center ${ipClass}" data-label="IP">${formatCurrency(d.ip, 2)}</td>
                    <td class="rpt-align-end ${varClass}" data-label="Var. %">${d.variacionContratacion}</td>
                </tr>
            `);
        }
    }

    return `
    <div class="rpt-cmsdg-subinforme-wrap">
        <div class="rpt-cmsdg-table-container-last rpt-mb-2">
            <table class="rpt-table rpt-cmsdg-tabla rpt-w-100">
                <colgroup>
                    <col class="rpt-cmsdg-col-obj-m">
                    <col class="rpt-cmsdg-col-contr-m">
                    <col class="rpt-cmsdg-col-spacer-1">
                    <col class="rpt-cmsdg-col-mercado">
                    <col class="rpt-cmsdg-col-spacer-2">
                    <col class="rpt-cmsdg-col-obj-a">
                    <col class="rpt-cmsdg-col-contr-a">
                    <col class="rpt-cmsdg-col-ip">
                    <col class="rpt-cmsdg-col-var-r">
                </colgroup>
                <tbody>
                    ${htmlRows.join('')}
                </tbody>
            </table>
        </div>
    </div>`;
}

// ═══════════════════════════════════════════════════════════════
// EVENTOS
// ═══════════════════════════════════════════════════════════════

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        renderContenido: () => _renderContenidoCompleto(),
        modoAgrupacion: 'NONE',
        margenes: estado.margenes,
        nombreInforme: 'contratacion_mercados_sdg_dn'
    });
}
