import { RPT_CLASSES, formatCurrency, actualizarEstadoPaginacion, inicializarEventListenersBase } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase } from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

export async function ejecutar({ anio, mes, nroPagina, mercado, codSubDir, mostrarTitulo }) {
    try {
        const subDir = codSubDir || '221';
        const url = `/api/MercadosSGDelegaciones?anio=${anio}&mes=${mes}&codSubDirGeneral=${encodeURIComponent(subDir)}&_=${Date.now()}`;

        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;

        await inicializarInforme({
            url, estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: '',
            claveAgrupacion: 'subDireccionesGenerales',
            margenes: { web: '1.5rem', pdf: '6.4mm', maxWidth: '1200px' }
        });
    } catch (error) {
        console.error("Error al ejecutar informe Mercados SG Delegaciones:", error);
    }
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;
    const sdg = estado.informeGlobalData.subDireccionesGenerales[estado.paginaActual];
    if (!sdg) return;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="mercados_sg_delegaciones" role="main">
            ${_getHtmlEncabezado(sdg)}
            <div class="report-body">${_renderSDG(sdg)}</div>
        </div>`;
    container.scrollTop = 0;
    actualizarEstadoPaginacion(estado.paginaActual, estado.paginasTotales, sdg.nombreSubDirGeneral);
}

function _getHtmlEncabezado(sdg) {
    const encabezadoBase = getHtmlEncabezadoBase({
        tituloCorporativo: 'Informe de Contratación',
        textoBanner1: 'Elecnor',
        textoBanner2: 'Direcciones',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });

    if (!sdg) return encabezadoBase;

    // Inyectar el título de la Subdirección General (naranja) debajo del banner base
    return `
        ${encabezadoBase}
        <div style="text-align: center; color: #ff8c00; font-size: 1.1rem; font-weight: bold; margin-top: 10px; margin-bottom: 5px;">
            ${sdg.nombreSubDirGeneral}
        </div>
    `;
}
function _renderSDG(sdg) {
    if (!sdg || !sdg.direccionesNegocio) return '';
    return sdg.direccionesNegocio.map(dn => _renderDN(dn, sdg)).join('');
}

function _renderDN(dn, sdg) {
    const data = estado.informeGlobalData;
    const anioAnterior = data.meta.filtros.anio - 1;
    const meses = ["Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"];
    const mesAnterior = data.meta.filtros.mes - 1;
    const mesAnteriorLabel = mesAnterior > 0 ? meses[mesAnterior - 1] : anioAnterior;
    const isFirstDN = dn === sdg.direccionesNegocio[0];

    const subHeaders = ''; // Se mueven al interior del thead de la tabla

    const tableHeader = `
        <table class="rpt-table-delegaciones">
            <colgroup>
                <col class="rpt-dg-col-obj-m"><col class="rpt-dg-col-contr-m"><col class="rpt-dg-col-centro">
                <col class="rpt-dg-col-obj-a"><col class="rpt-dg-col-contr-a"><col class="rpt-dg-col-ip">
                <col class="rpt-dg-col-spacer"><col class="rpt-dg-col-var-contr"><col class="rpt-dg-col-var-cart">
            </colgroup>
            <thead>
                ${isFirstDN ? `
                <tr class="rpt-dg-subheaders-row">
                    <th colspan="2" class="text-center"><span>Mensual</span></th>
                    <th></th>
                    <th colspan="3" class="text-center"><span>Acumulado</span></th>
                    <th></th>
                    <th colspan="2" class="text-center"><span>Var/${anioAnterior}</span></th>
                </tr>` : ''}
                <tr class="rpt-dg-th-columns">
                    <th class="text-end pe-2 rpt-text-corporate">Objet.</th>
                    <th class="text-end pe-2 rpt-text-corporate">Contr.</th>
                    <th class="rpt-dg-header-center-name text-white" style="background-color: #00468B; border: 1px solid #00468B;">${dn.nombreDirNegocio}</th>
                    <th class="text-end pe-2 rpt-text-corporate">Objet.</th>
                    <th class="text-end pe-2 rpt-text-corporate">Contr.</th>
                    <th class="text-center rpt-text-corporate">Ip</th><th></th>
                    <th class="text-center rpt-text-corporate">Contr.</th>
                    <th class="text-center rpt-text-corporate">Cart.(${mesAnteriorLabel})</th>
                </tr>
                <tr class="rpt-dg-header-line-row">
                    <th class="rpt-dg-header-line" colspan="2"></th>
                    <th></th>
                    <th class="rpt-dg-header-line" colspan="3"></th>
                    <th></th>
                    <th class="rpt-dg-header-line" colspan="2"></th>
                </tr>
            </thead><tbody>`;

    const filasHtml = dn.areas
        .flatMap(area => area.delegaciones.map(del => ({ ...del, area: area.area })))
        .map(del => `
            <tr class="rpt-dg-detail-row">
                <td class="rpt-dg-col-obj-m text-end">${formatCurrency(del.mensual.objetivos, 0)}</td>
                <td class="rpt-dg-col-contr-m text-end">${formatCurrency(del.mensual.contratacion, 0)}</td>
                <td class="rpt-dg-col-centro">${del.nombreDelegacion}</td>
                <td class="rpt-dg-col-obj-a text-end">${formatCurrency(del.acumulado.objetivos, 0)}</td>
                <td class="rpt-dg-col-contr-a text-end">${formatCurrency(del.acumulado.contratacion / 1000, 0)}</td>
                <td class="rpt-dg-col-ip text-center">${formatCurrency(del.acumulado.ip, 2)}</td>
                <td class="rpt-dg-col-spacer"></td>
                <td class="rpt-dg-col-var-contr text-center">${del.variaciones.contratacion}</td>
                <td class="rpt-dg-col-var-cart text-center">${del.variaciones.cartera}</td>
            </tr>`).join('');

    const totalesHtml = `
            <tr class="rpt-dg-total-row">
                <td class="rpt-dg-col-obj-m text-end has-line">${formatCurrency(dn.totales.objetivosMensual, 0)}</td>
                <td class="rpt-dg-col-contr-m text-end has-line">${formatCurrency(dn.totales.contratacionMensual, 0)}</td>
                <td class="rpt-dg-col-centro">&nbsp;</td>
                <td class="rpt-dg-col-obj-a text-end has-line">${formatCurrency(dn.totales.objetivosAcumulado, 0)}</td>
                <td class="rpt-dg-col-contr-a text-end has-line">${formatCurrency(dn.totales.contratacionAcumulado / 1000, 0)}</td>
                <td class="rpt-dg-col-ip text-center has-line">${formatCurrency(dn.totales.ip, 2)}</td>
                <td class="rpt-dg-col-spacer"></td>
                <td class="rpt-dg-col-var-contr text-center has-line">${dn.totales.variacionContratacion}</td>
                <td class="rpt-dg-col-var-cart text-center has-line">${dn.totales.variacionCartera}</td>
            </tr>`;

    const hasNacional = dn.totales.resumen.objetivosMensualNacional !== 0 ||
                        dn.totales.resumen.contratacionMensualNacional !== 0 ||
                        dn.totales.resumen.objetivosAcumuladoNacional !== 0 ||
                        dn.totales.resumen.contratacionAcumuladoNacional !== 0;

    const htmlNacional = hasNacional ? `
            <tr class="rpt-dg-resumen-row rpt-dg-resumen-nacional">
                <td class="rpt-dg-col-obj-m text-end">${formatCurrency(dn.totales.resumen.objetivosMensualNacional, 0)}</td>
                <td class="rpt-dg-col-contr-m text-end">${formatCurrency(dn.totales.resumen.contratacionMensualNacional, 0)}</td>
                <td class="rpt-dg-col-centro">Nacional</td>
                <td class="rpt-dg-col-obj-a text-end">${formatCurrency(dn.totales.resumen.objetivosAcumuladoNacional, 0)}</td>
                <td class="rpt-dg-col-contr-a text-end">${formatCurrency(dn.totales.resumen.contratacionAcumuladoNacional / 1000, 0)}</td>
                <td class="rpt-dg-col-ip text-center">${formatCurrency(dn.totales.resumen.ipNacional, 2)}</td>
                <td class="rpt-dg-col-spacer"></td>
                <td class="rpt-dg-col-var-contr text-center"></td><td class="rpt-dg-col-var-cart text-center"></td>
            </tr>` : '';

    const hasInternacional = dn.totales.resumen.objetivosMensualInternacional !== 0 ||
                             dn.totales.resumen.contratacionMensualInternacional !== 0 ||
                             dn.totales.resumen.objetivosAcumuladoInternacional !== 0 ||
                             dn.totales.resumen.contratacionAcumuladoInternacional !== 0;

    const htmlInternacional = hasInternacional ? `
            <tr class="rpt-dg-resumen-row rpt-dg-resumen-internacional">
                <td class="rpt-dg-col-obj-m text-end">${formatCurrency(dn.totales.resumen.objetivosMensualInternacional, 0)}</td>
                <td class="rpt-dg-col-contr-m text-end">${formatCurrency(dn.totales.resumen.contratacionMensualInternacional, 0)}</td>
                <td class="rpt-dg-col-centro">Internacional</td>
                <td class="rpt-dg-col-obj-a text-end">${formatCurrency(dn.totales.resumen.objetivosAcumuladoInternacional, 0)}</td>
                <td class="rpt-dg-col-contr-a text-end">${formatCurrency(dn.totales.resumen.contratacionAcumuladoInternacional / 1000, 0)}</td>
                <td class="rpt-dg-col-ip text-center">${formatCurrency(dn.totales.resumen.ipInternacional, 2)}</td>
                <td class="rpt-dg-col-spacer"></td>
                <td class="rpt-dg-col-var-contr text-center"></td><td class="rpt-dg-col-var-cart text-center"></td>
            </tr>` : '';

    const resumenHtml = htmlNacional + htmlInternacional;

    return `<div class="rpt-bloque-dn" data-dn="${dn.nombreDirNegocio}">
        ${tableHeader}${filasHtml}${totalesHtml}${resumenHtml}</tbody></table></div>`;
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    const informeGlobalData = estado.informeGlobalData;
    if (!informeGlobalData) return;

    const items = informeGlobalData.subDireccionesGenerales || [];
    if (!items.length) return;

    // Variables CSS inline para márgenes (paridad con el modal)
    const styleVars = '--rpt-padding-web: 1.5rem; --rpt-padding-pdf: 6.4mm; --rpt-max-width: 1200px;';

    const capaPrint = document.createElement('div');
    capaPrint.className = 'rpt-print-layer';

    /* Técnica Outer-Table para repetición nativa de cabeceras corporativas */
    const html = items.map((sdg, idx) => `
        <div class="rpt-paper rpt-paper--print ${idx < items.length - 1 ? 'rpt-page-break' : ''}"
             style="${styleVars}">
            <table style="width:100%; border-collapse:collapse; border:none; table-layout:fixed;">
                <thead>
                    <tr>
                        <td style="padding: 6.4mm 0 0 0; border:none;">
                            ${_getHtmlEncabezado(sdg)}
                        </td>
                    </tr>
                </thead>
                <tfoot>
                    <tr>
                        <td style="padding-bottom: 6.4mm; border:none;"></td>
                    </tr>
                </tfoot>
                <tbody>
                    <tr>
                        <td style="padding:0; border:none; vertical-align:top;">
                            <div class="report-body">${_renderSDG(sdg)}</div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    `).join('');

    capaPrint.innerHTML = html;
    document.body.appendChild(capaPrint);

    const originalTitle = document.title;
    try {
        await new Promise(resolve => setTimeout(resolve, 200));
        document.title = '';
        window.print();
    } finally {
        document.title = originalTitle;
        if (document.body.contains(capaPrint)) {
            document.body.removeChild(capaPrint);
        }
    }
}
