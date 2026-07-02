/**
 * Utilidades comunes para el sistema de informes.
 * Módulo compartido para funciones de formateo, clasificación y UI.
 * 
 * Este archivo contiene:
 * - Constantes de clases CSS (RPT_CLASSES)
 * - Arrays de meses (MESES_COMPLETOS, MESES_CORTOS)
 * - Helpers de fecha (getNombreMes, getMesCorto, getMesAnterior)
 * - Utilidades UI (mostrarSinDatos, mostrarControlesPaginacion, etc.)
 * - Funciones de formateo (formatCurrency, getIpClass, getVarClass)
 */


import { ApiClient, GlobalUI } from '../site.js';

// =============================================================================
// CONSTANTES DE CLASES CSS COMPARTIDAS
// =============================================================================
export const RPT_CLASSES = Object.freeze({
    HEADER: 'rpt-header',
    BANNER: 'rpt-banner-top rpt-mb-1',
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
    BTN_DESCARGAR_PDF: 'btnDescargarPdfDirecto',
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
    const ctrl = document.getElementById(RPT_CLASSES.CTRL_PAGINACION);
    const btnAnterior = document.getElementById(RPT_CLASSES.BTN_PAG_ANTERIOR);
    const btnSiguiente = document.getElementById(RPT_CLASSES.BTN_PAG_SIGUIENTE);
    const lbl = document.getElementById(RPT_CLASSES.LBL_ESTADO_PAGINACION);

    // TRATAMIENTO COMÚN: Si solo hay una página o ninguna, ocultar todo el bloque de paginación
    if (paginasTotales <= 1) {
        if (ctrl) ctrl.classList.add('d-none');
        return;
    } 
    
    // Si hay más de una, asegurar que se vea
    if (ctrl) ctrl.classList.remove('d-none');

    const label = `${prefijo} ${paginaActual + 1} de ${paginasTotales}`;
        
    if (lbl) lbl.textContent = label;
    
    if (btnAnterior) {
        const canGoBack = (paginaActual > 0);
        btnAnterior.disabled = !canGoBack;
        btnAnterior.setAttribute('aria-disabled', (!canGoBack).toString());
        btnAnterior.setAttribute('aria-label', `Ir a ${prefijo} anterior`);
    }
    if (btnSiguiente) {
        const canGoNext = (paginasTotales && paginaActual < paginasTotales - 1);
        btnSiguiente.disabled = !canGoNext;
        btnSiguiente.setAttribute('aria-disabled', (!canGoNext).toString());
        btnSiguiente.setAttribute('aria-label', `Ir a ${prefijo} siguiente`);
    }
}

/**
 * Inicializa los event listeners de paginación y PDF.
 * Todos los handlers se reasignan en cada apertura de informe
 * para garantizar que referencien el estado actual.
 * @param {object} estado - Estado del informe (paginaActual, paginasTotales)
 * @param {Function} renderFn - Función para renderizar página actual
 * @param {Function} imprimirFn - Función para imprimir informe
 */
export function inicializarEventListenersBase(estado, renderFn, imprimirFn) {
    // NOTA CRÍTICA: Se usa `onclick` en lugar de `addEventListener` deliberadamente.
    // Los botones son elementos DOM únicos compartidos por TODOS los informes.
    // onclick reemplaza el handler previo; addEventListener los acumularía.

    // Todos los handlers se reasignan SIEMPRE (onclick reemplaza, no acumula).
    // Esto garantiza que cada informe abierto es dueño de los botones y
    // que las closures capturan el estado correcto de cada invocación.

    // Botón PDF
    const btnPdf = document.getElementById(RPT_CLASSES.BTN_EXPORTAR_PDF);
    if (btnPdf) {
        btnPdf.onclick = imprimirFn;
    }

    // Botón Descarga PDF Directo
    const btnDescargar = document.getElementById(RPT_CLASSES.BTN_DESCARGAR_PDF);
    if (btnDescargar) {
        btnDescargar.onclick = async () => {
            const originalPrint = window.print;
            const originalText = btnDescargar.innerHTML;

            // Poner en estado de carga en el botón
            btnDescargar.disabled = true;
            btnDescargar.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i> Generando...';

            let htmlContent = null;
            let fileName = null;
            let reportName = null;
            let pageNum = null;

            // Interceptamos temporalmente window.print
            window.print = function () {
                const capaPrint = document.querySelector('.rpt-print-layer');
                if (capaPrint) {
                    htmlContent = capaPrint.innerHTML;

                    const firstPaper = capaPrint.querySelector('.rpt-paper');
                    let rName = firstPaper ? (firstPaper.dataset.informe || firstPaper.getAttribute('data-informe')) : '';
                    if (!rName || rName === 'unificado') {
                        const screenPaper = document.querySelector('#modalInformeContenido .rpt-paper');
                        if (screenPaper) {
                            rName = screenPaper.dataset.informe || screenPaper.getAttribute('data-informe') || '';
                        }
                    }
                    reportName = rName;

                    const pageNumElem = capaPrint.querySelector('.rpt-page-number');
                    if (pageNumElem) {
                        pageNum = pageNumElem.textContent.trim();
                    }
                    if (!pageNum && estado) {
                        pageNum = estado.nroPagina;
                    }
                    if (!pageNum && estado) {
                        pageNum = estado.paginaActual + 1;
                    }
                    fileName = `${pageNum || 1}.pdf`;
                }
            };

            try {
                // Ejecutamos imprimirFn, que construirá la capa y disparará window.print()
                await imprimirFn();
            } catch (err) {
                if (typeof Swal !== 'undefined') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error de impresión',
                        text: 'Ocurrió un error al preparar la vista del informe.'
                    });
                }
            } finally {
                // Restauramos inmediatamente window.print
                window.print = originalPrint;
            }

            // Validamos e iniciamos la descarga o informamos de fallos
            if (htmlContent) {
                await descargarPdfDesdeServidor(htmlContent, fileName, reportName, parseInt(pageNum) || null);
            } else {
                if (typeof Swal !== 'undefined') {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Descarga no iniciada',
                        text: 'No se pudo generar el contenido del informe para la descarga.'
                    });
                }
            }

            // Restauramos el botón
            btnDescargar.disabled = false;
            btnDescargar.innerHTML = originalText;
        };
    }

    // Botón Anterior
    const btnAnterior = document.getElementById(RPT_CLASSES.BTN_PAG_ANTERIOR);
    if (btnAnterior) {
        btnAnterior.onclick = () => {
            if (estado.paginaActual > 0) {
                estado.paginaActual--;
                renderFn(estado.paginaActual);
            }
        };
    }

    // Botón Siguiente
    const btnSiguiente = document.getElementById(RPT_CLASSES.BTN_PAG_SIGUIENTE);
    if (btnSiguiente) {
        btnSiguiente.onclick = () => {
            if (estado.paginaActual < estado.paginasTotales - 1) {
                estado.paginaActual++;
                renderFn(estado.paginaActual);
            }
        };
    }
}

