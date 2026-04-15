/**
 * Módulo para el informe Cartera Diferida Consejo.
 * Implementa paginación por años con subinforme de mercados AI.
 * 
 * Basado en la metodología unificada de Informes_Subinformes.md (Sección 19)
 */
import { RPT_CLASSES, formatCurrency, formatPercentage, getNombreMes, getMesCorto, getMesAnterior, actualizarEstadoPaginacion, inicializarEventListenersBase, APP_VERSION } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeUnificado, APP_VERSION as UTILS_VERSION } from './informes_unificados_utils.js';
import { ApiClient } from '../site.js';

// ===============================================================================
// ESTADO GLOBAL DEL MÓDULO (usar factory function)
// ===============================================================================
const estado = crearEstadoInforme();

// ===============================================================================
// PUNTO DE ENTRADA (llamado por informes_manager.js)
// ===============================================================================

/**
 * Inicializa o actualiza el informe para el año/mes indicados.
 * Usa inicializarInforme() de informes_utils.js para máxima reutilización.
 */
export async function ejecutar(anio, mes, nroPagina, mostrarTitulo) {
    try {
        let url = `/api/CarteraDiferidaConsejo?anio=${anio}&mes=${mes}`;
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
            prefijoPaginacion: 'Año',
            claveAgrupacion: 'agrupaciones'
        });
    } catch (error) {
        throw error; // El manager lo capturará
    }
}

// ===============================================================================
// FUNCIONES DE RENDERIZADO (específicas del informe)
// ===============================================================================

/**
 * Renderiza el año del índice indicado en el contenedor del modal.
 */
function _renderizarPagina(index) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    container.innerHTML = '';

    const agrupacion = estado.informeGlobalData.agrupaciones[index];

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="cartera_diferida_consejo" data-anio-index="${index}" role="main">
            ${_getHtmlEncabezado()}
            <div class="report-body">
                ${_renderTripleBlock(agrupacion)}
                <div class="rpt-sub-report-wrapper d-flex flex-column align-items-center">
                    ${agrupacion.subMercadosAI?.length > 0 ? `
                        <div class="rpt-sub-report-container">
                            ${_renderSubsetTripleBlock(agrupacion)}
                        </div>
                    ` : ''}
                    ${agrupacion.carteraProduccion?.lineas?.length > 0 ? `
                        <div class="rpt-sub-report-container w-100 rpt-cmai-mt-medium">
                            ${_renderCarteraProduccion(agrupacion)}
                        </div>
                    ` : ''}
                    ${agrupacion.carteraDiferida?.lineas?.length > 0 ? `
                        <div class="rpt-sub-report-container w-100 rpt-cmai-mt-medium">
                            ${_renderCarteraDiferida(agrupacion)}
                        </div>
                    ` : ''}
                    ${agrupacion.ventas?.lineas?.length > 0 ? `
                        <div class="rpt-sub-report-container w-100 rpt-cmai-mt-huge">
                            ${_renderVentas(agrupacion)}
                        </div>
                    ` : ''}
                </div>

            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(estado.paginaActual, estado.paginasTotales, 'Año');
}

/**
 * Obtiene el encabezado HTML específico para este informe.
 */
function _getHtmlEncabezado() {
    const mes = estado.informeGlobalData.meta.filtros.mes;
    const anio = estado.informeGlobalData.meta.filtros.anio;

    return `
        ${getHtmlEncabezadoBase({
            tituloCorporativo: '<span class="rpt-text-orange-council fs-3">Consejo de Administración</span> <span class="ms-3 fs-6">Informe de Contratación</span>',
            textoBanner1: 'Elecnor',
            textoBanner2: 'Mercados',
            mes,
            anio,
            nroPagina: estado.nroPagina || 1,
            mostrarNumeroPagina: estado.mostrarNumeroPagina,
            mostrarTitulo: estado.mostrarTitulo
        })}
    `;
}

/**
 * Registra los event listeners usando la función base compartida.
 */
