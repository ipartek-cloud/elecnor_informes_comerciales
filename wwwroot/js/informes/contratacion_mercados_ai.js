/**
 * Módulo para el informe Contratación Mercados AI (Cartera Diferida).
 * Implementa paginación por años con subinforme de mercados AI.
 * 
 * Basado en la metodología unificada de Informes_Subinformes.md (Sección 19)
 */
import { RPT_CLASSES, formatCurrency, formatPercentage, getNombreMes, getMesCorto, getMesAnterior, actualizarEstadoPaginacion, inicializarEventListenersBase, APP_VERSION } from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase, imprimirInformeBase, APP_VERSION as UTILS_VERSION } from './informes_utils.js';
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
export async function ejecutar(anio, mes, nroPagina) {
    try {
        let url = `/api/ContratacionMercadosAI?anio=${anio}&mes=${mes}`;
        if (nroPagina) url += `&nroPagina=${nroPagina}`;
        url += `&_=${Date.now()}`; 

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
        <div class="${RPT_CLASSES.PAPER}" data-anio-index="${index}" role="main">
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
    const nroPagina = estado.informeGlobalData.meta.filtros.nroPagina;

    return `
        ${getHtmlEncabezadoBase({
            tituloCorporativo: '<span class="rpt-text-orange-council fs-3">Consejo de Administración</span> <span class="ms-3 fs-6">Informe de Contratación</span>',
            textoBanner1: 'Elecnor',
            textoBanner2: 'Mercados',
            mes,
            anio,
            nroPagina
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
    await imprimirInformeBase({
        informeGlobalData: estado.informeGlobalData,
        getHtmlEncabezado: _getHtmlEncabezado,
        claveAgrupacion: 'agrupaciones', // Evita que la detección automática coja el array equivocado
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
                        <col style="width:20%;">
                        <col style="width:20%;">
                        <col style="width:20%;">
                        <col style="width:20%;">
                        <col style="width:20%;">
                    </colgroup>
                    <tr class="rpt-detail-row">
                        <td class="rpt-number-cell rpt-pad-right-15">${scaleObjetivo(d.objetivoAnual)}</td>
                        <td class="rpt-number-cell rpt-font-small rpt-pad-right-15" style="color: #999 !important;">${d.pais === 'Nacional' ? '-7%' : '4%'}</td>
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
                <table class="rpt-block-table" style="width: 100%; border-collapse: collapse;">
                    <tr class="rpt-total-row-blue">
                        <td class="rpt-number-cell">&nbsp;</td>
                    </tr>
                </table>
            </div>
            <div class="rpt-block-acumulado">
                <table class="rpt-block-table">
                    <colgroup>
                        <col style="width:20%;">
                        <col style="width:20%;">
                        <col style="width:20%;">
                        <col style="width:20%;">
                        <col style="width:20%;">
                    </colgroup>
                    <tr class="rpt-total-row-blue">
                        <td class="rpt-number-cell rpt-pad-right-15">${scaleObjetivo(agrup.totales.objetivoAnual)}</td>
                        <td class="rpt-number-cell rpt-font-small rpt-pad-right-15" style="color: #999 !important;">-1%</td>
                        <td class="rpt-number-cell rpt-pad-right-15">${scaleContratado(agrup.totales.contratacionAcumulada)}</td>
                        <td class="rpt-number-cell rpt-pad-right-15">${formatCurrency(agrup.totales.indiceProduccion / 1000, 2)}</td>
                        <td class="rpt-number-cell">${agrup.totales.variacionContratacion}</td>
                    </tr>
                </table>
            </div>
        </div>
    `;

    return `
        <div class="rpt-triple-container mt-4 mb-0" style="align-items: flex-end;">
            <div class="rpt-block-mensual">
                <div class="fw-bold rpt-font-small rpt-text-corporate text-center mb-1">Mensual</div>
                <table class="rpt-block-table">
                    <thead>
                        <tr class="rpt-th-blue" style="border-top: none;">
                            <th class="rpt-number-cell w-50 pe-3 pb-1" style="border-top: none;">Objet.</th>
                            <th class="rpt-number-cell w-50 pe-4 pb-1" style="border-top: none;">Contr.</th>
                        </tr>
                    </thead>
                </table>
            </div>
            <div class="rpt-block-labels text-center" style="margin-bottom: 2px;">
                <div class="rpt-label-blue-header">Mercado</div>
            </div>
            <div class="rpt-block-acumulado">
                <div class="fw-bold rpt-font-small rpt-text-corporate text-center mb-1">Acumulado</div>
                <table class="rpt-block-table">
                    <colgroup>
                        <col style="width:20%;">
                        <col style="width:20%;">
                        <col style="width:20%;">
                        <col style="width:20%;">
                        <col style="width:20%;">
                    </colgroup>
                    <thead>
                        <tr class="rpt-th-blue" style="border-top: none;">
                            <th class="rpt-number-cell rpt-pad-right-15 pb-1" style="border-top: none;">Objet.</th>
                            <th class="rpt-number-cell rpt-pad-right-15 pb-1" style="border-top: none; color: #999 !important;">Var/${agrup.año - 1}</th>
                            <th class="rpt-number-cell rpt-pad-right-15 pb-1" style="border-top: none;">Contr.</th>
                            <th class="rpt-number-cell rpt-pad-right-15 pb-1" style="border-top: none;">Ip</th>
                            <th class="rpt-number-cell pb-1" style="border-top: none;">Var/${agrup.año - 1}</th>
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
                <col style="width: 100px;">
                <col style="width: 25px;">
                <col style="width: 315px;">
                <col style="width: 30px;">
                <col style="width: 100px;">
                <col style="width: 100px;">
                <col style="width: 100px;">
            </colgroup>
            <thead>
                <tr style="height: 20px;">
                    <th>Mensual</th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th colspan="3">Acumulado</th>
                </tr>
                <tr class="rpt-border-header" style="height: 18px;">
                    <th class="text-end">Contr.</th>
                    <th style="border: none !important;"></th>
                    <th style="text-align: center;">Asociado Inversión</th>
                    <th style="border: none !important;"></th>
                    <th class="text-end">Contr</th>
                    <th class="text-end">% s/Merc</th>
                    <th class="text-end">Var/2025</th>
                </tr>
            </thead>
            <tbody>
                ${subMercados.map(s => `
                    <tr style="height: 18px;">
                        <td class="text-end" data-label="Mensual Contr.">${val(s.importeContratadoMensual)}</td>
                        <td style="border: none !important;"></td>
                        <td class="ps-2" data-label="Asociado Inversión">${s.mercado.trim()}</td>
                        <td style="border: none !important;"></td>
                        <td class="text-end" data-label="Acum. Contr.">${val(s.importeContratadoAcumulado)}</td>
                        <td class="text-end" data-label="% s/Merc">${formatPercentage(s.porcentajeSobreMercado)}</td>
                        <td class="text-end" data-label="Var/2025">${s.variacion}</td>
                    </tr>
                `).join('')}
            </tbody>
            <tfoot>
                <tr class="fw-bold rpt-text-corporate" style="height: 18px;">
                    <td class="text-end rpt-td-total" data-label="Total Mensual">${val(totales.contratacionMensual)}</td>
                    <td style="border: none !important;"></td>
                    <td class="rpt-td-total"></td>
                    <td style="border: none !important;"></td>
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
                <col style="width: 100px;">
                <col style="width: 25px;">
                <col style="width: 315px;">
                <col style="width: 30px;">
                <col style="width: 150px;">
                <col style="width: 150px;">
            </colgroup>

                    <thead>
                        <tr style="height: 20px;">
                            <th class="text-center" style="border: none !important;">Cart.</th>
                            <th style="border: none !important;"></th>
                            <th style="border: none !important;"></th>
                            <th style="border: none !important;"></th>
                            <th colspan="2" class="text-center" style="border: none !important;">Cartera</th>
                        </tr>
                        <tr class="rpt-border-header" style="height: 18px;">
                            <th class="text-end" style="border-top: none;">${data.tituloColInicial}</th>
                            <th style="border: none !important;"></th>
                            <th style="border: none !important; padding: 0;"><div class="rpt-label-blue-header" style="width: 100%;">Cartera Producción</div></th>
                            <th style="border: none !important;"></th>
                            <th class="text-end" style="border-top: none;">${data.tituloColActual}</th>
                            <th class="text-end" style="border-top: none;">${data.tituloColDelta}</th>
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
                                <tr style="height: 18px;">
                                    <td class="text-end ${isIndented ? 'rpt-text-grey' : ''}" data-label="${data.tituloColInicial}">${showInitial}</td>
                                    <td style="border: none !important;"></td>
                                    <td class="ps-2 ${labelClass}" data-label="Concepto">${cleanConcept}</td>
                                    <td style="border: none !important;"></td>
                                    <td class="text-end ${isIndented ? 'rpt-text-grey' : ''}" data-label="${data.tituloColActual}">${showActual}</td>
                                    <td class="text-end ${isIndented ? 'rpt-text-grey' : ''}" data-label="${data.tituloColDelta}">${showVar}</td>
                                </tr>
                            `;
                        }).join('')}
                    </tbody>
                    <tfoot>
                        <tr class="fw-bold fs-7 rpt-text-corporate" style="height: 18px;">
                            <td class="text-end rpt-td-total" data-label="Total ${data.tituloColInicial}">${val(totales.importeInicial)}</td>
                            <td style="border: none !important;"></td>
                            <td class="rpt-td-total"></td>
                            <td style="border: none !important;"></td>
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

    // Mapeo directo a slots fijos (1.1.25, 2025, 2026, 2027) según requerimiento de layout estático
    const getVals = (l) => {
        return { 
            v1_1: l.cart1_1 || l.Cart1_1 || 0,
            v25: l.anio1 || l.Anio1 || 0,
            v26: l.anio2 || l.Anio2 || 0,
            v27: l.anio3 || l.Anio3 || 0
        };
    };

    const t = getVals(totales);
    const sumaTotalCartera = (t.v25 + t.v26 + t.v27);

    return `
        <table class="rpt-table-triple rpt-table-stackable">

            <colgroup>
                <col style="width: 80px;">
                <col style="width: 80px;">
                <col style="width: 80px;">
                <col style="width: 15px;">
                <col style="width: 390px;">
                <col style="width: 15px;">
                <col style="width: 80px;">
                <col style="width: 45px;">
                <col style="width: 65px;">
                <col style="width: 65px;">
                <col style="width: 65px;">
            </colgroup>

                    <thead>
                        <tr style="height: 20px;">
                            <th colspan="3" class="text-center" style="border: none !important;">Cart.</th>
                            <th style="border: none !important;"></th>
                            <th style="border: none !important;"></th>
                            <th style="border: none !important;"></th>
                            <th style="border: none !important;"></th>
                            <th style="border: none !important;"></th>
                            <th colspan="3" class="text-center" style="border: none !important;">Cartera Pendiente</th>
                        </tr>
                        <tr class="rpt-border-header" style="height: 18px;">
                            <th class="text-end">1.1.25</th>
                            <th class="text-end">Nuevos *</th>
                            <th class="text-end">Total</th>
                            <th style="border: none !important;"></th>
                            <th style="border: none !important; padding: 0;"><div class="rpt-label-blue-header" style="width: 100%;">Cartera Diferida</div></th>
                            <th style="border: none !important;"></th>
                            <th class="text-end">Contr.</th>
                            <th class="text-end">Ip</th>
                            <th class="text-end">2025</th>
                            <th class="text-end">2026</th>
                            <th class="text-end">2027</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${data.lineas.map(l => {
                            const v = getVals(l);
                            return `
                                <tr style="height: 18px;">
                                    <td class="text-end" data-label="1.1.25">${val(v.v1_1)}</td>
                                    <td class="text-end" data-label="Nuevos *">${val(l.nuevos)}</td>
                                    <td class="text-end" data-label="Total">${val(l.total)}</td>
                                    <td style="border: none !important;"></td>
                                    <td class="ps-2" data-label="Cartera Diferida">${l.concepto.trim()}</td>
                                    <td style="border: none !important;"></td>
                                    <td class="text-end" data-label="Contr.">${val(l.contr)}</td>
                                    <td class="text-end" data-label="Ip">${l.total === 0 ? '####' : formatCurrency(l.ip, 2)}</td>
                                    <td class="text-end" data-label="2025">${val(v.v25)}</td>
                                    <td class="text-end" data-label="2026">${val(v.v26)}</td>
                                    <td class="text-end" data-label="2027">${val(v.v27)}</td>
                                </tr>
                            `;
                        }).join('')}
                    </tbody>
                    <tfoot>
                        <tr class="fw-bold fs-7 rpt-text-corporate" style="height: 18px;">
                            <td class="text-end rpt-td-total" data-label="Total 1.1.25">${val(t.v1_1)}</td>
                            <td class="text-end rpt-td-total" data-label="Total Nuevos">${val(totales.nuevos)}</td>
                            <td class="text-end rpt-td-total" data-label="Total Total">${val(totales.total)}</td>
                            <td style="border: none !important;"></td>
                            <td class="rpt-td-total"></td>
                            <td style="border: none !important;"></td>
                            <td class="text-end rpt-td-total" data-label="Total Contr.">${val(totales.contr)}</td>
                            <td class="text-end rpt-td-total" data-label="Total Ip">${totales.total === 0 ? '####' : formatCurrency(totales.ip, 2)}</td>
                            <td class="text-end rpt-td-total" data-label="Total 2025">${val(t.v25)}</td>
                            <td class="text-end rpt-td-total" data-label="Total 2026">${val(t.v26)}</td>
                            <td class="text-end rpt-td-total" data-label="Total 2027">${val(t.v27)}</td>
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
