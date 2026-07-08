import { RPT_CLASSES, formatCurrency, actualizarEstadoPaginacion, inicializarEventListenersBase } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, getStyleVars, MARGENES_ESTANDAR } from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

export async function ejecutar({ anio, mes, nroPagina, mostrarTitulo, codSubDir, isPdf }) {
    try {
        let url = `/api/CD_Elecnor_DG_Centros_DGRI_Nuevo?anio=${anio}&mes=${mes}`;
        if (nroPagina) url += `&nroPagina=${nroPagina}`;
        if (codSubDir) url += `&codSubDirGeneral=${codSubDir}`;
        url += `&_=${Date.now()}`;

        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;
        estado.isPdf = isPdf;

        await inicializarInforme({
            url, estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: '',
            claveAgrupacion: 'subDireccionesGenerales',
            margenes: MARGENES_ESTANDAR
        });

        // Vista Unificada forzada a 1 página física en visualización web
        estado.paginasTotales = 1;
        actualizarEstadoPaginacion(0, 1, "Vista Unificada");

    } catch (error) {
        console.error("Error al ejecutar informe CD_Elecnor_DG_Centros_DGRI_Nuevo:", error);
        throw error;
    }
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;
    
    const data = estado.informeGlobalData;
    if (!data || !data.subDireccionesGenerales) return;

    if (estado.isPdf) {
        const styleVars = getStyleVars(estado.margenes);
        container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER} rpt-paper--print" data-informe="CD_Elecnor_DG_Centros_DGRI_Nuevo"${styleVars}>
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
            </table>
        </div>`;
        return;
    }

    const cuerpoHtml = data.subDireccionesGenerales.map((sdg, idx) => {
        const htmlSDG = _renderSDG(sdg);
        return idx < data.subDireccionesGenerales.length - 1 
            ? `${htmlSDG}<div class="rpt-page-break"></div>` 
            : htmlSDG;
    }).join('');

    container.innerHTML = `
    <div class="${RPT_CLASSES.PAPER}" data-informe="CD_Elecnor_DG_Centros_DGRI_Nuevo" role="main"${getStyleVars(estado.margenes)}>
        ${_getHtmlEncabezadoBase()}
        <div class="report-body rpt-cmai-mt-standard">${cuerpoHtml}</div>
    </div>`;

    container.scrollTop = 0;
}

function _getHtmlEncabezadoBase() {
    return getHtmlEncabezadoBase({
        tituloCorporativo: '<span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container rpt-d-none">Consejo Elecnor</span> <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>',
        textoBanner1: 'Elecnor',
        textoBanner2: 'Delegaciones',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

function _renderSDG(sdg) {
    if (!sdg || !sdg.direccionesNegocio) return '';
    
    const data = estado.informeGlobalData;
    const anioAnterior = data.meta.filtros.anio - 1;
    const meses = ["Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"];
    const mesAnterior = data.meta.filtros.mes - 1;
    const mesAnteriorLabel = mesAnterior > 0 ? meses[mesAnterior - 1] : anioAnterior;
    const nombreSDG = sdg.nombreSubDirGeneral;

    let htmlCompleto = '';

    sdg.direccionesNegocio.forEach((dn, dnIdx) => {
        const isFirstDN = (dnIdx === 0);
        const isPrintOnlyHeader = (sdg.codSubDirGeneral === '221' && dnIdx === 2);
        
        // 1. Título de la Subdirección General (se pinta arriba del todo)
        let sdgTitleHtml = '';
        if (isFirstDN) {
            sdgTitleHtml = `<div class="rpt-dg-sdg-titulo">${nombreSDG}</div>`;
        } else if (isPrintOnlyHeader) {
            sdgTitleHtml = `<div class="rpt-dg-sdg-titulo rpt-print-only">${nombreSDG}</div>`;
        }

        let nombreDNFormateado = dn.nombreDirNegocio || '';
        if (nombreDNFormateado.startsWith("DIR. ")) {
            nombreDNFormateado = nombreDNFormateado.replace("DIR. ", "D. ");
        } else if (nombreDNFormateado.startsWith("DIR.")) {
            nombreDNFormateado = nombreDNFormateado.replace("DIR.", "D. ");
        }

        if (isPrintOnlyHeader) {
            htmlCompleto += `<div class="rpt-print-page-break-before"></div>`;
        }

        if (sdgTitleHtml) {
            htmlCompleto += sdgTitleHtml;
        }

        dn.delegaciones.forEach((del, delIdx) => {
            const isFirstDelInDN = (delIdx === 0);
            const subheaderLabel = isFirstDelInDN ? nombreDNFormateado : '';

            let subheadersHtml = `
                <tr class="rpt-dg-subheaders-row">
                    <th colspan="2" class="rpt-align-center rpt-fs-8pt"><span class="rpt-dg-subheader-label">Mensual</span></th>
                    <th class="rpt-dg-col-sep" rpt-border-none></th>
                    <th class="rpt-align-center rpt-fs-8pt"><span class="rpt-dg-dn-subheader-label">${subheaderLabel}</span></th>
                    <th class="rpt-dg-col-sep" rpt-border-none></th>
                    <th colspan="3" class="rpt-align-center rpt-fs-8pt"><span class="rpt-dg-subheader-label">Acumulado</span></th>
                    <th rpt-border-none></th>
                    <th colspan="2" class="rpt-align-center rpt-fs-8pt"><span class="rpt-dg-subheader-label">Var/${anioAnterior}</span></th>
                </tr>`;

            const tableHeader = `
            <table class="rpt-table-delegaciones">
                <colgroup>
                    <col class="rpt-dg-col-obj-m"><col class="rpt-dg-col-contr-m">
                    <col class="rpt-dg-col-sep">
                    <col class="rpt-dg-col-centro">
                    <col class="rpt-dg-col-sep">
                    <col class="rpt-dg-col-obj-a"><col class="rpt-dg-col-contr-a"><col class="rpt-dg-col-ip">
                    <col class="rpt-dg-col-spacer"><col class="rpt-dg-col-var-contr"><col class="rpt-dg-col-var-cart">
                </colgroup>
                <thead>
                    ${subheadersHtml}
                    <tr class="rpt-dg-th-columns">
                        <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Objet.</th>
                        <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Contr.</th>
                        <th class="rpt-dg-col-sep" rpt-border-none></th>
                        <th class="rpt-dg-header-center-name">${del.nombreDelegacion}</th>
                        <th class="rpt-dg-col-sep" rpt-border-none></th>
                        <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Objet.</th>
                        <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Contr.</th>
                        <th class="rpt-dg-col-ip rpt-align-end rpt-text-corporate rpt-fs-8pt">Ip</th>
                        <th rpt-border-none></th>
                        <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Contr.</th>
                        <th class="rpt-align-end rpt-text-corporate rpt-fs-8pt">Cart.(${mesAnteriorLabel})</th>
                    </tr>
                    <tr class="rpt-dg-header-line-row">
                        <th class="rpt-dg-header-line" colspan="2"></th>
                        <th class="rpt-dg-col-sep"></th>
                        <th></th>
                        <th class="rpt-dg-col-sep"></th>
                        <th class="rpt-dg-header-line" colspan="3"></th>
                        <th></th>
                        <th class="rpt-dg-header-line" colspan="2"></th>
                    </tr>
                </thead>
                <tbody>`;

            let filasCentrosHtml = del.centros.map(ct => `
                <tr class="rpt-dg-detail-row">
                    <td class="rpt-dg-col-obj-m rpt-number-cell">${formatCurrency(ct.mensual.objetivos, 0)}</td>
                    <td class="rpt-dg-col-contr-m rpt-number-cell">${formatCurrency(ct.mensual.contratacion, 0)}</td>
                    <td class="rpt-dg-col-sep"></td>
                    <td class="rpt-dg-col-centro">${ct.nombreCentro}</td>
                    <td class="rpt-dg-col-sep"></td>
                    <td class="rpt-dg-col-obj-a rpt-number-cell">${formatCurrency(ct.acumulado.objetivos, 0)}</td>
                    <td class="rpt-dg-col-contr-a rpt-number-cell">${formatCurrency(ct.acumulado.contratacion, 0)}</td>
                    <td class="rpt-dg-col-ip rpt-align-end">${formatCurrency(ct.acumulado.ip, 2)}</td>
                    <td class="rpt-dg-col-spacer"></td>
                    <td class="rpt-dg-col-var-contr rpt-align-end">${ct.variaciones.contratacion}</td>
                    <td class="rpt-dg-col-var-cart rpt-align-end">${ct.variaciones.cartera}</td>
                </tr>
            `).join('');

            const totalDelegacionHtml = `
                <tr class="rpt-spacer-row-totales"><td colspan="11" class="rpt-spacer-cell-totales"></td></tr>
                <tr class="rpt-dg-total-row">
                    <td class="rpt-dg-col-obj-m rpt-number-cell rpt-td-total">${formatCurrency(del.totales.objetivosMensual, 0)}</td>
                    <td class="rpt-dg-col-contr-m rpt-number-cell rpt-td-total">${formatCurrency(del.totales.contratacionMensual, 0)}</td>
                    <td class="rpt-dg-col-sep"></td>
                    <td class="rpt-dg-col-centro rpt-dg-total-border-top">&nbsp;</td>
                    <td class="rpt-dg-col-sep"></td>
                    <td class="rpt-dg-col-obj-a rpt-number-cell rpt-td-total">${formatCurrency(del.totales.objetivosAcumulado, 0)}</td>
                    <td class="rpt-dg-col-contr-a rpt-number-cell rpt-td-total">${formatCurrency(del.totales.contratacionAcumulado, 0)}</td>
                    <td class="rpt-dg-col-ip rpt-align-end rpt-td-total">${formatCurrency(del.totales.ip, 2)}</td>
                    <td class="rpt-dg-col-spacer"></td>
                    <td class="rpt-dg-col-var-contr rpt-align-end rpt-td-total">${del.totales.variacionContratacion}</td>
                    <td class="rpt-dg-col-var-cart rpt-align-end rpt-td-total">${del.totales.variacionCartera}</td>
                </tr>
                <tr class="rpt-spacer-row-resumen"><td colspan="11"></td></tr>`;

            const hasNacional = del.totales.resumen.objetivosMensualNacional !== 0 || del.totales.resumen.contratacionMensualNacional !== 0;
            const htmlNacional = hasNacional ? `
                <tr class="rpt-dg-resumen-row rpt-dg-resumen-nacional">
                    <td class="rpt-dg-col-obj-m rpt-number-cell">${formatCurrency(del.totales.resumen.objetivosMensualNacional, 0)}</td>
                    <td class="rpt-dg-col-contr-m rpt-number-cell">${formatCurrency(del.totales.resumen.contratacionMensualNacional, 0)}</td>
                    <td class="rpt-dg-col-sep"></td>
                    <td class="rpt-dg-col-centro rpt-dg-resumen-label">Nacional</td>
                    <td class="rpt-dg-col-sep"></td>
                    <td class="rpt-dg-col-obj-a rpt-number-cell">${formatCurrency(del.totales.resumen.objetivosAcumuladoNacional, 0)}</td>
                    <td class="rpt-dg-col-contr-a rpt-number-cell">${formatCurrency(del.totales.resumen.contratacionAcumuladoNacional, 0)}</td>
                    <td class="rpt-dg-col-ip rpt-align-end">${formatCurrency(del.totales.resumen.ipNacional, 2)}</td>
                    <td class="rpt-dg-col-spacer"></td>
                    <td class="rpt-align-end">&nbsp;</td>
                    <td class="rpt-align-end">&nbsp;</td>
                </tr>` : '';

            const hasInternacional = del.totales.resumen.objetivosMensualInternacional !== 0 || del.totales.resumen.contratacionMensualInternacional !== 0;
            const htmlInternacional = hasInternacional ? `
                <tr class="rpt-dg-resumen-row rpt-dg-resumen-internacional">
                    <td class="rpt-dg-col-obj-m rpt-number-cell">${formatCurrency(del.totales.resumen.objetivosMensualInternacional, 0)}</td>
                    <td class="rpt-dg-col-contr-m rpt-number-cell">${formatCurrency(del.totales.resumen.contratacionMensualInternacional, 0)}</td>
                    <td class="rpt-dg-col-sep"></td>
                    <td class="rpt-dg-col-centro rpt-dg-resumen-label">Internacional</td>
                    <td class="rpt-dg-col-sep"></td>
                    <td class="rpt-dg-col-obj-a rpt-number-cell">${formatCurrency(del.totales.resumen.objetivosAcumuladoInternacional, 0)}</td>
                    <td class="rpt-dg-col-contr-a rpt-number-cell">${formatCurrency(del.totales.resumen.contratacionAcumuladoInternacional, 0)}</td>
                    <td class="rpt-dg-col-ip rpt-align-end">${formatCurrency(del.totales.resumen.ipInternacional, 2)}</td>
                    <td class="rpt-dg-col-spacer"></td>
                    <td class="rpt-align-end">&nbsp;</td>
                    <td class="rpt-align-end">&nbsp;</td>
                </tr>` : '';

            const resumenHtml = htmlNacional + htmlInternacional;

            htmlCompleto += `<div class="rpt-bloque-delegacion" data-delegacion="${del.nombreDelegacion}">${tableHeader}${filasCentrosHtml}${totalDelegacionHtml}${resumenHtml}</tbody></table></div>`;
        });
    });

    return htmlCompleto;
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

async function _imprimirInforme() {
    const data = estado.informeGlobalData;
    const styleVars = getStyleVars(estado.margenes);
    
    const capaPrint = document.createElement('div');
    capaPrint.className = 'rpt-print-layer';
    
    const html = `
        <div class="rpt-paper rpt-paper--print" data-informe="CD_Elecnor_DG_Centros_DGRI_Nuevo"${styleVars}>
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
