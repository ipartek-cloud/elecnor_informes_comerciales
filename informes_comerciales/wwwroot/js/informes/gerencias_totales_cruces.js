/**
 * Módulo para el informe Gerencias Totales Cruces.
 * Implementa una máquina de estados de paginación lógica en cliente:
 *   - Un Gerente = Una Página en el modal.
 *   - Impresión PDF: se renderiza todo el informe, se imprime y se restaura la página actual.
 * 
 * Basado en la metodología unificada de Informes_Subinformes.md (Sección 19)
 */
import { RPT_CLASSES, formatCurrency, getNombreMes, getMesCorto, actualizarEstadoPaginacion, inicializarEventListenersBase, APP_VERSION } from './utils.js';
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
export async function ejecutar(anio, mes, nroPagina) {
    try {
        let url = `/api/GerenciasTotalesCruces?anio=${anio}&mes=${mes}`;
        if (nroPagina) url += `&nroPagina=${nroPagina}`;
        url += `&_=${Date.now()}`; // Cache buster (Regla de Oro #9)

        await inicializarInforme({
            url,
            estado,
            renderizarPagina: _renderizarPagina,
            inicializarEventListeners: _registrarEventos,
            prefijoPaginacion: 'Gerencia'
        });
    } catch (error) {
        throw error; // El manager lo capturará
    }
}

// ===============================================================================
// FUNCIONES DE RENDERIZADO (específicas del informe)
// ===============================================================================

/**
 * Renderiza la gerencia del índice indicado en el contenedor del modal.
 */