function _registrarEventos() {
    inicializarEventListenersBase(estado, _renderizarPagina, _imprimirInforme);
}

// ===============================================================================
// IMPRESIÓN PDF
// ===============================================================================

/**
 * Genera la capa de impresión para todo el informe.
 */
async function _imprimirInforme() {
    await imprimirInformeUnificado({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        modoAgrupacion: 'agrupaciones', // Evita que la detección automática coja el array equivocado
        renderContenido: (agrupacion) => {
            return _renderTripleBlock(agrupacion) +
                ((agrupacion.subMercadosAI?.length > 0 || agrupacion.carteraProduccion?.lineas?.length > 0 || agrupacion.carteraDiferida?.lineas?.length > 0) ? `
                    <div class="rpt-sub-report-wrapper d-flex flex-column align-items-center">
                        ${agrupacion.subMercadosAI?.length > 0 ? `
                            <div class="rpt-sub-report-container">
                                ${_renderSubsetTripleBlock(agrupacion)}
                            </div>
                        ` : ''}
                        ${agrupacion.carteraProduccion?.lineas?.length > 0 ? `
                            <div class="rpt-sub-report-container w-100 rpt-cmai-mt-medium">
                                ${_renderCarteraProduccion(agrupacion)}
                            </div>
                        ` : ''}
                        ${agrupacion.carteraDiferida?.lineas?.length > 0 ? `
                            <div class="rpt-sub-report-container w-100 rpt-cmai-mt-medium">
                                ${_renderCarteraDiferida(agrupacion)}
                            </div>
                        ` : ''}
                        ${agrupacion.ventas?.lineas?.length > 0 ? `
                            <div class="rpt-sub-report-container w-100 rpt-cmai-mt-huge">
                                ${_renderVentas(agrupacion)}
                            </div>
                        ` : ''}
                    </div>
                ` : '');

        }
    });
}

// ===============================================================================
// FUNCIONES DE RENDERIZADO DE NEGOCIO (específicas de este informe)
// ===============================================================================

/**
 * Renderiza el bloque triple (Mensual | Labels | Acumulado) del informe principal.
 */
