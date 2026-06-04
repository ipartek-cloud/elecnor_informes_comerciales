/**
 * Informe: Contrataciones Significativas
 * Gestión dual de mercados Nacional (paginado) e Internacional (tabla única).
 */
import {
    RPT_CLASSES, formatCurrency, getNombreMes, escapeHtml,
    actualizarEstadoPaginacion, inicializarEventListenersBase
} from './utils.js';
import {
    crearEstadoInforme, inicializarInforme,
    getHtmlEncabezadoBase, imprimirInformeUnificado, getStyleVars, MARGENES_ESTANDAR
} from './informes_unificados_utils.js';
import { ApiClient, GlobalUI } from '../site.js';

const estado = crearEstadoInforme();

/**
 * Punto de entrada del informe.
 */
export async function ejecutar({ anio, mes, nroPagina, mercado = 'Nacional', umbral, codSubDir = '221', mostrarTitulo = true, limiteImporte = 1000 }) {
    try {
        const chkGenerar = document.getElementById('chkGenerarRPTPrincipalesContrataciones');
        if (chkGenerar?.checked) {
            GlobalUI.showLoading('Generando contrataciones significativas...');
            const genResp = await ApiClient.post('/api/ContratacionesSignificativas/generar', { anio, mes }, true);
            if (!genResp.ok) {
                const errorText = await genResp.text();
                GlobalUI.showAlert('Error al generar: ' + errorText, 'danger');
                GlobalUI.hideLoading();
                return;
            }
            GlobalUI.hideLoading();
        }

        const subDir = codSubDir || '221';
        const url = `/api/ContratacionesSignificativas?anio=${anio}&mes=${mes}&mercado=${encodeURIComponent(mercado)}&codSubDirGeneral=${encodeURIComponent(subDir)}&limiteImporte=${limiteImporte}&_=${Date.now()}`;

        estado.nroPagina = nroPagina;
        estado.mostrarNumeroPagina = (nroPagina !== null && nroPagina !== undefined);
        estado.mostrarTitulo = mostrarTitulo;
        estado.limiteImporte = limiteImporte;

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: 'Página',
            claveAgrupacion: mercado === 'Internacional' ? 'NONE' : 'datos',
            margenes: MARGENES_ESTANDAR
        });

    } catch (error) {
        console.error('[ContratacionesSignificativas] Error:', error);
        throw error;
    }
}

/**
 * Renderizado de página según mercado.
 */
async function _renderizarPagina(index = 0) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const data = estado.informeGlobalData;
    const esInternacional = data?.meta?.filtros?.mercado === 'Internacional';

    let cuerpoHtml = '';

    if (esInternacional) {
        // MODO WEB INTERNACIONAL: Solo la primera dirección muestra los literales de columna.
        cuerpoHtml = data.datos.map((dir, idx) => _renderTablaDireccion(dir, idx === 0)).join('<div class="rpt-page-break"></div>');
    } else {
        // MODO WEB NACIONAL: Una dirección por página (siempre muestra literales).
        const direccion = data.datos[index];
        cuerpoHtml = direccion ? _renderTablaDireccion(direccion, true) : '<div class="rpt-text-center rpt-p-5 rpt-text-muted-gray">No hay registros disponibles.</div>';
    }

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="contrataciones_significativas" role="main" ${getStyleVars(estado.margenes)}>
            ${_getHtmlEncabezado()}
            <div class="report-body rpt-cmai-mt-medium">
                ${cuerpoHtml}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(estado.paginaActual, estado.paginasTotales, 'Página');
}

/**
 * Genera el encabezado corporativo CMAI estándar.
 */