function _renderizarPagina(index) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    container.innerHTML = '';

    const gerente = estado.informeGlobalData.gerentes[index];
    const mesCorto = getMesCorto(estado.informeGlobalData.meta.filtros.mes - 1);

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="gerencias_totales_cruces" data-gerente-index="${index}" role="main">
            ${_getHtmlEncabezado(gerente.nombreGerente)}
            <div class="report-body">
                ${renderSeccionGerente(gerente, mesCorto)}
            </div>
        </div>
    `;

    container.scrollTop = 0;
    actualizarEstadoPaginacion(estado.paginaActual, estado.paginasTotales, 'Gerencia');
}

/**
 * Obtiene el encabezado HTML con el nombre de la gerencia.
 * Acepta tanto un objeto gerente (cuando la llama imprimirInformeBase pasando el item)
 * como un string (cuando la llama _renderizarPagina con gerente.nombreGerente).
 * @param {object|string} itemONombre - Objeto gerente o string con el nombre
 */
function _getHtmlEncabezado(itemONombre = '') {
    const mes = estado.informeGlobalData.meta.filtros.mes;
    const anio = estado.informeGlobalData.meta.filtros.anio;
    const nroPagina = estado.informeGlobalData.meta.filtros.nroPagina;

    // Si recibe un objeto (llamado desde imprimirInformeBase), extrae el nombre del gerente.
    // Si recibe un string (llamado desde _renderizarPagina), lo usa directamente.
    const nombreGerencia = (typeof itemONombre === 'object' && itemONombre !== null)
        ? (itemONombre.nombreGerente || '')
        : itemONombre;

    const encabezadoBase = getHtmlEncabezadoBase({
        tituloCorporativo: '<span class="rpt-text-orange-council fs-3">Consejo de Administración</span> <span class="ms-3 fs-6">Informe de Contratación</span>',
        textoBanner1: 'Elecnor',
        textoBanner2: 'Gerencias',
        mes,
        anio,
        nroPagina
    });

    return nombreGerencia ? `
        ${encabezadoBase}
        <h4 class="rpt-gerente-name">${nombreGerencia}</h4>
    ` : encabezadoBase;
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
        renderContenido: (gerente) => {
            const mesCorto = getMesCorto(estado.informeGlobalData.meta.filtros.mes - 1);
            return renderSeccionGerente(gerente, mesCorto, true);
        }
    });
}

// ===============================================================================
// FUNCIONES DE RENDERIZADO HTML (específicas del negocio)
// ===============================================================================

/**
 * Renderiza la sección completa de una gerencia.
 * @param {boolean} esImpresion - Si true, elimina divs decorativos que añaden márgenes innecesarios en PDF.
 */
function renderSeccionGerente(gerente, mesCorto, esImpresion = false) {
    return `
        <div class="mb-5">
            ${gerente.direccionesNegocio.map(dn => renderDireccionNegocio(dn, mesCorto, esImpresion)).join('')}
            ${renderTotalGerente(gerente, esImpresion)}
        </div>
    `;
}

/**
 * Renderiza el total de una gerencia.
 */
function renderTotalGerente(gerente, esImpresion = false) {
    const tableHtml = `
        <table class="rpt-table rpt-table-stackable fw-bold">
            <colgroup>
                <col class="rpt-col-80">
                <col class="rpt-col-80">
                <col class="rpt-col-250">
                <col class="rpt-col-90">
                <col class="rpt-col-90">
                <col class="rpt-col-60">
                <col class="rpt-col-70">
                <col class="rpt-col-70">
            </colgroup>
            <tr>
                <td class="rpt-number-cell pe-3 rpt-td-total" data-label="Mensual Objet.">${formatCurrency(gerente.totalesGerente.objetivoMensual)}</td>
                <td class="rpt-number-cell pe-4 rpt-td-total" data-label="Mensual Contr.">${formatCurrency(gerente.totalesGerente.contratacionMensual)}</td>
                <td class="text-start ps-4 rpt-text-corporate fw-bold rpt-td-total" data-label="Concepto"></td>
                <td class="rpt-number-cell pe-3 rpt-td-total" data-label="Acum. Objet.">${formatCurrency(gerente.totalesGerente.objetivoAnual)}</td>
                <td class="rpt-number-cell pe-3 rpt-td-total" data-label="Acum. Contr.">${formatCurrency(gerente.totalesGerente.contratacionAcumulada)}</td>
                <td class="rpt-number-cell rpt-td-total" data-label="IP">${formatCurrency(gerente.totalesGerente.indiceProduccion, 2)}</td>
                <td class="rpt-number-cell rpt-td-total" data-label="Var. Contr.">${gerente.totalesGerente.variacionContratacion || '0%'}</td>
                <td class="rpt-number-cell rpt-td-total" data-label="Var. Cart.">${gerente.totalesGerente.variacionCartera || '0%'}</td>
            </tr>
        </table>
    `;

    return esImpresion ? tableHtml : `<div class="mt-3">${tableHtml}</div>`;
}

/**
 * Renderiza una dirección de negocio con sus centros.
 */
function renderDireccionNegocio(dn, mesCorto, esImpresion = false) {
    const centrosContent = dn.centros && dn.centros.length > 0
        ? dn.centros.map(c => `
            <tr class="rpt-detail-row">
                <td class="rpt-number-cell pe-3">${formatCurrency(c.objetivosMensual)}</td>
                <td class="rpt-number-cell pe-4">${formatCurrency(c.contratacionMensual)}</td>
                <td class="ps-4 rpt-col-centro">
                    <span class="rpt-text-dark">${c.codCentro}</span>
                    <span class="rpt-text-dark">${c.nombreCentro}</span>
                </td>
                <td class="rpt-number-cell pe-3">${formatCurrency(c.objetivosAcumulado)}</td>
                <td class="rpt-number-cell pe-3">${formatCurrency(c.contratacionAcumulada)}</td>
                <td class="rpt-number-cell">${formatCurrency(c.ip, 2)}</td>
                <td class="rpt-number-cell">${c.variacionContratacion}</td>
                <td class="rpt-number-cell">${c.variacionCartera}</td>
            </tr>
        `).join('')
        : '<tr><td colspan="8" class="text-center text-muted py-3">Sin datos</td></tr>';

    const anioComparacion = estado.informeGlobalData?.meta?.filtros?.anio
        ? estado.informeGlobalData.meta.filtros.anio - 1
        : (new Date()).getFullYear() - 1;

    const tableHtml = `
        <table class="rpt-table rpt-table-stackable">
            <colgroup>
                <col class="rpt-col-80">
                <col class="rpt-col-80">
                <col class="rpt-col-250">
                <col class="rpt-col-90">
                <col class="rpt-col-90">
                <col class="rpt-col-60">
                <col class="rpt-col-70">
                <col class="rpt-col-70">
            </colgroup>
            <thead>
                <tr class="fw-bold">
                    <th colspan="2" class="text-center rpt-label-blue">Mensual</th>
                    <th></th>
                    <th colspan="3" class="text-center rpt-label-blue">Acumulado</th>
                    <th colspan="2" class="text-center rpt-label-blue">Var/${anioComparacion}</th>
                </tr>
                <tr class="fw-bold rpt-th-middle">
                    <th class="rpt-number-cell pe-3 rpt-th-blue">Objet.</th>
                    <th class="rpt-number-cell pe-4 rpt-th-blue">Contr.</th>
                    <th class="text-center">
                        <div class="rpt-group-badge">${dn.nombreDirNegocio}</div>
                    </th>
                    <th class="rpt-number-cell pe-3 rpt-th-blue">Objet.</th>
                    <th class="rpt-number-cell pe-3 rpt-th-blue">Contr.</th>
                    <th class="rpt-number-cell rpt-th-blue">Ip</th>
                    <th class="rpt-number-cell rpt-th-blue">Contr.</th>
                    <th class="rpt-number-cell rpt-th-blue">Cart. ${mesCorto ? `(${mesCorto})` : ''}</th>
                </tr>
            </thead>
            <tbody>
                ${dn.centros && dn.centros.length > 0 ? dn.centros.map(c => `
                    <tr class="rpt-detail-row">
                        <td class="rpt-number-cell pe-3" data-label="Mensual Objet.">${formatCurrency(c.objetivosMensual)}</td>
                        <td class="rpt-number-cell pe-4" data-label="Mensual Contr.">${formatCurrency(c.contratacionMensual)}</td>
                        <td class="ps-4 rpt-col-centro text-start" data-label="Centro">
                            <span class="rpt-text-dark">${c.codCentro}</span>
                            <span class="rpt-text-dark">${c.nombreCentro}</span>
                        </td>
                        <td class="rpt-number-cell pe-3" data-label="Acum. Objet.">${formatCurrency(c.objetivosAcumulado)}</td>
                        <td class="rpt-number-cell pe-3" data-label="Acum. Contr.">${formatCurrency(c.contratacionAcumulada)}</td>
                        <td class="rpt-number-cell" data-label="IP">${formatCurrency(c.ip, 2)}</td>
                        <td class="rpt-number-cell" data-label="Var. Contr.">${c.variacionContratacion}</td>
                        <td class="rpt-number-cell" data-label="Var. Cart.">${c.variacionCartera}</td>
                    </tr>
                `).join('') : '<tr><td colspan="8" class="text-center text-muted py-3">Sin datos</td></tr>'}
            </tbody>
            <tfoot class="fw-bold">
                <tr>
                    <td class="rpt-number-cell pe-3 rpt-td-total" data-label="Total Mensual Objet.">${formatCurrency(dn.totalesDireccion.objetivoMensual)}</td>
                    <td class="rpt-number-cell pe-4 rpt-td-total" data-label="Total Mensual Contr.">${formatCurrency(dn.totalesDireccion.contratacionMensual)}</td>
                    <td class="rpt-td-total" data-label="Concepto"></td>
                    <td class="rpt-number-cell pe-3 rpt-td-total" data-label="Total Acum. Objet.">${formatCurrency(dn.totalesDireccion.objetivoAnual)}</td>
                    <td class="rpt-number-cell pe-3 rpt-td-total" data-label="Total Acum. Contr.">${formatCurrency(dn.totalesDireccion.contratacionAcumulada)}</td>
                    <td class="rpt-number-cell rpt-td-total" data-label="Total IP">${formatCurrency(dn.totalesDireccion.indiceProduccion, 2)}</td>
                    <td class="rpt-number-cell rpt-td-total" data-label="Total Var. Contr.">${dn.totalesDireccion.variacionContratacion || '0%'}</td>
                    <td class="rpt-number-cell rpt-td-total" data-label="Total Var. Cart.">${dn.totalesDireccion.variacionCartera || '0%'}</td>
                </tr>
            </tfoot>
        </table>
    `;

    return esImpresion ? tableHtml : `<div class="mb-4">${tableHtml}</div>`;
}

// ===============================================================================
// FIN DEL MÓDULO
// ===============================================================================
