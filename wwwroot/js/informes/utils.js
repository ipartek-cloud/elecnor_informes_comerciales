/**
 * Utilidades comunes para el sistema de informes.
 * Módulo compartido para funciones de formateo, clasificación y UI.
 * 
 * Este archivo contiene:
 * - Constante de versión para cache-busting (APP_VERSION)
 * - Constantes de clases CSS (RPT_CLASSES)
 * - Arrays de meses (MESES_COMPLETOS, MESES_CORTOS)
 * - Helpers de fecha (getNombreMes, getMesCorto, getMesAnterior)
 * - Utilidades UI (mostrarSinDatos, mostrarControlesPaginacion, etc.)
 * - Funciones de formateo (formatCurrency, getIpClass, getVarClass)
 */

// =============================================================================
// CONSTANTE DE VERSIÓN COMPARTIDA (para cache-busting)
// =============================================================================
export const APP_VERSION = '1.0.2';

// =============================================================================
// CONSTANTES DE CLASES CSS COMPARTIDAS
// =============================================================================
export const RPT_CLASSES = Object.freeze({
    HEADER: 'rpt-header',
    BANNER: 'rpt-banner-top mb-1',
    SUBTITLE: 'rpt-subtitle',
    PAPER: 'rpt-paper',
    TABLE: 'rpt-table',
    NUMBER_CELL: 'rpt-number-cell',
    DETAIL_ROW: 'rpt-detail-row',
    TOTAL_ROW: 'rpt-total-row-blue',
    TH_BLUE: 'rpt-th-blue',
    TD_TOTAL: 'rpt-td-total',
    GROUP_BADGE: 'rpt-group-badge',
    INFO_ALERT: 'rpt-info-alert',
    MODAL_CONTENT: 'modalInformeContenido',
    MODAL_TITLE: 'modalInformeTitulo',
    MODAL: 'modalInforme',
    CTRL_PAGINACION: 'ctrlPaginacion',
    BTN_PAG_ANTERIOR: 'btnPagAnterior',
    BTN_PAG_SIGUIENTE: 'btnPagSiguiente',
    BTN_EXPORTAR_PDF: 'btnExportarPdf',
    LBL_ESTADO_PAGINACION: 'lblEstadoPaginacion'
});

// =============================================================================
// HELPERS DE FECHA
// =============================================================================

/**
 * Array de meses completos en español.
 */
export const MESES_COMPLETOS = [
    "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
    "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
];

/**
 * Array de meses cortos en español.
 */
export const MESES_CORTOS = [
    "Ene", "Feb", "Mar", "Abr", "May", "Jun",
    "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"
];

/**
 * Obtiene el nombre completo del mes dado su número (1-12).
 * @param {number} mes - Número de mes (1-12)
 * @returns {string} Nombre del mes
 */
export function getNombreMes(mes) {
    return MESES_COMPLETOS[mes - 1] || `mes ${mes}`;
}

/**
 * Obtiene el nombre corto del mes dado su número (1-12).
 * @param {number} mes - Número de mes (1-12)
 * @returns {string} Nombre corto del mes
 */
export function getMesCorto(mes) {
    return MESES_CORTOS[mes - 1] || '';
}

/**
 * Obtiene el nombre del mes anterior (para textos como "Var/Dic").
 * @param {number} mes - Número de mes actual (1-12)
 * @returns {string} Nombre corto del mes anterior o cadena vacía si es Enero
 */
export function getMesAnterior(mes) {
    if (mes <= 1) return '';
    return MESES_CORTOS[mes - 2] || '';
}

// =============================================================================
// UTILIDADES DE UI (Extraídas de ambos informes - P0)
// =============================================================================

/**
 * Renderiza el estado de "sin datos" en el contenedor del modal.
 * Función genérica reutilizable por todos los informes.
 * @param {object} data - Datos recibidos de la API
 * @param {number} anio - Año del filtro
 * @param {string} [mensajePersonalizado] - Mensaje opcional personalizado
 */
