/**
 * Módulo para el informe Gerencias Totales Cruces.
 * Implementa una máquina de estados de paginación lógica en cliente:
 *   - Un Gerente = Una Página en el modal.
 *   - Impresión PDF: se renderiza todo el informe, se imprime y se restaura la página actual.
 */
import { GlobalUI, ApiClient } from '../site.js';
import { formatCurrency } from './utils.js';

// ===============================================================================
// CONSTANTES DE CLASES CSS (evitar literales hardcoded)
// ===============================================================================
const HEADER_CLASSES    = 'rpt-header';
const BANNER_CLASSES    = 'rpt-banner-top mb-1';
const SUBTITLE_CLASSES  = 'rpt-subtitle';
const GERENTE_TITLE_CLASSES = 'rpt-gerente-name';

// ===============================================================================
// ESTADO GLOBAL DEL MÓDULO (persiste entre llamadas gracias al Module Registry)
// ===============================================================================
let informeGlobalData  = null;  // JSON completo recibido de la API
let paginaActual       = 0;     // Índice base-0 de la gerencia visible
let paginasTotales     = 0;     // = informeGlobalData.gerentes.length
let eventosIniciados   = false; // Flag: previene la duplicación de addEventListener

// ===============================================================================
// PUNTO DE ENTRADA (llamado por informes_manager.js)
// ===============================================================================

/**
 * Inicializa o actualiza el informe para el año/mes indicados.
 * Gracias al Module Registry, este export se llama sobre el MISMO módulo
 * en sucesivas aperturas del modal, garantizando que `eventosIniciados`
 * mantenga su valor entre llamadas y nunca se dupliquen los listeners.
 */
export async function ejecutar(anio, mes) {
    try {
        const resp = await ApiClient.get(`/api/GerenciasTotalesCruces?anio=${anio}&mes=${mes}`);

        if (resp.ok) {
            const data = await resp.json();

            // --- Sin datos ---
            if (!data.gerentes || data.gerentes.length === 0) {
                _mostrarSinDatos(data, anio);
                _ocultarControlesPaginacion();
                _abrirModal(data.meta?.titulo || 'Gerencias Totales Cruces');
                return;
            }

            // --- Inicializar estado global ---
            informeGlobalData = data;
            paginaActual      = 0;
            paginasTotales    = data.gerentes.length;

            // Actualizar título del modal
            const modalTitle = document.getElementById('modalInformeTitulo');
            if (modalTitle) modalTitle.innerText = data.meta.titulo;

            // Renderizar primera página
            _renderizarPagina(0);

            // Mostrar controles de paginación (solo si hay más de 1 gerente)
            if (paginasTotales > 1) {
                _mostrarControlesPaginacion();
            } else {
                _ocultarControlesPaginacion();
            }

            // Registrar event listeners UNA SOLA VEZ
            _inicializarEventListeners();

            // Abrir modal
            _abrirModal();
        }
    } catch (error) {
        throw error; // El manager lo capturará y mostrará el alert
    }
}

// ===============================================================================
// LÓGICA DE PAGINACIÓN
// ===============================================================================

/**
 * Renderiza la gerencia del índice indicado en el contenedor del modal.
 * Limpia el contenido previo antes de inyectar el nuevo HTML.
 */
function _renderizarPagina(index) {
    if (!informeGlobalData) return;
    if (index < 0 || index >= paginasTotales) {
        console.error(`[GerenciasTotalesCruces] Índice de página inválido: ${index}`);
        return;
    }

    const contentContainer = document.getElementById('modalInformeContenido');
    if (!contentContainer) return;

    // CRÍTICO: limpiar para evitar acumulación de contenido
    contentContainer.innerHTML = '';

    const gerente  = informeGlobalData.gerentes[index];
    const mesCorto = _getMesCorto(informeGlobalData.meta.filtros.mes - 1);
    const nombreMes = _getNombreMes(informeGlobalData.meta.filtros.mes);

    contentContainer.innerHTML = `
        <div class="rpt-paper" data-gerente-index="${index}" role="main">
            ${_getHtmlEncabezado(gerente.nombreGerente)}
            <div class="report-body">
                ${renderSeccionGerente(gerente, mesCorto)}
            </div>
        </div>
    `;

    // UX: volver al inicio del contenedor al cambiar página
    contentContainer.scrollTop = 0;

    // Sincronizar estado visual de los botones
    _actualizarEstadoUI();
}

/**
 * Actualiza el texto y el estado disabled/aria de los controles de paginación.
 */
