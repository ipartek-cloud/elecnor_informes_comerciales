/**
 * Utilidades de nivel superior para el sistema de informes.
 * Proporciona funciones base que orquestan las utilidades de utils.js
 * 
 * Este archivo contiene:
 * - Constante APP_VERSION (re-exportada desde utils.js)
 * - Factory function para estado de informe (crearEstadoInforme)
 * - Inicialización de informe con patrón de opciones (inicializarInforme)
 * - Encabezado HTML base (getHtmlEncabezadoBase)
 * - Impresión PDF base (imprimirInformeBase)
 */

import { RPT_CLASSES, getNombreMes, APP_VERSION } from './utils.js';
import { ApiClient } from '../site.js';
import { mostrarControlesPaginacion, ocultarControlesPaginacion, mostrarSinDatos, abrirModal } from './utils.js';

// Re-exportar para que los módulos de informe puedan importar desde aquí
export { APP_VERSION };

// =============================================================================
// ESTADO BASE DE INFORME (Factory Function)
// =============================================================================

/**
 * Crea un estado inicial de informe con valores por defecto.
 * @returns {object} Estado inicial del informe
 */
export function crearEstadoInforme() {
    return {
        informeGlobalData: null,
        paginaActual: 0,
        paginasTotales: 0,
        eventosIniciados: false,
        mostrarNumeroPagina: true, // Flag de visibilidad
        mostrarTitulo: true        // Nuevo flag de visibilidad
    };
}

// =============================================================================
// INICIALIZACIÓN DE INFORME (PATRÓN DE OPCIONES)
// =============================================================================

/**
 * Inicializa un informe usando patrón de opciones.
 * Detecta automáticamente la clave de agrupación en el JSON.
 * 
 * @param {object} opciones - Opciones de inicialización
 * @param {string} opciones.url - URL de la API
 * @param {object} opciones.estado - Estado del informe (de crearEstadoInforme())
 * @param {Function} opciones.renderizarPagina - Función para renderizar página (específica del informe)
 * @param {Function} opciones.inicializarEventListeners - Función para inicializar listeners (específica del informe)
 * @param {string} [opciones.prefijoPaginacion='Página'] - Prefijo para el label de paginación (ej: "Gerencia", "Año")
 * @param {string} [opciones.claveAgrupacion=null] - Clave manual de agrupación (opcional, para override si la detección automática falla)
 */
export async function inicializarInforme(opciones) {
    const {
        url,
        estado,
        renderizarPagina,
        inicializarEventListeners,
        prefijoPaginacion = 'Página',
        claveAgrupacion = null
    } = opciones;

    try {
        const resp = await ApiClient.get(url);
        if (!resp.ok) throw new Error('Error en la respuesta');

        const data = await resp.json();
        
        // Detección de datos y paginación
        let paginas = 0;
        let hayDatos = true;

        if (claveAgrupacion === 'NONE') {
            // Informe de página única: Forzamos 1 página y dejamos que el informe maneje sus datos.
            paginas = 1;
            hayDatos = true; 
        } else {
            // Informe con paginación basada en array de agrupación
            const key = claveAgrupacion || Object.keys(data).find(k => Array.isArray(data[k]));
            const arr = key ? data[key] : [];
            paginas = arr.length;
            hayDatos = (paginas > 0);
        }

        if (!hayDatos) {
            mostrarSinDatos(data);
            ocultarControlesPaginacion();
            abrirModal(data.meta?.titulo);
            return;
        }

        estado.informeGlobalData = data;
        estado.paginaActual = 0;
        estado.paginasTotales = paginas;
        
        // Prioridad: Si el frontend ya ha decidido ocultarlo (mostrarNumeroPagina === false), se mantiene.
        // Si no, se intenta leer del servidor.
        if (estado.mostrarNumeroPagina !== false) {
            estado.mostrarNumeroPagina = data.meta?.mostrarNumeroPagina ?? true;
        }

        if (estado.mostrarTitulo !== false) {
            estado.mostrarTitulo = data.meta?.mostrarTitulo ?? true;
        }

        renderizarPagina(0);

        // La visibilidad del bloque de paginación se delega ahora íntegramente a 
        // actualizarEstadoPaginacion (llamada por renderizarPagina o manualmente),
        // siguiendo el principio de tratamiento común.

        if (estado.paginasTotales > 1) {
            mostrarControlesPaginacion();
        } else {
            ocultarControlesPaginacion();
        }

        inicializarEventListeners();
        abrirModal(data.meta?.titulo);

    } catch (error) {
        throw error;
    }
}