export function mostrarSinDatos(data, anio, mensajePersonalizado) {
    const container = document.getElementById(RPT_CLASSES.MODAL_CONTENT);
    if (!container) return;

    const mesIdx = (data?.meta?.filtros?.mes ?? 1);
    const nombreMes = getNombreMes(mesIdx);
    const anioFiltro = data?.meta?.filtros?.anio || anio;

    container.innerHTML = `
        <div class="${RPT_CLASSES.INFO_ALERT}" role="alert">
            <div class="rpt-info-alert-icon">
                <i class="fas fa-info-circle" aria-hidden="true"></i>
            </div>
            <h5 class="rpt-info-alert-title">No hay datos disponibles</h5>
            <p class="rpt-info-alert-text">
                ${mensajePersonalizado || `No se encontraron registros para ${nombreMes} ${anioFiltro}.`}
            </p>
        </div>
    `;
}

/**
 * Muestra los controles de paginación.
 */
export function mostrarControlesPaginacion() {
    const ctrl = document.getElementById(RPT_CLASSES.CTRL_PAGINACION);
    if (ctrl) ctrl.classList.remove('d-none');
}

/**
 * Oculta los controles de paginación.
 */
export function ocultarControlesPaginacion() {
    const ctrl = document.getElementById(RPT_CLASSES.CTRL_PAGINACION);
    if (ctrl) ctrl.classList.add('d-none');
}

/**
 * Abre el modal de informe con título opcional.
 * @param {string} [titulo] - Título del modal (opcional)
 */
export function abrirModal(titulo) {
    if (titulo) {
        const t = document.getElementById(RPT_CLASSES.MODAL_TITLE);
        if (t) t.innerText = titulo;
    }
    const modalElement = document.getElementById(RPT_CLASSES.MODAL);
    const modal = bootstrap.Modal.getOrCreateInstance(modalElement);
    modal.show();
}

/**
 * Actualiza el estado visual de los controles de paginación.
 * @param {number} paginaActual - Página actual (base 0)
 * @param {number} paginasTotales - Total de páginas
 * @param {string} [prefijo] - Prefijo del label (ej: "Gerencia", "Año", "Página")
 */
export function actualizarEstadoPaginacion(paginaActual, paginasTotales, prefijo = 'Página') {
    const btnAnterior = document.getElementById(RPT_CLASSES.BTN_PAG_ANTERIOR);
    const btnSiguiente = document.getElementById(RPT_CLASSES.BTN_PAG_SIGUIENTE);
    const lbl = document.getElementById(RPT_CLASSES.LBL_ESTADO_PAGINACION);

    const label = `${prefijo} ${paginaActual + 1} de ${paginasTotales}`;
    if (lbl) lbl.textContent = label;
    
    if (btnAnterior) {
        btnAnterior.disabled = (paginaActual === 0);
        btnAnterior.setAttribute('aria-disabled', (paginaActual === 0).toString());
        btnAnterior.setAttribute('aria-label', `Ir a ${prefijo} anterior`);
    }
    if (btnSiguiente) {
        btnSiguiente.disabled = (paginaActual === paginasTotales - 1);
        btnSiguiente.setAttribute('aria-disabled', (paginaActual === paginasTotales - 1).toString());
        btnSiguiente.setAttribute('aria-label', `Ir a ${prefijo} siguiente`);
    }
}

/**
 * Inicializa los event listeners de paginación y PDF.
 * Se registra una sola vez gracias al flag eventosIniciados.
 * @param {object} estado - Estado del informe (paginaActual, paginasTotales, eventosIniciados)
 * @param {Function} renderFn - Función para renderizar página actual
 * @param {Function} imprimirFn - Función para imprimir informe
 */