function _renderTripleBlock(agrup) {
    const scaleObjetivo = (val) => formatCurrency(val || 0, 0);
    const scaleContratado = (val) => formatCurrency((val || 0) / 1000, 0);
    const mesCorto = getMesAnterior(estado.informeGlobalData.meta.filtros.mes);

    const rowsHtml = agrup.detalles.map(d => `
        <div class="rpt-triple-container">
            <div class="rpt-block-mensual">
                <table class="rpt-block-table">
                    <tr class="rpt-detail-row">
                        <td class="rpt-number-cell w-50 pe-3">${scaleObjetivo(d.objetivoMensual)}</td>
                        <td class="rpt-number-cell w-50 pe-4">${scaleContratado(d.importeContratadoMensual)}</td>
                    </tr>
                </table>
            </div>
            <div class="rpt-block-labels">
                <div class="rpt-label-row-data">${d.pais}</div>
            </div>
            <div class="rpt-block-acumulado">
                <table class="rpt-block-table">
                    <colgroup>
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                    </colgroup>
                    <tr class="rpt-detail-row">
                        <td class="rpt-number-cell rpt-pad-right-15">${scaleObjetivo(d.objetivoAnual)}</td>
                        <td class="rpt-number-cell rpt-font-small rpt-pad-right-15" rpt-text-muted-value>${d.pais === 'Nacional' ? '-7%' : '4%'}</td>
                        <td class="rpt-number-cell rpt-pad-right-15">${scaleContratado(d.importeContratadoAcumulado)}</td>
                        <td class="rpt-number-cell rpt-pad-right-15">${formatCurrency(d.indiceProduccion / 1000, 2)}</td>
                        <td class="rpt-number-cell">${d.variacion}</td>
                    </tr>
                </table>
            </div>
        </div>
    `).join('');

    const totalesHtml = `
        <div class="rpt-triple-container mt-1">
            <div class="rpt-block-mensual">
                <table class="rpt-block-table">
                    <tr class="rpt-total-row-blue">
                        <td class="rpt-number-cell w-50 pe-3">${scaleObjetivo(agrup.totales.objetivoMensual)}</td>
                        <td class="rpt-number-cell w-50 pe-4">${scaleContratado(agrup.totales.contratacionMensual)}</td>
                    </tr>
                </table>
            </div>
            <div class="rpt-block-labels">
                <table class="rpt-block-table rpt-table-full-collapse">
                    <tr class="rpt-total-row-blue">
                        <td class="rpt-number-cell">&nbsp;</td>
                    </tr>
                </table>
            </div>
            <div class="rpt-block-acumulado">
                <table class="rpt-block-table">
                    <colgroup>
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                    </colgroup>
                    <tr class="rpt-total-row-blue">
                        <td class="rpt-number-cell rpt-pad-right-15">${scaleObjetivo(agrup.totales.objetivoAnual)}</td>
                        <td class="rpt-number-cell rpt-font-small rpt-pad-right-15" rpt-text-muted-value>-1%</td>
                        <td class="rpt-number-cell rpt-pad-right-15">${scaleContratado(agrup.totales.contratacionAcumulada)}</td>
                        <td class="rpt-number-cell rpt-pad-right-15">${formatCurrency(agrup.totales.indiceProduccion / 1000, 2)}</td>
                        <td class="rpt-number-cell">${agrup.totales.variacionContratacion}</td>
                    </tr>
                </table>
            </div>
        </div>
    `;

    return `
        <div class="rpt-triple-container mt-4 mb-0 rpt-align-flex-end">
            <div class="rpt-block-mensual">
                <div class="fw-bold rpt-font-small rpt-text-corporate text-center mb-1">Mensual</div>
                <table class="rpt-block-table">
                    <thead>
                        <tr class="rpt-th-blue" rpt-border-top-none>
                            <th class="rpt-number-cell w-50 pe-3 pb-1" rpt-border-top-none>Objet.</th>
                            <th class="rpt-number-cell w-50 pe-4 pb-1" rpt-border-top-none>Contr.</th>
                        </tr>
                    </thead>
                </table>
            </div>
            <div class="rpt-block-labels text-center rpt-mb-2">
                <div class="rpt-label-blue-header">Mercado</div>
            </div>
            <div class="rpt-block-acumulado">
                <div class="fw-bold rpt-font-small rpt-text-corporate text-center mb-1">Acumulado</div>
                <table class="rpt-block-table">
                    <colgroup>
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                        <col class="rpt-col-width-20">
                    </colgroup>
                    <thead>
                        <tr class="rpt-th-blue" rpt-border-top-none>
                            <th class="rpt-number-cell rpt-pad-right-15 pb-1" rpt-border-top-none>Objet.</th>
                            <th class="rpt-number-cell rpt-pad-right-15 pb-1 rpt-border-top-none rpt-text-muted-value">Var/${agrup.año - 1}</th>
                            <th class="rpt-number-cell rpt-pad-right-15 pb-1" rpt-border-top-none>Contr.</th>
                            <th class="rpt-number-cell rpt-pad-right-15 pb-1" rpt-border-top-none>Ip</th>
                            <th class="rpt-number-cell pb-1" rpt-border-top-none>Var/${agrup.año - 1}</th>
                        </tr>
                    </thead>
                </table>
            </div>
        </div>
        ${rowsHtml}
        ${totalesHtml}
    `;
}



/**
 * Renderiza el subinforme de mercados AI (bloque triple unificado en una tabla).
 */