function _actualizarEstadoUI() {
    const btnAnterior  = document.getElementById('btnPagAnterior');
    const btnSiguiente = document.getElementById('btnPagSiguiente');
    const lblEstado    = document.getElementById('lblEstadoPaginacion');

    if (!btnAnterior || !btnSiguiente || !lblEstado) return;

    lblEstado.textContent = `Gerencia ${paginaActual + 1} de ${paginasTotales}`;

    const esPrimera = (paginaActual === 0);
    const esUltima  = (paginaActual === paginasTotales - 1);

    btnAnterior.disabled  = esPrimera;
    btnSiguiente.disabled = esUltima;
    btnAnterior.setAttribute('aria-disabled',  esPrimera.toString());
    btnSiguiente.setAttribute('aria-disabled', esUltima.toString());

    const numAnterior = paginaActual > 0 ? paginaActual : 'primera';
    const numSiguiente = paginaActual < paginasTotales - 1 ? paginaActual + 2 : 'última';
    btnAnterior.setAttribute('aria-label',  `Ir a gerencia anterior (${numAnterior})`);
    btnSiguiente.setAttribute('aria-label', `Ir a siguiente gerencia (${numSiguiente})`);
}

// ===============================================================================
// REGISTRO DE EVENT LISTENERS (se ejecuta solo una vez gracias al flag)
// ===============================================================================

/**
 * CRÍTICO 1 - Solución:
 * Al usar el Module Registry en informes_manager.js, este módulo persiste en memoria
 * entre aperturas del modal. El flag `eventosIniciados` también persiste, por lo que
 * garantiza que los addEventListener solo se registren una vez durante toda la sesión.
 */
function _inicializarEventListeners() {
    if (eventosIniciados) return;

    const btnAnterior  = document.getElementById('btnPagAnterior');
    const btnSiguiente = document.getElementById('btnPagSiguiente');
    const btnPdf       = document.getElementById('btnExportarPdf');

    if (btnAnterior) {
        btnAnterior.addEventListener('click', () => {
            if (paginaActual > 0) {
                paginaActual--;
                _renderizarPagina(paginaActual);
            }
        });
    }

    if (btnSiguiente) {
        btnSiguiente.addEventListener('click', () => {
            if (paginaActual < paginasTotales - 1) {
                paginaActual++;
                _renderizarPagina(paginaActual);
            }
        });
    }

    if (btnPdf) {
        btnPdf.addEventListener('click', _imprimirInforme);
    }

    eventosIniciados = true;
}

// ===============================================================================
// IMPRESIÓN PDF (CRÍTICO 2 + IMPORTANTE 3)
// ===============================================================================

/**
 * Renderiza el encabezado corporativo (Logo, Banner, Subtítulo) y el nombre de la gerencia.
 */
function _getHtmlEncabezado(nombreGerencia = '') {
    const mes    = informeGlobalData.meta.filtros.mes;
    const anio   = informeGlobalData.meta.filtros.anio;
    const nombre = _getNombreMes(mes);

    return `
        <!-- Logo y Tipo -->
        <div class="${HEADER_CLASSES}">
            <div class="rpt-text-corporate rpt-header-corporate-text">Informe de Contratación</div>
            <img src="/images/logoElecnor.png" alt="Logo Elecnor" class="rpt-header-logo">
        </div>
        <!-- Banner Azul -->
        <div class="${BANNER_CLASSES}">
            <span>Elecnor</span>
            <span>Gerencias</span>
        </div>
        <!-- Subtítulo -->
        <div class="${SUBTITLE_CLASSES}">
            Cierre de ${nombre} ${anio} | Miles de euros
        </div>
        ${nombreGerencia ? `
        <!-- Nombre de Gerencia (Recurrente en la impresión) -->
        <h4 class="${GERENTE_TITLE_CLASSES}">
            ${nombreGerencia}
        </h4>
        ` : ''}
    `;
}

/**
 * IMPRESIÓN PDF:
 * Estructura de tabla con múltiples filas (una por DN) para forzar la repetición
 * del `thead` en cada página física cuando una gerencia es muy larga.
 */
