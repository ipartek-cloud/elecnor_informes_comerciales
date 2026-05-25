import { RPT_CLASSES, formatCurrency, actualizarEstadoPaginacion, inicializarEventListenersBase } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, getStyleVars, imprimirInformeUnificado, MARGENES_ESTANDAR } from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

export async function ejecutar({ anio, mes, nroPagina, mercado, mostrarTitulo }) {
    try {
        let url = `/api/MercadosSGDelegaciones?anio=${anio}&mes=${mes}`;
        if (nroPagina) url += `&nroPagina=${nroPagina}`;
        url += `&_=${Date.now()}`;

        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

        await inicializarInforme({
            url, estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: '',
            claveAgrupacion: 'subDireccionesGenerales',
            margenes: MARGENES_ESTANDAR
        });

        // V-19: Para Sábana Continua (Tipo Internacional), forzamos 1 sola página en la navegación web
        estado.paginasTotales = 1;
        actualizarEstadoPaginacion(0, 1, "Vista Unificada");

    } catch (error) {
        console.error("Error al ejecutar informe Mercados SG Delegaciones:", error);
        throw error;
    }
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;
    
    const data = estado.informeGlobalData;
    if (!data || !data.subDireccionesGenerales) return;

    // Renderizamos TODAS las Subdirecciones una tras otra
    const cuerpoHtml = data.subDireccionesGenerales.map((sdg, idx) => {
        const htmlSDG = _renderSDG(sdg);
        // Añadir salto de página físico para el PDF entre SDGs
        return idx < data.subDireccionesGenerales.length - 1 
            ? `${htmlSDG}<div class="rpt-page-break"></div>` 
            : htmlSDG;
    }).join('');

    container.innerHTML = `
    <div class="${RPT_CLASSES.PAPER}" data-informe="mercados_sg_delegaciones" role="main"${getStyleVars(estado.margenes)}>
        ${_getHtmlEncabezadoBase()}
        <div class="report-body rpt-cmai-mt-standard">${cuerpoHtml}</div>
    </div>`;

    container.scrollTop = 0;
}