function _renderSubsetTripleBlock(agrup) {
    if (!agrup.subMercadosAI || agrup.subMercadosAI.length === 0) return '';

    const val = (v) => formatCurrency(v || 0, 0);
    const subMercados = agrup.subMercadosAI;
    const totales = agrup.totalesAI;

    return `
        <table class="rpt-table-triple rpt-table-stackable">
            <colgroup>
                <col class="rpt-col-100px">
                <col class="rpt-col-25px">
                <col class="rpt-col-315px">
                <col class="rpt-col-30px">
                <col class="rpt-col-100px">
                <col class="rpt-col-100px">
                <col class="rpt-col-100px">
            </colgroup>
            <thead>
                <tr rpt-row-height-20>
                    <th>Mensual</th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th colspan="3">Acumulado</th>
                </tr>
                <tr class="rpt-border-header" rpt-row-height-18>
                    <th class="text-end">Contr.</th>
                    <th rpt-border-none></th>
                    <th class="rpt-inline-center">Asociado Inversión</th>
                    <th rpt-border-none></th>
                    <th class="text-end">Contr</th>
                    <th class="text-end">% s/Merc</th>
                    <th class="text-end">Var/${agrup.año - 1}</th>
                </tr>
            </thead>
            <tbody>
                ${subMercados.map(s => `
                    <tr rpt-row-height-18>
                        <td class="text-end" data-label="Mensual Contr.">${val(s.importeContratadoMensual)}</td>
                        <td rpt-border-none></td>
                        <td class="ps-2" data-label="Asociado Inversión">${s.mercado.trim()}</td>
                        <td rpt-border-none></td>
                        <td class="text-end" data-label="Acum. Contr.">${val(s.importeContratadoAcumulado)}</td>
                        <td class="text-end" data-label="% s/Merc">${formatPercentage(s.porcentajeSobreMercado)}</td>
                        <td class="text-end" data-label="Var/${agrup.año - 1}">${s.variacion}</td>
                    </tr>
                `).join('')}
            </tbody>
            <tfoot>
                <tr class="fw-bold rpt-text-corporate" rpt-row-height-18>
                    <td class="text-end rpt-td-total" data-label="Total Mensual">${val(totales.contratacionMensual)}</td>
                    <td rpt-border-none></td>
                    <td class="rpt-td-total"></td>
                    <td rpt-border-none></td>
                    <td class="text-end rpt-td-total" data-label="Total Acumulado">${val(totales.contratacionAcumulada)}</td>
                    <td class="text-end rpt-td-total" data-label="Total %">${formatPercentage(totales.porcentajeSobreMercado)}</td>
                    <td class="text-end rpt-td-total" data-label="Total Var.">${totales.variacionCartera || ''}</td>
                </tr>
            </tfoot>
        </table>
    `;
}


/**
 * Renderiza el subinforme de Cartera Producción (bloque triple unificado).
 */