// =============================================================================
// ENCABEZADO HTML BASE
// =============================================================================

/**
 * Obtiene el encabezado HTML base para un informe.
 * 
 * @param {object} opciones - Opciones del encabezado
 * @param {string} [opciones.tituloCorporativo='Informe de Contratación'] - Título corporativo
 * @param {string} [opciones.textoBanner1='Elecnor'] - Primer texto del banner
 * @param {string} [opciones.textoBanner2='Informes'] - Segundo texto del banner
 * @param {number} opciones.mes - Mes del informe
 * @param {number} opciones.anio - Año del informe
 * @param {number} [opciones.nroPagina] - Número de página opcional
 * @param {boolean} [opciones.mostrarNumeroPagina=true] - Si debe mostrarse el número de página
 * @param {boolean} [opciones.mostrarTitulo=true] - Si debe mostrarse el título corporativo
 * @returns {string} HTML del encabezado
 */
export function getHtmlEncabezadoBase(opciones) {
    const {
        tituloCorporativo = 'Informe de Contratación',
        textoBanner1 = 'Elecnor',
        textoBanner2 = 'Informes',
        mes,
        anio,
        nroPagina,
        mostrarNumeroPagina = true,
        mostrarTitulo = true
    } = opciones;

    const nombreMes = getNombreMes(mes);

    // El número de página solo se muestra si está habilitado Y existe un valor.
    const htmlPagina = (mostrarNumeroPagina !== false && nroPagina) 
        ? `<span class="rpt-page-number">${nroPagina}</span>` 
        : '';

    // El título corporativo solo se muestra si está habilitado.
    // Si no se muestra, inyectamos un div vacío para que Flexbox (justify-content: space-between)
    // mantenga el logotipo a la derecha.
    const htmlTitulo = (mostrarTitulo !== false)
        ? `<div class="rpt-text-corporate rpt-header-corporate-text">${tituloCorporativo}</div>`
        : '<div></div>';

    return `
        <div class="${RPT_CLASSES.HEADER}">
            ${htmlTitulo}
            <div class="d-flex flex-column align-items-end">
                ${htmlPagina}
                <img src="/images/logoElecnor.png" alt="Logo Elecnor" class="rpt-header-logo">
            </div>
        </div>
        <div class="${RPT_CLASSES.BANNER}">
            <span>${textoBanner1}</span>
            <span>${textoBanner2}</span>
        </div>
        <div class="${RPT_CLASSES.SUBTITLE}">
            Cierre de ${nombreMes} ${anio} | Miles de euros
        </div>
    `;
}

// =============================================================================
// HELPER: Genera string de variables CSS inline para márgenes custom
// =============================================================================

/**
 * Construye un string de atributos style con variables CSS para márgenes.
 * Si margenes es null/undefined, retorna string vacío (se aplican los defaults del CSS).
 *
 * @param {object|null} margenes - Configuración de márgenes custom
 * @param {string} [margenes.web] - Padding en pantalla (ej: "1.5rem")
 * @param {string} [margenes.pdf] - Padding en impresión (ej: "6.4mm")
 * @param {string} [margenes.maxWidth] - Ancho máximo del papel (ej: "1200px")
 * @returns {string} String HTML para inyectar como atributo style, o string vacío.
 */