function _getHtmlEncabezadoBase() {
    return getHtmlEncabezadoBase({
        tituloCorporativo: '<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container rpt-d-none">Consejo Elecnor</span> <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>',
        textoBanner1: 'Elecnor',
        textoBanner2: 'Direcciones',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

function _renderSDG(sdg) {
    if (!sdg || !sdg.direccionesNegocio) return '';
    
    return sdg.direccionesNegocio.map((dn, idx) => {
        return _renderDN(dn, sdg, idx === 0);
    }).join('');
}

function _renderDN(dn, sdg, isFirstDN) {
    const data = estado.informeGlobalData;
    const anioAnterior = data.meta.filtros.anio - 1;
    const meses = ["Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"];
    const mesAnterior = data.meta.filtros.mes - 1;
    const mesAnteriorLabel = mesAnterior > 0 ? meses[mesAnterior - 1] : anioAnterior;
    const nombreSDG = sdg.nombreSubDirGeneral;

    const titleHtml = isFirstDN ? `<div class="rpt-dg-sdg-titulo">${nombreSDG}</div>` : '';

    const tableHeader = `
    ${titleHtml}
    <table class="rpt-table-delegaciones">
        <colgroup>
            <col class="rpt-dg-col-obj-m"><col class="rpt-dg-col-contr-m">
            <col class="rpt-dg-col-sep"> <!-- Separador 1 -->
            <col class="rpt-dg-col-centro">
            <col class="rpt-dg-col-sep"> <!-- Separador 2 -->
            <col class="rpt-dg-col-obj-a"><col class="rpt-dg-col-contr-a"><col class="rpt-dg-col-ip">
            <col class="rpt-dg-col-spacer"><col class="rpt-dg-col-var-contr"><col class="rpt-dg-col-var-cart">
        </colgroup>
        <thead>
            <tr class="rpt-dg-subheaders-row">
                <th colspan="2" class="rpt-align-center rpt-fs-8pt"><span class="rpt-dg-subheader-label">Mensual</span></th>
                <th class="rpt-dg-col-sep" rpt-border-none></th> <!-- Sep 1 -->
                <th rpt-border-none></th> <!-- Centro -->
                <th class="rpt-dg-col-sep" rpt-border-none></th> <!-- Sep 2 -->
                <th colspan="3" class="rpt-align-center rpt-fs-8pt"><span class="rpt-dg-subheader-label">Acumulado</span></th>
                <th rpt-border-none></th> <!-- Spacer -->
                <th colspan="2" class="rpt-align-center rpt-fs-8pt"><span class="rpt-dg-subheader-label">Var/${anioAnterior}</span></th>
            </tr>
            <tr class="rpt-dg-th-columns">
                <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Objet.</th>
                <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Contr.</th>
                <th class="rpt-dg-col-sep" rpt-border-none></th> <!-- Sep 1 -->
                <th class="rpt-dg-header-center-name">${dn.nombreDirNegocio}</th>
                <th class="rpt-dg-col-sep" rpt-border-none></th> <!-- Sep 2 -->
                <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Objet.</th>
                <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Contr.</th>
                <th class="rpt-align-center rpt-text-corporate rpt-fs-8pt">Ip</th>
                <th rpt-border-none></th> <!-- Spacer -->
                <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Contr.</th>
                <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Cart.(${mesAnteriorLabel})</th>
            </tr>
            <tr class="rpt-dg-header-line-row">
                <th class="rpt-dg-header-line" colspan="2"></th>
                <th class="rpt-dg-col-sep"></th> <!-- Sep 1 -->
                <th></th> <!-- Centro -->
                <th class="rpt-dg-col-sep"></th> <!-- Sep 2 -->
                <th class="rpt-dg-header-line" colspan="3"></th>
                <th></th> <!-- Spacer -->
                <th class="rpt-dg-header-line" colspan="2"></th>
            </tr>
        </thead>
        <tbody>`;

    let filasHtml = '';
    dn.areas.forEach(area => {
        if (area.area && area.area.trim() !== '') {
            filasHtml += `
            <tr class="rpt-dg-area-row">
                <td class="rpt-dg-col-obj-m rpt-number-cell">${formatCurrency(area.mensual.objetivos, 0)}</td>
                <td class="rpt-dg-col-contr-m rpt-number-cell">${formatCurrency(area.mensual.contratacion, 0)}</td>
                <td class="rpt-dg-col-sep"></td> <!-- Sep 1 -->
                <td class="rpt-dg-col-centro">${area.area}</td>
                <td class="rpt-dg-col-sep"></td> <!-- Sep 2 -->
                <td class="rpt-dg-col-obj-a rpt-number-cell">${formatCurrency(area.acumulado.objetivos, 0)}</td>
                <td class="rpt-dg-col-contr-a rpt-number-cell">${formatCurrency(area.acumulado.contratacion / 1000, 0)}</td>
                <td class="rpt-dg-col-ip rpt-align-end">${formatCurrency(area.acumulado.ip, 2)}</td>
                <td class="rpt-dg-col-spacer"></td>
                <td class="rpt-dg-col-var-contr rpt-align-end">${area.variaciones.contratacion}</td>
                <td class="rpt-dg-col-var-cart rpt-align-end">${area.variaciones.cartera}</td>
            </tr>`;
        }

        area.delegaciones.forEach(del => {
            filasHtml += `
            <tr class="rpt-dg-detail-row">
                <td class="rpt-dg-col-obj-m rpt-number-cell">${formatCurrency(del.mensual.objetivos, 0)}</td>
                <td class="rpt-dg-col-contr-m rpt-number-cell">${formatCurrency(del.mensual.contratacion, 0)}</td>
                <td class="rpt-dg-col-sep"></td> <!-- Sep 1 -->
                <td class="rpt-dg-col-centro">${del.nombreDelegacion}</td>
                <td class="rpt-dg-col-sep"></td> <!-- Sep 2 -->
                <td class="rpt-dg-col-obj-a rpt-number-cell">${formatCurrency(del.acumulado.objetivos, 0)}</td>
                <td class="rpt-dg-col-contr-a rpt-number-cell">${formatCurrency(del.acumulado.contratacion / 1000, 0)}</td>
                <td class="rpt-dg-col-ip rpt-align-end">${formatCurrency(del.acumulado.ip, 2)}</td>
                <td class="rpt-dg-col-spacer"></td>
                <td class="rpt-dg-col-var-contr rpt-align-end">${del.variaciones.contratacion}</td>
                <td class="rpt-dg-col-var-cart rpt-align-end">${del.variaciones.cartera}</td>
            </tr>`;
        });
    });

    const totalesHtml = `
            <tr class="rpt-spacer-row-totales"><td colspan="11" class="rpt-spacer-cell-totales"></td></tr>
            <tr class="rpt-dg-total-row">
                <td class="rpt-dg-col-obj-m rpt-number-cell rpt-td-total">${formatCurrency(dn.totales.objetivosMensual, 0)}</td>
                <td class="rpt-dg-col-contr-m rpt-number-cell rpt-td-total">${formatCurrency(dn.totales.contratacionMensual, 0)}</td>
                <td class="rpt-dg-col-sep"></td> <!-- Sep 1 -->
                <td class="rpt-dg-col-centro rpt-dg-total-border-top">&nbsp;</td>
                <td class="rpt-dg-col-sep"></td> <!-- Sep 2 -->
                <td class="rpt-dg-col-obj-a rpt-number-cell rpt-td-total">${formatCurrency(dn.totales.objetivosAcumulado, 0)}</td>
                <td class="rpt-dg-col-contr-a rpt-number-cell rpt-td-total">${formatCurrency(dn.totales.contratacionAcumulado / 1000, 0)}</td>
                <td class="rpt-dg-col-ip rpt-align-end rpt-td-total">${formatCurrency(dn.totales.ip, 2)}</td>
                <td class="rpt-dg-col-spacer"></td>
                <td class="rpt-dg-col-var-contr rpt-align-end rpt-td-total">${dn.totales.variacionContratacion}</td>
                <td class="rpt-dg-col-var-cart rpt-align-end rpt-td-total">${dn.totales.variacionCartera}</td>
            </tr>
            <tr class="rpt-spacer-row-resumen"><td colspan="11"></td></tr>`;

    const hasNacional = dn.totales.resumen.objetivosMensualNacional !== 0 ||
        dn.totales.resumen.contratacionMensualNacional !== 0;

    const htmlNacional = hasNacional ? `
            <tr class="rpt-dg-resumen-row rpt-dg-resumen-nacional">
                <td class="rpt-dg-col-obj-m rpt-number-cell">${formatCurrency(dn.totales.resumen.objetivosMensualNacional, 0)}</td>
                <td class="rpt-dg-col-contr-m rpt-number-cell">${formatCurrency(dn.totales.resumen.contratacionMensualNacional, 0)}</td>
                <td class="rpt-dg-col-sep"></td> <!-- Sep 1 -->
                <td class="rpt-dg-col-centro rpt-dg-resumen-label">Nacional</td>
                <td class="rpt-dg-col-sep"></td> <!-- Sep 2 -->
                <td class="rpt-dg-col-obj-a rpt-number-cell">${formatCurrency(dn.totales.resumen.objetivosAcumuladoNacional, 0)}</td>
                <td class="rpt-dg-col-contr-a rpt-number-cell">${formatCurrency(dn.totales.resumen.contratacionAcumuladoNacional / 1000, 0)}</td>
                <td class="rpt-dg-col-ip rpt-align-end">${formatCurrency(dn.totales.resumen.ipNacional, 2)}</td>
                <td class="rpt-dg-col-spacer"></td>
                <td class="rpt-align-end">&nbsp;</td>
                <td class="rpt-align-end">&nbsp;</td>
            </tr>` : '';

    const hasInternacional = dn.totales.resumen.objetivosMensualInternacional !== 0 ||
        dn.totales.resumen.contratacionMensualInternacional !== 0;

    const htmlInternacional = hasInternacional ? `
            <tr class="rpt-dg-resumen-row rpt-dg-resumen-internacional">
                <td class="rpt-dg-col-obj-m rpt-number-cell">${formatCurrency(dn.totales.resumen.objetivosMensualInternacional, 0)}</td>
                <td class="rpt-dg-col-contr-m rpt-number-cell">${formatCurrency(dn.totales.resumen.contratacionMensualInternacional, 0)}</td>
                <td class="rpt-dg-col-sep"></td> <!-- Sep 1 -->
                <td class="rpt-dg-col-centro rpt-dg-resumen-label">Internacional</td>
                <td class="rpt-dg-col-sep"></td> <!-- Sep 2 -->
                <td class="rpt-dg-col-obj-a rpt-number-cell">${formatCurrency(dn.totales.resumen.objetivosAcumuladoInternacional, 0)}</td>
                <td class="rpt-dg-col-contr-a rpt-number-cell">${formatCurrency(dn.totales.resumen.contratacionAcumuladoInternacional / 1000, 0)}</td>
                <td class="rpt-dg-col-ip rpt-align-end">${formatCurrency(dn.totales.resumen.ipInternacional, 2)}</td>
                <td class="rpt-dg-col-spacer"></td>
                <td class="rpt-align-end">&nbsp;</td>
                <td class="rpt-align-end">&nbsp;</td>
            </tr>` : '';

    const resumenHtml = htmlNacional + htmlInternacional;

    return `<div class="rpt-bloque-dn" data-dn="${dn.nombreDirNegocio}">${tableHeader}${filasHtml}${totalesHtml}${resumenHtml}</tbody></table></div>`;
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    const data = estado.informeGlobalData;
    const styleVars = getStyleVars(estado.margenes);
    
    // Crear capa de impresión manual para usar la técnica de Outer Table
    const capaPrint = document.createElement('div');
    capaPrint.className = 'rpt-print-layer';
    
    // La Outer Table permite que el thead se repita en cada página física del PDF
    const html = `
        <div class="rpt-paper rpt-paper--print" data-informe="mercados_sg_delegaciones"${styleVars}>
            <table class="rpt-print-outer-table">
                <thead>
                    <tr>
                        <td class="rpt-print-td-header">
                            ${_getHtmlEncabezadoBase()}
                        </td>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="rpt-print-td-body">
                            <div class="report-body rpt-cmai-mt-standard">
                                ${data.subDireccionesGenerales.map((sdg, idx) => {
                                    const htmlSDG = _renderSDG(sdg);
                                    return idx < data.subDireccionesGenerales.length - 1 
                                        ? `${htmlSDG}<div class="rpt-page-break"></div>` 
                                        : htmlSDG;
                                }).join('')}
                            </div>
                        </td>
                    </tr>
                </tbody>
                <tfoot>
                    <tr>
                        <td class="rpt-print-td-footer">
                            <!-- Espacio para el pie de página si fuera necesario -->
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