export function inicializarEventListenersBase(estado, renderFn, imprimirFn) {
    // NOTA CRÍTICA: Se usa `onclick` en lugar de `addEventListener` deliberadamente.
    // Los tres botones son elementos DOM únicos compartidos por TODOS los informes.
    // Con addEventListener, cada vez que se abre un informe diferente se añade un handler
    // adicional al mismo botón, acumulándolos. onclick reemplaza el handler previo.

    // El botón PDF se reasigna SIEMPRE, sin importar eventosIniciados.
    // Garantiza que el último informe abierto es siempre el dueño del botón de impresión.
    const btnPdf = document.getElementById(RPT_CLASSES.BTN_EXPORTAR_PDF);
    if (btnPdf) {
        btnPdf.onclick = imprimirFn;
    }

    // Los botones de paginación solo se configuran una vez por estado de informe.
    if (estado.eventosIniciados) return;

    const btnAnterior = document.getElementById(RPT_CLASSES.BTN_PAG_ANTERIOR);
    const btnSiguiente = document.getElementById(RPT_CLASSES.BTN_PAG_SIGUIENTE);

    if (btnAnterior) {
        btnAnterior.onclick = () => {
            if (estado.paginaActual > 0) {
                estado.paginaActual--;
                renderFn(estado.paginaActual);
            }
        };
    }

    if (btnSiguiente) {
        btnSiguiente.onclick = () => {
            if (estado.paginaActual < estado.paginasTotales - 1) {
                estado.paginaActual++;
                renderFn(estado.paginaActual);
            }
        };
    }

    estado.eventosIniciados = true;
}

// =============================================================================
// FUNCIONES DE FORMATEO (Originales)
// =============================================================================

/**
 * Formatea un valor numérico como moneda (miles de euros).
 * @param {number} val - Valor a formatear
 * @param {number} decimals - Cantidad de decimales a mostrar (por defecto 0)
 * @returns {string} Valor formateado o "-" si es cero
 */
export function formatCurrency(val, decimals = 0) {
    if (val === null || val === undefined) return "0";
    
    // Forzamos que sea un número para toLocaleString
    const num = Number(val);
    if (isNaN(num)) return "0";
    if (num === 0) return "0";

    return num.toLocaleString('es-ES', { 
        minimumFractionDigits: decimals, 
        maximumFractionDigits: decimals,
        useGrouping: true // Asegura el separador de miles (puntos)
    });
}

/**
 * Formatea un valor numérico como porcentaje (ej: 0.25 -> 25%).
 * @param {number} val - Valor a formatear
 * @param {number} decimals - Cantidad de decimales a mostrar (por defecto 0)
 * @returns {string} Valor formateado con símbolo %
 */
export function formatPercentage(val, decimals = 0) {
    if (val === null || val === undefined) return "0%";
    const num = Number(val);
    if (isNaN(num)) return "0%";
    if (num === 0) return "0%";

    // El servidor ya suele enviar el número entero para mostrar (ej: 25 para 25%)
    // o el decimal (ej: 0.25). 
    // En este proyecto, la lógica de negocio suele normalizar a entero en el DTO o 
    // esperar que el frontend lo multiplique. 
    // Revisando el Service, se envía el valor ya calculado para mostrar.
    
    return num.toLocaleString('es-ES', { 
        minimumFractionDigits: decimals, 
        maximumFractionDigits: decimals 
    }) + '%';
}

/**
 * Retorna la clase CSS según el valor del IP (Índice de Producción).
 * @param {number} ip - Valor del índice de producción
 * @returns {string} Clase CSS (text-success, text-warning, text-danger)
 */
export function getIpClass(ip) {
    if (ip >= 1) return 'text-success';
    if (ip >= 0.8) return 'text-warning';
    return 'text-danger';
}

export function getVarClass(val) {
    if (!val || typeof val !== 'string') return 'text-muted';
    if (val.startsWith('-')) return 'text-danger';
    if (val === '0%' || val === '-') return 'text-muted';
    return 'text-success';
}

/**
 * Formatea una fecha al formato locale español.
 * @param {string|Date} date - Fecha a formatear
 * @returns {string} Fecha formateada
 */
export function formatDate(date) {
    if (!date) return '';
    const d = typeof date === 'string' ? new Date(date) : date;
    return d.toLocaleString('es-ES');
}

/**
 * Escapa caracteres HTML para prevenir XSS.
 * @param {string} str - String a escapar
 * @returns {string} String escapado
 */
export function escapeHtml(str) {
    if (!str) return '';
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
}