function _renderCarteraProduccion(agrup) {
    if (!agrup.carteraProduccion || !agrup.carteraProduccion.lineas || agrup.carteraProduccion.lineas.length === 0) return '';

    const data = agrup.carteraProduccion;
    const val = (v) => formatCurrency(v || 0, 0);
    const totales = data.totales;

    return `
        <table class="rpt-table-triple rpt-table-stackable">
            <colgroup>
                <col class="rpt-col-100px">
                <col class="rpt-col-25px">
                <col class="rpt-col-315px">
                <col class="rpt-col-30px">
                <col class="rpt-col-150px">
                <col class="rpt-col-150px">
            </colgroup>

                    <thead>
                        <tr rpt-row-height-20>
                            <th class="text-center" rpt-border-none>Cart.</th>
                            <th rpt-border-none></th>
                            <th rpt-border-none></th>
                            <th rpt-border-none></th>
                            <th colspan="2" class="text-center" rpt-border-none>Cartera</th>
                        </tr>
                        <tr class="rpt-border-header" rpt-row-height-18>
                            <th class="text-end" rpt-border-top-none>${data.tituloColInicial}</th>
                            <th rpt-border-none></th>
                            <th class="rpt-border-none rpt-pad-0"><div class="rpt-label-blue-header rpt-w-100">Cartera Producción</div></th>
                            <th rpt-border-none></th>
                            <th class="text-end" rpt-border-top-none>${data.tituloColActual}</th>
                            <th class="text-end" rpt-border-top-none>${data.tituloColDelta}</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${data.lineas.map(l => {
                            const cleanConcept = l.concepto.trim();
                            const isIndented = l.isIndented;

                            const showInitial = val(l.importeInicial);
                            const showActual = (l.importeActual === 0) ? '' : val(l.importeActual);
                            const showVar = (l.porcentajeIncremento === null || l.porcentajeIncremento === 0) ? '' : formatPercentage(l.porcentajeIncremento);

                            const labelClass = isIndented ? 'ps-4 rpt-text-grey' : '';

                            return `
                                <tr rpt-row-height-18>
                                    <td class="text-end ${isIndented ? 'rpt-text-grey' : ''}" data-label="${data.tituloColInicial}">${showInitial}</td>
                                    <td rpt-border-none></td>
                                    <td class="ps-2 ${labelClass}" data-label="Concepto">${cleanConcept}</td>
                                    <td rpt-border-none></td>
                                    <td class="text-end ${isIndented ? 'rpt-text-grey' : ''}" data-label="${data.tituloColActual}">${showActual}</td>
                                    <td class="text-end ${isIndented ? 'rpt-text-grey' : ''}" data-label="${data.tituloColDelta}">${showVar}</td>
                                </tr>
                            `;
                        }).join('')}
                    </tbody>
                    <tfoot>
                        <tr class="fw-bold fs-7 rpt-text-corporate" rpt-row-height-18>
                            <td class="text-end rpt-td-total" data-label="Total ${data.tituloColInicial}">${val(totales.importeInicial)}</td>
                            <td rpt-border-none></td>
                            <td class="rpt-td-total"></td>
                            <td rpt-border-none></td>
                            <td class="text-end rpt-td-total" data-label="Total ${data.tituloColActual}">${val(totales.importeActual)}</td>
                            <td class="text-end rpt-td-total" data-label="Variación">${totales.variacionCartera || ''}</td>
                        </tr>
                        <tr class="fs-8 rpt-text-corporate">
                            <td class="text-end py-1" data-label="Variación Anual">
                                Δ / ${agrup.año - 1} <span class="fw-bold">${totales.variacionAñoAnterior || ''}</span>
                            </td>
                            <td colspan="5" class="d-none d-print-table-cell"></td>
                        </tr>
                    </tfoot>
                </table>
    `;
}



/**
 * Renderiza el subinforme de Cartera Diferida (bloque triple unificado).
 */