/**
 * Envía el HTML del informe al servidor y descarga el PDF generado.
 */
async function descargarPdfDesdeServidor(htmlContent, fileName, reportName, nroPagina) {
    try {
        const response = await ApiClient.post('/api/PdfExport/download', {
            htmlContent: htmlContent,
            fileName: fileName,
            reportName: reportName,
            nroPagina: nroPagina || null
        }, true);

        if (!response.ok) {
            let errorText = "Error desconocido del servidor.";
            try {
                errorText = await response.text();
            } catch {}
            throw new Error(`Error ${response.status}: ${errorText}`);
        }

        const blob = await response.blob();
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = fileName;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);

        // Informamos éxito mediante Toast
        if (typeof Swal !== 'undefined') {
            Swal.fire({
                toast: true,
                position: 'top-end',
                icon: 'success',
                title: 'PDF generado y descargado',
                showConfirmButton: false,
                timer: 3000,
                timerProgressBar: true
            });
        }
    } catch (err) {
        if (typeof Swal !== 'undefined') {
            Swal.fire({
                icon: 'error',
                title: 'Error de descarga',
                text: 'No se pudo generar o descargar el PDF en el servidor. Por favor, inténtelo de nuevo.'
            });
        } else {
            alert('No se pudo generar o descargar el PDF.');
        }
    }
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
    if (ip >= 1) return 'rpt-text-success';
    if (ip >= 0.8) return 'rpt-text-warning';
    return 'rpt-text-danger';
}

export function getVarClass(val) {
    if (!val || typeof val !== 'string') return 'rpt-text-muted';
    if (val.startsWith('-')) return 'rpt-text-danger';
    if (val === '0%' || val === '-') return 'rpt-text-muted';
    return 'rpt-text-success';
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

/**
 * Ejecuta la generación previa de datos de un informe mediante checkbox.
 * Patrón compartido por contrataciones.js y contrataciones_ai.js.
 *
 * @param {string} checkboxId - ID del checkbox en el DOM
 * @param {string} endpoint - Endpoint POST para la generación
 * @param {object} payload - Payload con { anio, mes }
 * @param {string} loadingMsg - Mensaje mostrado durante la generación
 * @returns {Promise<boolean>} true si se generó (o no era necesario), false si hubo error
 */
export async function ejecutarGeneracionPrevia(checkboxId, endpoint, payload, loadingMsg = 'Generando datos...') {
    const chkGenerar = document.getElementById(checkboxId);
    const debeGenerar = chkGenerar?.checked ?? false;

    if (!debeGenerar) return true;

    GlobalUI.showLoading(loadingMsg);

    try {
        const genResp = await ApiClient.post(endpoint, payload, true);
        if (!genResp.ok) {
            const errorText = await genResp.text();
            GlobalUI.showAlert('Error al generar datos: ' + errorText, 'danger');
            GlobalUI.hideLoading();
            return false;
        }
    } catch (error) {
        GlobalUI.showAlert('Error al conectar con el servidor', 'danger');
        GlobalUI.hideLoading();
        return false;
    }

    GlobalUI.hideLoading();
    return true;
}
