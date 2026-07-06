/**
 * Informe "Actividades x DN" (CD_Elecnor_DG_Activ_Redes).
 * Variante de Actividades SDG filtrada por CodDirNegocio. Sin Objetivos ni IP.
 */
import { RPT_CLASSES, formatCurrency, getVarClass,
         actualizarEstadoPaginacion, inicializarEventListenersBase }
    from './utils.js';
import { crearEstadoInforme, inicializarInforme, getHtmlEncabezadoBase,
         imprimirInformeUnificado, getStyleVars, MARGENES_ESTANDAR }
    from './informes_unificados_utils.js';

const estado = crearEstadoInforme();

export async function ejecutar({ anio, mes, nroPagina, codSubDir, codDirNegocio, mostrarTitulo }) {
    try {
        const url = `/api/CD_Elecnor_DG_Activ_Redes?anio=${anio}&mes=${mes}&subdireccion=${codSubDir || ''}&codDirNegocio=${codDirNegocio || '500'}&_=${Date.now()}`;

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
        console.error("Error al ejecutar informe Actividades x DN:", error);
        throw error;
    }
}

function _renderizarPagina() {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    container.innerHTML = `
        <div class="${RPT_CLASSES.PAPER}" data-informe="CD_Elecnor_DG_Activ_Redes"
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
    const bannerText = subdireccion === '286' ? 'D.G. Elecnor Proyectos' : 'S.G. Instalaciones y Redes';

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

function _renderContenidoCompleto() {
    const data = estado.informeGlobalData;
    if (!data || !data.secciones) return '';

    const seccionPrincipal = data.secciones[0];
    const subinformes = data.secciones.slice(1);

    return `
        <div class="rpt-adn-layout">
            <div class="rpt-adn-col-izq">
                ${_renderSeccion(seccionPrincipal, 0)}
            </div>
            <div class="rpt-adn-col-der">
                ${subinformes.map((s, i) => _renderSeccion(s, i + 1)).join('')}
            </div>
        </div>
    `;
}

function _renderSeccion(seccion, index) {
    const anioAnterior = estado.informeGlobalData.meta.filtros.anio - 1;
    const varClass = getVarClass(seccion.variacionContratacion);

    const esPrimera = (index === 0);

    let badgeHtml = '';
    if (seccion.MercadoBadge || seccion.mercadoBadge) {
        badgeHtml = `
        <div class="rpt-as-badge-container">
            <span class="rpt-as-badge">${seccion.MercadoBadge || seccion.mercadoBadge}</span>
        </div>`;
    }

    // Encabezado: primera sección sin texto, subinformes sin badge
    let headerRowHtml = '';
    if (esPrimera) {
        headerRowHtml = `
        <tr class="rpt-as-column-headers-row">
            <th class="rpt-align-start rpt-fs-8pt rpt-text-corporate rpt-as-cabecera-vacia"></th>
            <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Contr.</th>
            <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Var/${anioAnterior}</th>
        </tr>`;
    } else {
        headerRowHtml = `
        <tr class="rpt-as-column-headers-row">
            <th class="rpt-align-start rpt-fs-8pt rpt-text-corporate rpt-as-cabecera-vacia"></th>
            <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Contr.</th>
            <th class="rpt-align-end rpt-fs-8pt rpt-text-corporate">Var/${anioAnterior}</th>
        </tr>`;
    }

    return `
    <div class="rpt-as-seccion">
        ${badgeHtml}
        <table class="rpt-table rpt-as-tabla rpt-w-100">
            <colgroup>
                <col class="rpt-as-col-actividad">
                <col class="rpt-as-col-contr">
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
                    <td colspan="3" class="rpt-spacer-cell-totales"></td>
                </tr>
                <tr class="rpt-as-total-row">
                    <td class="rpt-align-start rpt-as-total-label">Total</td>
                    <td class="rpt-number-cell" data-label="Total Contr.">${formatCurrency(seccion.totalContrat, 0)}</td>
                    <td class="rpt-align-end ${varClass}" data-label="Total Var.">${seccion.variacionContratacion}</td>
                </tr>
            </tfoot>
        </table>
    </div>`;
}

function _renderActividad(actividad) {
    const anioAnterior = estado.informeGlobalData.meta.filtros.anio - 1;
    const varClass = getVarClass(actividad.variacionContratacion);
    const tieneSub = actividad.subActividades && actividad.subActividades.length > 0;

    return `
    ${_renderFilaActividad(actividad, varClass, anioAnterior)}
    ${tieneSub ? actividad.subActividades.map(s => _renderSubActividad(s, anioAnterior)).join('') : ''}
    `;
}

function _renderFilaActividad(a, varClass, anioAnterior) {
    return `
    <tr class="rpt-as-actividad-row">
        <td class="rpt-as-actividad-cell" data-label="Actividad">${a.actividad}</td>
        <td class="rpt-number-cell" data-label="Contr.">${formatCurrency(a.totalContrat, 0)}</td>
        <td class="rpt-align-end ${varClass}" data-label="Var.">${a.variacionContratacion}</td>
    </tr>`;
}

function _renderSubActividad(s, anioAnterior) {
    const varClass = getVarClass(s.variacionContratacion);

    return `
    <tr class="rpt-as-subactividad-row">
        <td class="rpt-as-subactividad-cell" data-label="Sub-actividad">
            ${s.subActividad}
        </td>
        <td class="rpt-number-cell" data-label="Contr.">${formatCurrency(s.totalContrat, 0)}</td>
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
        nombreInforme: 'CD_Elecnor_DG_Activ_Redes'
    });
}