function _buildStyleVars(margenes) {
    if (!margenes || typeof margenes !== 'object') return '';

    const vars = [];
    if (margenes.web) vars.push(`--rpt-padding-web: ${margenes.web};`);
    if (margenes.pdf) vars.push(`--rpt-padding-pdf: ${margenes.pdf};`);
    if (margenes.maxWidth) vars.push(`--rpt-max-width: ${margenes.maxWidth};`);

    return vars.length > 0 ? ` style="${vars.join(' ')}"` : '';
}

// =============================================================================
// IMPRESIÓN PDF BASE
// =============================================================================

/**
 * Genera la capa de impresión para un informe.
 *
 * @param {object} opciones - Opciones de impresión
 * @param {object} opciones.informeGlobalData - Datos del informe
 * @param {Function} opciones.getHtmlEncabezado - Función para generar encabezado (específica del informe, sin parámetros)
 * @param {Function} opciones.renderContenido - Función para renderizar contenido (específica del informe, recibe el item)
 * @param {string} [opciones.modoAgrupacion=null] - Clave manual de agrupación (igual que en inicializarInforme)
 * @param {object} [opciones.margenes=null] - Configuración de márgenes custom { web, pdf, maxWidth }
 * @returns {Promise<void>}
 */
export async function imprimirInformeUnificado(opciones) {
    const {
        informeGlobalData,
        getHtmlEncabezado,
        renderContenido,
        modoAgrupacion = null,
        margenes = null
    } = opciones;

    if (!informeGlobalData) return;

    // Construir string de variables CSS inline si se proporcionan márgenes custom
    const styleVars = _buildStyleVars(margenes);

    const capaPrint = document.createElement('div');
    capaPrint.className = 'rpt-print-layer';

    // Normalizar modo de agrupación para chequeos consistentes
    const modoNormalizado = (typeof modoAgrupacion === 'string') ? modoAgrupacion.trim().toUpperCase() : '';
    const esPaginaUnica = (modoNormalizado === 'NONE');

    // Caso especial: informe de página única (modoAgrupacion = 'NONE')
    if (esPaginaUnica) {
        const html = `
            <div class="rpt-paper rpt-paper--print" data-informe="una-pagina"${styleVars}>
                ${getHtmlEncabezado()}
                <div class="report-body">
                    ${renderContenido()}
                </div>
            </div>
        `;
        capaPrint.innerHTML = html;
        document.body.appendChild(capaPrint);

        const originalTitle = document.title;
        try {
            await new Promise(resolve => setTimeout(resolve, 200));
            document.title = '';
            window.print();
        } finally {
            document.title = originalTitle;
            if (document.body.contains(capaPrint)) {
                document.body.removeChild(capaPrint);
            }
        }
        return;
    }

    // Informes con paginación basada en array de agrupación
    const key = (modoAgrupacion && !esPaginaUnica)
        ? modoAgrupacion
        : Object.keys(informeGlobalData).find(k => Array.isArray(informeGlobalData[k]));

    const items = key ? (informeGlobalData[key] || []) : [];

    if (!Array.isArray(items) || items.length === 0) return;

    const html = items.map((item, idx) => `
        <div class="rpt-paper rpt-paper--print ${idx < items.length - 1 ? 'rpt-page-break' : ''}"${styleVars}>
            ${getHtmlEncabezado(item)}
            <div class="report-body">
                ${renderContenido(item)}
            </div>
        </div>
    `).join('');

    capaPrint.innerHTML = html;
    document.body.appendChild(capaPrint);

    const originalTitle = document.title;
    try {
        await new Promise(resolve => setTimeout(resolve, 200));
        document.title = '';
        window.print();
    } finally {
        document.title = originalTitle;
        if (document.body.contains(capaPrint)) {
            document.body.removeChild(capaPrint);
        }
    }
}