function _renderCarteraDiferida(agrup) {
    if (!agrup.carteraDiferida || !agrup.carteraDiferida.lineas || agrup.carteraDiferida.lineas.length === 0) return '';

    const data = agrup.carteraDiferida;
    const val = (v) => formatCurrency(v || 0, 0);
    const totales = data.totales;
    const anioSel = agrup.año;

    // Acceso a propiedades semánticas del DTO con fallback triple (nuevo → DTO → legacy)
    const getVals = (l) => ({
        v1_1: l.valorCart1_1 ?? l.ValorCart1_1 ?? l.cart1_1 ?? l.Cart1_1 ?? 0,
        nuevos: l.nuevos ?? l.Nuevos ?? 0,
        total: l.total ?? l.Total ?? 0,
        contr: l.contr ?? l.Contr ?? 0,
        ip: l.ip ?? l.Ip ?? 0,
        v1: l.valorAnio1 ?? l.ValorAnio1 ?? l.anio1 ?? l.Anio1 ?? 0,
        v2: l.valorAnio2 ?? l.ValorAnio2 ?? l.anio2 ?? l.Anio2 ?? 0,
        v3: l.valorAnio3 ?? l.ValorAnio3 ?? l.anio3 ?? l.Anio3 ?? 0
    });

    const t = getVals(totales);
    const sumaTotalCartera = (t.v1 + t.v2 + t.v3);

    return `
        <table class="rpt-table-triple rpt-table-stackable rpt-table-cd">

            <colgroup>
                <col class="rpt-col-80px">
                <col class="rpt-col-80px">
                <col class="rpt-col-80px">
                <col class="rpt-col-15px">
                <col class="rpt-col-390px">
                <col class="rpt-col-15px">
                <col class="rpt-col-80px">
                <col class="rpt-col-45px">
                <col class="rpt-col-65px">
                <col class="rpt-col-65px">
                <col class="rpt-col-65px">
            </colgroup>

                    <thead>
                        <tr rpt-row-height-20>
                            <th colspan="3" class="text-center" rpt-border-none>Cart.</th>
                            <th rpt-border-none></th>
                            <th rpt-border-none></th>
                            <th rpt-border-none></th>
                            <th rpt-border-none></th>
                            <th rpt-border-none></th>
                            <th colspan="3" class="text-center" rpt-border-none>Cartera Pendiente</th>
                        </tr>
                        <tr class="rpt-border-header" rpt-row-height-18>
                            <th class="text-end">${data.tituloColInicial}</th>
                            <th class="text-end">Nuevos *</th>
                            <th class="text-end">Total</th>
                            <th rpt-border-none></th>
                            <th class="rpt-border-none rpt-pad-0"><div class="rpt-label-blue-header rpt-w-100">Cartera Diferida</div></th>
                            <th rpt-border-none></th>
                            <th class="text-end">Contr.</th>
                            <th class="text-end">Ip</th>
                            <th class="text-end">${data.tituloColAnio1}</th>
                            <th class="text-end">${data.tituloColAnio2}</th>
                            <th class="text-end">${data.tituloColAnio3}</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${data.lineas.map(l => {
                            const v = getVals(l);
                            return `
                                <tr rpt-row-height-18>
                                    <td class="text-end" data-label="${data.tituloColInicial}">${val(v.v1_1)}</td>
                                    <td class="text-end" data-label="Nuevos *">${val(v.nuevos)}</td>
                                    <td class="text-end" data-label="Total">${val(v.total)}</td>
                                    <td rpt-border-none></td>
                                    <td class="ps-2" data-label="Cartera Diferida">${l.concepto.trim()}</td>
                                    <td rpt-border-none></td>
                                    <td class="text-end" data-label="Contr.">${val(v.contr)}</td>
                                    <td class="text-end" data-label="Ip">${l.total === 0 ? '####' : formatCurrency(v.ip, 2)}</td>
                                    <td class="text-end" data-label="${data.tituloColAnio1}">${val(v.v1)}</td>
                                    <td class="text-end" data-label="${data.tituloColAnio2}">${val(v.v2)}</td>
                                    <td class="text-end" data-label="${data.tituloColAnio3}">${val(v.v3)}</td>
                                </tr>
                            `;
                        }).join('')}
                    </tbody>
                    <tfoot>
                        <tr class="fw-bold fs-7 rpt-text-corporate" rpt-row-height-18>
                            <td class="text-end rpt-td-total" data-label="Total ${data.tituloColInicial}">${val(t.v1_1)}</td>
                            <td class="text-end rpt-td-total" data-label="Total Nuevos">${val(t.nuevos)}</td>
                            <td class="text-end rpt-td-total" data-label="Total Total">${val(t.total)}</td>
                            <td rpt-border-none></td>
                            <td class="rpt-td-total"></td>
                            <td rpt-border-none></td>
                            <td class="text-end rpt-td-total" data-label="Total Contr.">${val(t.contr)}</td>
                            <td class="text-end rpt-td-total" data-label="Total Ip">${t.total === 0 ? '####' : formatCurrency(t.ip, 2)}</td>
                                <td class="text-end rpt-td-total" data-label="Total ${data.tituloColAnio1}">${val(t.v1)}</td>
                            <td class="text-end rpt-td-total" data-label="Total ${data.tituloColAnio2}">${val(t.v2)}</td>
                            <td class="text-end rpt-td-total" data-label="Total ${data.tituloColAnio3}">${val(t.v3)}</td>
                        </tr>
                    </tfoot>
                </table>
        <div class="d-flex justify-content-between rpt-cma-footer-container rpt-font-small text-nowrap">
            <div class="rpt-cma-footer-note">* Contratos nuevos, reapreciación de Cartera y prórrogas</div>
            <div class="rpt-cma-footer-total rpt-text-corporate fw-bold">Total Cartera Pendiente: <span class="ms-1">${val(sumaTotalCartera)}</span></div>
        </div>
    `;
}



