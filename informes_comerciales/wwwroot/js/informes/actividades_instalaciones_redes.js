/**
 * Informe "Actividades SDG" (Elecnor Servicios / Elecnor Proyectos).
 * 3 secciones paralelas (DG / Nacional / Internacional) estilo Access.
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
        const url = `/api/ActividadesInstalacionesRedes?anio=${anio}&mes=${mes}&subdireccion=${codSubDir || ''}&_=${Date.now()}`;

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
        console.error("Error al ejecutar informe Actividades SDG:", error);
        throw error;
    }
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="actividades_instalaciones_redes"
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
    const bannerText = subdireccion === '286' ? 'D.G. Elecnor Proyectos' : 'D.G. Elecnor Servicios';

    return getHtmlEncabezadoBase({
        tituloCorporativo: 'Informe de Contratación',
        textoBanner1: bannerText,
        textoBanner2: 'Actividades',
        mes: estado.informeGlobalData?.meta?.filtros?.mes,
        anio: estado.informeGlobalData?.meta?.filtros?.anio,
        nroPagina: estado.nroPagina,
        mostrarNumeroPagina: estado.mostrarNumeroPagina,
        mostrarTitulo: estado.mostrarTitulo
    });
}

function _formatIp(val) {
    if (val === null || val === undefined) return "0,00";
    const num = Number(val);
    if (isNaN(num)) return "0,00";
    return num.toLocaleString('es-ES', { 
        minimumFractionDigits: 2, 
        maximumFractionDigits: 2,
        useGrouping: true 
    });
}

function _renderContenidoCompleto() {
    const data = estado.informeGlobalData;
    if (!data || !data.secciones) return '';

    return `
        <div class="rpt-as-wrap">
            ${data.secciones.map((s, index) => _renderSeccion(s, index)).join('')}
        </div>
    `;
}

function _renderSeccion(seccion, index) {
    const anioAnterior = estado.informeGlobalData.meta.filtros.anio - 1;
    const ipClass = getIpClass(seccion.ip);
    const varClass = getVarClass(seccion.variacionContratacion);

    const esPrimera = (index === 0);
    const esTercera = (index === 2);

    let badgeHtml = '';
    if (!esPrimera) {
        badgeHtml = `
        <div class="rpt-as-badge-container">
            <span class="rpt-as-badge">${seccion.MercadoBadge || seccion.mercadoBadge}</span>
        </div>`;
    }

    let headerRowHtml = '';
    if (esPrimera) {
        headerRowHtml = `
        <tr class="rpt-as-column-headers-row">
            <th class="rpt-align-start rpt-fs-8pt rpt-text-corporate">
                <div class="rpt-as-cabecera-actividad-container">
                    <span class="rpt-as-titulo-actividad">Actividad</span>
                    <span class="rpt-as-badge-inline">${seccion.MercadoBadge || seccion.mercadoBadge}</span>
                </div>
            </th>
            <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Obj.</th>
            <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Contr.</th>
            <th class="rpt-align-center rpt-fs-8pt rpt-text-corporate">Ip</th>
            <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Var/${anioAnterior}</th>
        </tr>`;
    }

    return `
    <div class="rpt-as-seccion">
        ${badgeHtml}
        <table class="rpt-table rpt-as-tabla rpt-w-100">
            <colgroup>
                <col class="rpt-as-col-actividad">
                <col class="rpt-as-col-obj">
                <col class="rpt-as-col-contr">
                <col class="rpt-as-col-ip">
                <col class="rpt-as-col-var">
            </colgroup>
            <thead>
                ${headerRowHtml}
            </thead>
            <tbody>
                ${seccion.actividades.map(a => _renderActividad(a)).join('')}
            </tbody>
            <tfoot class="rpt-font-bold">
                <tr class="rpt-spacer-row-totales">
                    <td colspan="5" class="rpt-spacer-cell-totales"></td>
                </tr>
                <tr class="rpt-as-total-row">
                    <td class="rpt-align-start rpt-as-total-label">Total</td>
                    <td class="rpt-number-cell" data-label="Total Obj.">${formatCurrency(seccion.totalObjetivos, 0)}</td>
                    <td class="rpt-number-cell" data-label="Total Contr.">${formatCurrency(seccion.totalContrat, 0)}</td>
                    <td class="rpt-number-cell rpt-align-center ${ipClass}" data-label="Total IP">${_formatIp(seccion.ip)}</td>
                    <td class="rpt-align-end ${varClass}" data-label="Total Var.">${seccion.variacionContratacion}</td>
                </tr>
            </tfoot>
        </table>
    </div>`;
}

function _renderActividad(actividad) {
    const anioAnterior = estado.informeGlobalData.meta.filtros.anio - 1;
    const ipClass = getIpClass(actividad.ip);
    const varClass = getVarClass(actividad.variacionContratacion);
    const tieneSub = actividad.subActividades && actividad.subActividades.length > 0;

    return `
    ${_renderFilaActividad(actividad, ipClass, varClass, anioAnterior)}
    ${tieneSub ? actividad.subActividades.map(s => _renderSubActividad(s, anioAnterior)).join('') : ''}
    `;
}

function _renderFilaActividad(a, ipClass, varClass, anioAnterior) {
    return `
    <tr class="rpt-as-actividad-row">
        <td class="rpt-as-actividad-cell" data-label="Actividad">${a.actividad}</td>
        <td class="rpt-number-cell" data-label="Obj.">${formatCurrency(a.totalObjetivos, 0)}</td>
        <td class="rpt-number-cell" data-label="Contr.">${formatCurrency(a.totalContrat, 0)}</td>
        <td class="rpt-number-cell rpt-align-center ${ipClass}" data-label="IP">${_formatIp(a.ip)}</td>
        <td class="rpt-align-end ${varClass}" data-label="Var.">${a.variacionContratacion}</td>
    </tr>`;
}

function _renderSubActividad(s, anioAnterior) {
    const ipClass = getIpClass(s.ip);
    const varClass = getVarClass(s.variacionContratacion);

    return `
    <tr class="rpt-as-subactividad-row">
        <td class="rpt-as-subactividad-cell" data-label="Sub-actividad">
            ${s.subActividad}
        </td>
        <td class="rpt-number-cell" data-label="Obj.">${formatCurrency(s.totalObjetivos, 0)}</td>
        <td class="rpt-number-cell" data-label="Contr.">${formatCurrency(s.totalContrat, 0)}</td>
        <td class="rpt-number-cell rpt-align-center ${ipClass}" data-label="IP">${_formatIp(s.ip)}</td>
        <td class="rpt-align-end ${varClass}" data-label="Var.">${s.variacionContratacion}</td>
    </tr>`;
}

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
        nombreInforme: 'actividades_instalaciones_redes'
    });
}