async function _imprimirInforme() {
    if (!informeGlobalData) return;

    // Crear capa de impresión
    const capaPrint = document.createElement('div');
    capaPrint.id    = 'rpt-print-layer';
    capaPrint.className = 'rpt-print-layer';

    const mesCorto = _getMesCorto(informeGlobalData.meta.filtros.mes - 1);

    // Generar bloque por cada Gerente
    const htmlGerentes = informeGlobalData.gerentes.map((g, idx) => {
        // En impresión, renderizamos las secciones sin los div wrappers decorativos de pantalla
        const contentHtml = g.direccionesNegocio.map(dn => renderDireccionNegocio(dn, mesCorto, true)).join('');
        const totalHtml   = renderTotalGerente(g, true);

        return `
            <div class="${idx < informeGlobalData.gerentes.length - 1 ? 'rpt-page-break' : ''}">
                <table class="rpt-print-table">
                    <thead class="rpt-print-header">
                        <tr>
                            <td class="rpt-print-td-flat">
                                ${_getHtmlEncabezado(g.nombreGerente)}
                            </td>
                        </tr>
                    </thead>
                    <tbody class="rpt-print-body">
                        <tr>
                            <td class="rpt-print-td-main">
                                ${contentHtml}
                                ${totalHtml}
                            </td>
                        </tr>
                    </tbody>
                    <tfoot class="rpt-print-footer">
                        <tr>
                            <td class="rpt-print-td-flat"></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        `;
    }).join('');

    capaPrint.innerHTML = htmlGerentes;

    document.body.appendChild(capaPrint);
    const originalTitle = document.title;

    try {
        await new Promise(resolve => setTimeout(resolve, 200));
        document.title = ""; 
        window.print();
    } finally {
        document.title = originalTitle;
        if (document.body.contains(capaPrint)) {
            document.body.removeChild(capaPrint);
        }
    }
}

// ===============================================================================
// FUNCIONES DE RENDERIZADO HTML (reutilizadas tanto en paginación como en impresión)
// ===============================================================================

function renderSeccionGerente(gerente, mesCorto) {
    return `
        <div class="mb-5">
            ${gerente.direccionesNegocio.map(dn => renderDireccionNegocio(dn, mesCorto)).join('')}
            ${renderTotalGerente(gerente)}
        </div>
    `;
}

function renderTotalGerente(gerente, esImpresion = false) {
    const tableHtml = `
            <table class="rpt-table fw-bold">
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
                    <td class="rpt-number-cell pe-3 rpt-td-total">${formatCurrency(gerente.totalesGerente.totalObjetivoMensual)}</td>
                    <td class="rpt-number-cell pe-4 rpt-td-total">${formatCurrency(gerente.totalesGerente.totalContratacionMensual)}</td>
                    <td class="text-start ps-4 rpt-text-corporate fw-bold rpt-td-total">Total</td>
                    <td class="rpt-number-cell pe-3 rpt-td-total">${formatCurrency(gerente.totalesGerente.totalObjetivoAcumulado)}</td>
                    <td class="rpt-number-cell pe-3 rpt-td-total">${formatCurrency(gerente.totalesGerente.totalContratacionAcumulada)}</td>
                    <td class="rpt-number-cell rpt-td-total">${formatCurrency(gerente.totalesGerente.ipMedia, 2)}</td>
                    <td class="rpt-number-cell rpt-td-total">${gerente.totalesGerente.variacionContratacion || '0%'}</td>
                    <td class="rpt-number-cell rpt-td-total">${gerente.totalesGerente.variacionCartera || '0%'}</td>
                </tr>
            </table>
    `;

    return esImpresion ? tableHtml : `<div class="mt-3">${tableHtml}</div>`;
}