// ===============================================================================
// FIN DEL MÓDULO
// ===============================================================================

/**
 * Renderiza el subinforme de Ventas (tabla horizontal de años 2017-2025).
 * Diseño según Imagen 2 (perfecto):
 *   - "Ventas" en la primera celda del thead (badge gris)
 *   - Bordes reducidos (solo líneas horizontales sutiles)
 *   - Detalle siempre blanco
 *   - Totales con fondo según plan
 */
function _renderVentas(agrupacion) {
    if (!agrupacion.ventas || !agrupacion.ventas.lineas || agrupacion.ventas.lineas.length === 0) return '';
    
    const v = (n) => formatCurrency(n || 0, 1);
    const lineas = agrupacion.ventas.lineas;
    const totales = agrupacion.ventas.totales;

    // Buscamos las filas específicas por mercado
    const internacional = lineas.find(l => l.mercado.toLowerCase() === 'internacional') || {};
    const nacional = lineas.find(l => l.mercado.toLowerCase() === 'nacional') || {};

    const getBgClass = (anio) => {
        const a = parseInt(anio);
        if (a >= 2017 && a <= 2019) return 'rpt-ventas-bg-pe1';
        if (a >= 2020 && a <= 2022) return 'rpt-ventas-bg-pe2';
        if (a >= 2023 && a <= 2025) return 'rpt-ventas-bg-pe3';
        return '';
    };

    const anios = [2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025];

    return `
        <div class="rpt-ventas-container rpt-cmai-mt-medium">
            <div class="text-end mb-1 rpt-ventas-unit">Millones de euros</div>
            <table class="rpt-ventas-table">
                <thead>
                    <tr>
                        <th class="rpt-ventas-title-cell">
                            <div class="rpt-ventas-badge">Ventas</div>
                        </th>
                        ${anios.map(a => `<th class="${getBgClass(a)} text-center">${a}</th>`).join('')}
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td class="rpt-ventas-row-label">Internacional</td>
                        ${anios.map(a => `<td class="text-end">${v(internacional[`anio${a}`])}</td>`).join('')}
                    </tr>
                    <tr>
                        <td class="rpt-ventas-row-label">Nacional</td>
                        ${anios.map(a => `<td class="text-end">${v(nacional[`anio${a}`])}</td>`).join('')}
                    </tr>
                </tbody>
                <tfoot>
                    <tr class="rpt-ventas-total-row">
                        <td class="rpt-ventas-row-label">Total</td>
                        ${anios.map(a => `<td class="text-end ${getBgClass(a)}"><strong>${v(totales[`total${a}`])}</strong></td>`).join('')}
                    </tr>
                </tfoot>
            </table>
            
            <div class="rpt-ventas-legend rpt-cmai-mt-medium d-flex gap-4">
                <div class="d-flex align-items-center gap-1">
                    <div class="rpt-ventas-sq rpt-ventas-bg-pe1"></div>
                    <span>Plan Estratégico 2017-2019</span>
                </div>
                <div class="d-flex align-items-center gap-1">
                    <div class="rpt-ventas-sq rpt-ventas-bg-pe2"></div>
                    <span>Plan Estratégico 2020-2022</span>
                </div>
            </div>
        </div>`;
}