function _getHtmlEncabezado() {
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    const mercado = filtros.mercado || 'Nacional';
    
    return getHtmlEncabezadoBase({
        tituloCorporativo: `
            <span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container rpt-d-none">Consejo de Administración</span>
            <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>`,
        textoBanner1: 'Elecnor',
        textoBanner2: `Contrataciones Significativas Mercado ${mercado}`,
        mes: filtros.mes,
        anio: filtros.anio,
        nroPagina: estado.nroPagina || (mercado === 'Nacional' ? 9 : 10),
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

/**
 * Renderiza la tabla de datos de una Dirección de Negocio.
 * @param {object} direccion - Datos de la dirección.
 * @param {boolean} mostrarHeader - Si debe incluir la fila de literales (Contratación >1M).
 */
function _renderTablaDireccion(direccion, mostrarHeader = true) {
    const dataMes = estado.informeGlobalData?.datosMes || [];
    const dataAnterior = estado.informeGlobalData?.datosMesesAnteriores || [];
    const nombreMes = getNombreMes(estado.informeGlobalData?.meta?.filtros?.mes);
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    const limiteImporte = filtros.limiteImporte || estado.limiteImporte || 1000;
    const valorM = limiteImporte / 1000;
    const labelUmbral = (valorM % 1 === 0) ? `${valorM}M` : `${valorM.toFixed(1)}M`;

    const contratosMes = dataMes.filter(item => item.nombreDirNegocio === direccion.nombreDirNegocio);
    const contratosAnt = dataAnterior.filter(item => item.nombreDirNegocio === direccion.nombreDirNegocio);

    let rowsHtml = `
        <tr>
            <td colspan="4" class="rpt-cont-sig-group-header">
                <span class="rpt-cont-sig-group-title">${escapeHtml(direccion.nombreDirNegocio)}</span>
            </td>
        </tr>
        <tr class="rpt-cont-sig-month-row">
            <td colspan="4" class="rpt-cont-sig-mes-label rpt-font-bold">${escapeHtml(nombreMes)}</td>
        </tr>`;

    rowsHtml += contratosMes.map(item => `
        <tr class="rpt-detail-row">
            <td class="rpt-col-mes-cliente">${escapeHtml(item.nombreCliente_OK.replace(/^ZZ_/, ''))}</td>
            <td class="rpt-col-mes-oferta">${escapeHtml(item.descripcionOferta_OK)}</td>
            <td rpt-border-none></td>
            <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
        </tr>`).join('');

    if (contratosAnt.length > 0) {
        rowsHtml += `
            <tr class="rpt-spacer-row-totales">
                <td colspan="4" class="rpt-spacer-cell-totales"></td>
            </tr>
            <tr class="rpt-cont-sig-anterior-label">
                <td colspan="4" class="rpt-text-muted-gray">Anterior</td>
            </tr>`;
        rowsHtml += contratosAnt.map(item => `
            <tr class="rpt-detail-row rpt-cont-sig-hist-row">
                <td class="rpt-col-mes-cliente">${escapeHtml(item.nombreCliente_OK.replace(/^ZZ_/, ''))}</td>
                <td class="rpt-col-mes-oferta">${escapeHtml(item.descripcionOferta_OK)}</td>
                <td rpt-border-none></td>
                <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
            </tr>`).join('');
    }

    const headerHtml = mostrarHeader ? `
        <thead>
            <tr class="rpt-font-bold">
                <th class="rpt-text-corporate rpt-align-start rpt-ps-3 rpt-fs-11pt">Contratación &gt;${labelUmbral}</th>
                <th></th>
                <th rpt-border-none></th>
                <th class="rpt-text-corporate rpt-align-end rpt-pe-3 rpt-fs-10pt">Mensual</th>
            </tr>
        </thead>` : '';

    return `
        <table class="rpt-table rpt-table-cont-sig">
            <colgroup>
                <col class="rpt-col-mes-cliente">
                <col class="rpt-col-mes-oferta">
                <col class="rpt-col-10px">
                <col class="rpt-col-mes-importe">
            </colgroup>
            ${headerHtml}
            <tbody>
                ${rowsHtml}
            </tbody>
        </table>`;
}

function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

/**
 * Gestión de impresión PDF.
 */
async function _imprimirInforme() {
    const esInternacional = estado.informeGlobalData?.meta?.filtros?.mercado === 'Internacional';

    if (esInternacional) {
        // MODO PDF INTERNACIONAL: Usa Tabla Maestra para repetición de thead corporativo.
        const contenidoHtml = _renderTablaMaestraInternacional();
        const styleVars = getStyleVars(estado.margenes);

        const capaPrint = document.createElement('div');
        capaPrint.className = 'rpt-print-layer';
        capaPrint.innerHTML = `
            <div class="rpt-paper rpt-paper--print" data-informe="contrataciones_significativas" data-mercado="Internacional" ${styleVars}>
                <div class="report-body">
                    ${contenidoHtml}
                </div>
            </div>`;
        document.body.appendChild(capaPrint);

        const originalTitle = document.title;
        try {
            await new Promise(resolve => setTimeout(resolve, 300));
            document.title = '';
            window.print();
        } finally {
            document.title = originalTitle;
            if (document.body.contains(capaPrint)) {
                document.body.removeChild(capaPrint);
            }
        }
    } else {
        // MODO PDF NACIONAL: Implementación "Master Table" para soportar paginación limpia.
        const styleVars = getStyleVars(estado.margenes);
        const contenidoHtml = _renderTablaMaestraNacional();

        const capaPrint = document.createElement('div');
        capaPrint.className = 'rpt-print-layer';
        capaPrint.innerHTML = `
            <div class="rpt-paper rpt-paper--print" data-informe="contrataciones_significativas" data-mercado="Nacional" ${styleVars}>
                <div class="report-body">
                    ${contenidoHtml}
                </div>
            </div>`;
        document.body.appendChild(capaPrint);

        const originalTitle = document.title;
        try {
            await new Promise(resolve => setTimeout(resolve, 300));
            document.title = '';
            window.print();
        } finally {
            document.title = originalTitle;
            if (document.body.contains(capaPrint)) {
                document.body.removeChild(capaPrint);
            }
        }
    }
}

/**
 * Genera la Tabla Maestra exclusiva para el PDF Nacional.
 * Utiliza múltiples tbodies para forzar el salto de página por Dirección de Negocio,
 * repitiendo la cabecera corporativa y los títulos de columna en cada salto de página natural.
 */
function _renderTablaMaestraNacional() {
    const dataArr = estado.informeGlobalData?.datos || [];
    const dataMes = estado.informeGlobalData?.datosMes || [];
    const dataAnterior = estado.informeGlobalData?.datosMesesAnteriores || [];
    const nombreMes = getNombreMes(estado.informeGlobalData?.meta?.filtros?.mes);
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    const mercado = filtros.mercado || 'Nacional';
    const nroPagina = estado.nroPagina || 9;
    const limiteImporte = filtros.limiteImporte || estado.limiteImporte || 1000;
    const valorM = limiteImporte / 1000;
    const labelUmbral = (valorM % 1 === 0) ? `${valorM}M` : `${valorM.toFixed(1)}M`;

    let tbodiesHtml = '';

    dataArr.forEach((direccion, idx) => {
        const contratosMes = dataMes.filter(item => item.nombreDirNegocio === direccion.nombreDirNegocio);
        const contratosAnt = dataAnterior.filter(item => item.nombreDirNegocio === direccion.nombreDirNegocio);

        let rowsHtml = `
            <tr class="rpt-cont-sig-group-start">
                <td colspan="4" class="rpt-cont-sig-group-header">
                    <span class="rpt-cont-sig-group-title">${escapeHtml(direccion.nombreDirNegocio)}</span>
                </td>
            </tr>
            <tr class="rpt-cont-sig-month-row">
                <td colspan="4" class="rpt-cont-sig-mes-label rpt-font-bold">${escapeHtml(nombreMes)}</td>
            </tr>`;

        rowsHtml += contratosMes.map(item => `
            <tr class="rpt-detail-row">
                <td class="rpt-col-mes-cliente">${escapeHtml(item.nombreCliente_OK.replace(/^ZZ_/, ''))}</td>
                <td class="rpt-col-mes-oferta">${escapeHtml(item.descripcionOferta_OK)}</td>
                <td rpt-border-none></td>
                <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
            </tr>`).join('');

        if (contratosAnt.length > 0) {
            rowsHtml += `
                <tr>
                    <td colspan="4" class="rpt-inner-wrapper-cell">
                        <table class="rpt-table rpt-inner-direction-table">
                            <colgroup>
                                <col class="rpt-col-mes-cliente">
                                <col class="rpt-col-mes-oferta">
                                <col class="rpt-col-10px">
                                <col class="rpt-col-mes-importe">
                            </colgroup>
                            <thead>
                                <tr class="rpt-cont-sig-anterior-label">
                                    <td colspan="4" class="rpt-text-muted-gray">Anterior</td>
                                </tr>
                            </thead>
                            <tbody>
                                ${contratosAnt.map(item => `
                                <tr class="rpt-detail-row rpt-cont-sig-hist-row">
                                    <td class="rpt-col-mes-cliente">${escapeHtml(item.nombreCliente_OK.replace(/^ZZ_/, ''))}</td>
                                    <td class="rpt-col-mes-oferta">${escapeHtml(item.descripcionOferta_OK)}</td>
                                    <td rpt-border-none></td>
                                    <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
                                </tr>`).join('')}
                            </tbody>
                        </table>
                    </td>
                </tr>`;
        }

        // Cada dirección va en su propio tbody. Se fuerza salto de página antes (excepto en el primero)
        const pageBreakClass = idx > 0 ? 'rpt-page-break' : '';
        tbodiesHtml += `<tbody class="rpt-group-tbody ${pageBreakClass}">${rowsHtml}</tbody>`;
    });

    return `
        <table class="rpt-table rpt-table-cont-sig rpt-table-print-master">
            <colgroup>
                <col class="rpt-col-mes-cliente">
                <col class="rpt-col-mes-oferta">
                <col class="rpt-col-10px">
                <col class="rpt-col-mes-importe">
            </colgroup>
            <thead class="rpt-print-thead-corporate">
                <tr class="rpt-print-thead-row">
                    <th colspan="4" class="rpt-print-thead-cell">
                        <div class="${RPT_CLASSES.HEADER}">
                            ${estado.mostrarTitulo !== false
                                ? `<div class="rpt-text-corporate rpt-header-corporate-text">
                                       <span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container rpt-d-none">Consejo de Administración</span>
                                       <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>
                                   </div>`
                                : '<div></div>'
                            }
                            <div class="rpt-d-flex rpt-flex-column rpt-align-items-end">
                                ${estado.mostrarNumeroPagina !== false && nroPagina ? `<span class="rpt-page-number">${nroPagina}</span>` : ''}
                                <img src="/images/logoElecnor.png" alt="Logo Elecnor" class="rpt-header-logo">
                            </div>
                        </div>
                        <div class="${RPT_CLASSES.BANNER}">
                            <span>Elecnor</span>
                            <span>Contrataciones Significativas Mercado ${mercado}</span>
                        </div>
                        <div class="${RPT_CLASSES.SUBTITLE}">
                            Cierre de ${getNombreMes(filtros.mes)} ${filtros.anio} | Miles de euros
                        </div>
                    </th>
                </tr>
                <tr class="rpt-font-bold rpt-table-header-columns">
                    <th class="rpt-text-corporate rpt-align-start rpt-ps-3 rpt-fs-11pt">Contratación &gt;${labelUmbral}</th>
                    <th></th>
                    <th rpt-border-none></th>
                    <th class="rpt-text-corporate rpt-align-end rpt-pe-3 rpt-fs-10pt">Mensual</th>
                </tr>
            </thead>
            <tfoot class="rpt-print-tfoot-master">
                <tr><td colspan="4" class="rpt-print-tfoot-cell"></td></tr>
            </tfoot>
            ${tbodiesHtml}
        </table>`;
}

/**
 * Genera la Tabla Maestra exclusiva para el PDF Internacional.
 * Incluye el thead corporativo repetible y el tfoot de margen.
 */
function _renderTablaMaestraInternacional() {
    const dataArr = estado.informeGlobalData?.datos || [];
    const dataMes = estado.informeGlobalData?.datosMes || [];
    const dataAnterior = estado.informeGlobalData?.datosMesesAnteriores || [];
    const nombreMes = getNombreMes(estado.informeGlobalData?.meta?.filtros?.mes);
    const filtros = estado.informeGlobalData?.meta?.filtros || {};
    const mercado = filtros.mercado || 'Internacional';
    const nroPagina = estado.nroPagina || 10;
    const limiteImporte = filtros.limiteImporte || estado.limiteImporte || 1000;
    const valorM = limiteImporte / 1000;
    const labelUmbral = (valorM % 1 === 0) ? `${valorM}M` : `${valorM.toFixed(1)}M`;

    let tbodiesHtml = '';

    dataArr.forEach((direccion) => {
        const contratosMes = dataMes.filter(item => item.nombreDirNegocio === direccion.nombreDirNegocio);
        const contratosAnt = dataAnterior.filter(item => item.nombreDirNegocio === direccion.nombreDirNegocio);

        let rowsHtml = `
            <tr class="rpt-cont-sig-group-start">
                <td colspan="4" class="rpt-cont-sig-group-header">
                    <span class="rpt-cont-sig-group-title">${escapeHtml(direccion.nombreDirNegocio)}</span>
                </td>
            </tr>
            <tr class="rpt-cont-sig-month-row">
                <td colspan="4" class="rpt-cont-sig-mes-label rpt-font-bold">${escapeHtml(nombreMes)}</td>
            </tr>`;

        rowsHtml += contratosMes.map(item => `
            <tr class="rpt-detail-row">
                <td class="rpt-col-mes-cliente">${escapeHtml(item.nombreCliente_OK.replace(/^ZZ_/, ''))}</td>
                <td class="rpt-col-mes-oferta">${escapeHtml(item.descripcionOferta_OK)}</td>
                <td rpt-border-none></td>
                <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
            </tr>`).join('');

        if (contratosAnt.length > 0) {
            rowsHtml += `
                <tr>
                    <td colspan="4" class="rpt-inner-wrapper-cell">
                        <table class="rpt-table rpt-inner-direction-table">
                            <colgroup>
                                <col class="rpt-col-mes-cliente">
                                <col class="rpt-col-mes-oferta">
                                <col class="rpt-col-10px">
                                <col class="rpt-col-mes-importe">
                            </colgroup>
                            <thead>
                                <tr class="rpt-cont-sig-anterior-label">
                                    <td colspan="4" class="rpt-text-muted-gray">Anterior</td>
                                </tr>
                            </thead>
                            <tbody>
                                ${contratosAnt.map(item => `
                                <tr class="rpt-detail-row rpt-cont-sig-hist-row">
                                    <td class="rpt-col-mes-cliente">${escapeHtml(item.nombreCliente_OK.replace(/^ZZ_/, ''))}</td>
                                    <td class="rpt-col-mes-oferta">${escapeHtml(item.descripcionOferta_OK)}</td>
                                    <td rpt-border-none></td>
                                    <td class="rpt-col-mes-importe rpt-number-cell">${formatCurrency(item.importeContratado, 0)}</td>
                                </tr>`).join('')}
                            </tbody>
                        </table>
                    </td>
                </tr>`;
        }

        tbodiesHtml += `<tbody class="rpt-group-tbody">${rowsHtml}</tbody>`;
    });

    return `
        <table class="rpt-table rpt-table-cont-sig rpt-table-print-master">
            <colgroup>
                <col class="rpt-col-mes-cliente">
                <col class="rpt-col-mes-oferta">
                <col class="rpt-col-10px">
                <col class="rpt-col-mes-importe">
            </colgroup>
            <thead class="rpt-print-thead-corporate">
                <tr class="rpt-print-thead-row">
                    <th colspan="4" class="rpt-print-thead-cell">
                        <div class="${RPT_CLASSES.HEADER}">
                            ${estado.mostrarTitulo !== false
                                ? `<div class="rpt-text-corporate rpt-header-corporate-text">
                                       <span class="rpt-text-orange-council rpt-fs-14pt rpt-cmai-titulo-container rpt-d-none">Consejo de Administración</span>
                                       <span class="rpt-cmai-margin-left rpt-cmai-subtitulo rpt-cmai-titulo-container">Informe de Contratación</span>
                                   </div>`
                                : '<div></div>'
                            }
                            <div class="rpt-d-flex rpt-flex-column rpt-align-items-end">
                                ${estado.mostrarNumeroPagina !== false && nroPagina ? `<span class="rpt-page-number">${nroPagina}</span>` : ''}
                                <img src="/images/logoElecnor.png" alt="Logo Elecnor" class="rpt-header-logo">
                            </div>
                        </div>
                        <div class="${RPT_CLASSES.BANNER}">
                            <span>Elecnor</span>
                            <span>Contrataciones Significativas Mercado ${mercado}</span>
                        </div>
                        <div class="${RPT_CLASSES.SUBTITLE}">
                            Cierre de ${getNombreMes(filtros.mes)} ${filtros.anio} | Miles de euros
                        </div>
                    </th>
                </tr>
                <tr class="rpt-font-bold rpt-table-header-columns">
                    <th class="rpt-text-corporate rpt-align-start rpt-ps-3 rpt-fs-11pt">Contratación &gt;${labelUmbral}</th>
                    <th></th>
                    <th rpt-border-none></th>
                    <th class="rpt-text-corporate rpt-align-end rpt-pe-3 rpt-fs-10pt">Mensual</th>
                </tr>
            </thead>
            <tfoot class="rpt-print-tfoot-master">
                <tr><td colspan="4" class="rpt-print-tfoot-cell"></td></tr>
            </tfoot>
            ${tbodiesHtml}
        </table>`;
}