function renderDireccionNegocio(dn, mesCorto, esImpresion = false) {

    const centrosContent = dn.centros && dn.centros.length > 0
        ? dn.centros.map(c => `
            <tr class="rpt-detail-row">
                <!-- MENSUAL -->
                <td class="rpt-number-cell pe-3">${formatCurrency(c.objetivosMensual)}</td>
                <td class="rpt-number-cell pe-4">${formatCurrency(c.contratacionMensual)}</td>

                <!-- CENTRO (CENTRAL) -->
                <td class="ps-4 rpt-col-centro">
                    <span class="rpt-text-dark">${c.codCentro}</span>
                    <span class="rpt-text-dark">${c.nombreCentro}</span>
                </td>

                <!-- ACUMULADO -->
                <td class="rpt-number-cell pe-3">${formatCurrency(c.objetivosAcumulado)}</td>
                <td class="rpt-number-cell pe-3">${formatCurrency(c.contratacionAcumulada)}</td>
                <td class="rpt-number-cell">${formatCurrency(c.ip, 2)}</td>

                <!-- RATIOS / VAR -->
                <td class="rpt-number-cell">${c.variacionContratacion}</td>
                <td class="rpt-number-cell">${c.variacionCartera}</td>
            </tr>
        `).join('')
        : '<tr><td colspan="8" class="text-center text-muted py-3">Sin datos</td></tr>';

    // Calcular año de comparación dinámicamente (año del filtro - 1)
    const anioComparacion = informeGlobalData?.meta?.filtros?.anio 
        ? informeGlobalData.meta.filtros.anio - 1 
        : (new Date()).getFullYear() - 1;

    const content = `
        <table class="rpt-table">
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
                    <!-- Mensual -->
                    <th class="rpt-number-cell pe-3 rpt-th-blue">Objet.</th>
                    <th class="rpt-number-cell pe-4 rpt-th-blue">Contr.</th>

                    <!-- Columna Centro -->
                    <th class="text-center">
                        <div class="rpt-group-badge">
                            ${dn.nombreDirNegocio}
                        </div>
                    </th>

                    <!-- Acumulado -->
                    <th class="rpt-number-cell pe-3 rpt-th-blue">Objet.</th>
                    <th class="rpt-number-cell pe-3 rpt-th-blue">Contr.</th>
                    <th class="rpt-number-cell rpt-th-blue">Ip</th>

                    <!-- Var -->
                    <th class="rpt-number-cell rpt-th-blue">Contr.</th>
                    <th class="rpt-number-cell rpt-th-blue">Cart. ${mesCorto ? `(${mesCorto})` : ''}</th>
                </tr>
            </thead>
            <tbody>
                ${centrosContent}
            </tbody>
            <tfoot class="fw-bold">
                <tr>
                    <td class="rpt-number-cell pe-3 rpt-td-total">${formatCurrency(dn.totalesDireccion.totalObjetivoMensual)}</td>
                    <td class="rpt-number-cell pe-4 rpt-td-total">${formatCurrency(dn.totalesDireccion.totalContratacionMensual)}</td>
                    <td class="rpt-td-total"></td> <!-- Espacio central limpio -->
                    <td class="rpt-number-cell pe-3 rpt-td-total">${formatCurrency(dn.totalesDireccion.totalObjetivoAcumulado)}</td>
                    <td class="rpt-number-cell pe-3 rpt-td-total">${formatCurrency(dn.totalesDireccion.totalContratacionAcumulada)}</td>
                    <td class="rpt-number-cell rpt-td-total">${formatCurrency(dn.totalesDireccion.ipMedia, 2)}</td>
                    <td class="rpt-number-cell rpt-td-total">${dn.totalesDireccion.variacionContratacion || '0%'}</td>
                    <td class="rpt-number-cell rpt-td-total">${dn.totalesDireccion.variacionCartera || '0%'}</td>
                </tr>
            </tfoot>
        </table>
    `;

    return esImpresion ? content : `<div class="dn-block mb-4">${content}</div>`;
}

// ===============================================================================
// HELPERS DE UI
// ===============================================================================

function _mostrarControlesPaginacion() {
    const ctrl = document.getElementById('ctrlPaginacion');
    if (ctrl) ctrl.classList.remove('d-none');
}

function _ocultarControlesPaginacion() {
    const ctrl = document.getElementById('ctrlPaginacion');
    if (ctrl) ctrl.classList.add('d-none');
}

function _abrirModal(titulo) {
    if (titulo) {
        const t = document.getElementById('modalInformeTitulo');
        if (t) t.innerText = titulo;
    }
    const modalElement = document.getElementById('modalInforme');
    const modal = bootstrap.Modal.getOrCreateInstance(modalElement);
    modal.show();
}

function _mostrarSinDatos(data, anio) {
    const contentContainer = document.getElementById('modalInformeContenido');
    const mesIdx = (data.meta?.filtros?.mes ?? 1) - 1;
    const nombreMes = _getNombreMes(mesIdx + 1);
    contentContainer.innerHTML = `
        <div class="rpt-info-alert" role="alert">
            <div class="rpt-info-alert-icon"><i class="fas fa-info-circle" aria-hidden="true"></i></div>
            <h5 class="rpt-info-alert-title">No hay datos disponibles</h5>
            <p class="rpt-info-alert-text">
                No se encontraron registros para ${nombreMes} ${data.meta?.filtros?.anio || anio}.
            </p>
        </div>
    `;
}

// ===============================================================================
// UTILIDADES
// ===============================================================================

function _getNombreMes(mes) {
    return ["Enero","Febrero","Marzo","Abril","Mayo","Junio",
            "Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"][mes - 1] || `mes ${mes}`;
}

function _getMesCorto(mes) {
    return ["Ene","Feb","Mar","Abr","May","Jun",
            "Jul","Ago","Sep","Oct","Nov","Dic"][mes - 1] || '';
}

// ===============================================================================
// FIN DEL MÓDULO
// ===============================================================================
