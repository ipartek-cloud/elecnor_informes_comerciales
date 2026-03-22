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
        eventosIniciados: false
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
        
        // Detección automática de clave de agrupación (o usa la manual si se proporciona)
        const key = claveAgrupacion || Object.keys(data).find(k => Array.isArray(data[k]));
        const arr = key ? data[key] : [];

        if (!arr || arr.length === 0) {
            mostrarSinDatos(data);
            ocultarControlesPaginacion();
            abrirModal(data.meta?.titulo);
            return;
        }

        estado.informeGlobalData = data;
        estado.paginaActual = 0;
        estado.paginasTotales = arr.length;

        renderizarPagina(0);

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
 * @returns {string} HTML del encabezado
 */
export function getHtmlEncabezadoBase(opciones) {
    const {
        tituloCorporativo = 'Informe de Contratación',
        textoBanner1 = 'Elecnor',
        textoBanner2 = 'Informes',
        mes,
        anio,
        nroPagina
    } = opciones;

    const nombreMes = getNombreMes(mes);

    return `
        <div class="${RPT_CLASSES.HEADER}">
            <div class="rpt-text-corporate rpt-header-corporate-text">${tituloCorporativo}</div>
            <div class="d-flex flex-column align-items-end">
                ${nroPagina ? `<span class="rpt-page-number">${nroPagina}</span>` : ''}
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
// IMPRESIÓN PDF BASE
// =============================================================================

/**
 * Genera la capa de impresión para un informe.
 * 
 * @param {object} opciones - Opciones de impresión
 * @param {object} opciones.informeGlobalData - Datos del informe
 * @param {Function} opciones.getHtmlEncabezado - Función para generar encabezado (específica del informe, sin parámetros)
 * @param {Function} opciones.renderContenido - Función para renderizar contenido (específica del informe, recibe el item)
 * @param {string} [opciones.claveAgrupacion=null] - Clave manual de agrupación (igual que en inicializarInforme)
 * @returns {Promise<void>}
 */
export async function imprimirInformeBase(opciones) {
    const {
        informeGlobalData,
        getHtmlEncabezado,
        renderContenido,
        claveAgrupacion = null
    } = opciones;

    if (!informeGlobalData) return;

    const capaPrint = document.createElement('div');
    capaPrint.className = 'rpt-print-layer';

    // Usar clave manual si se proporciona; si no, detección automática como fallback.
    // Esto garantiza que informes con múltiples arrays (p. ej. CMAI) usen el array correcto.
    const key = claveAgrupacion || Object.keys(informeGlobalData).find(k => Array.isArray(informeGlobalData[k]));
    const items = key ? informeGlobalData[key] : [];

    const html = items.map((item, idx) => `
        <div class="rpt-paper rpt-paper--print ${idx < items.length - 1 ? 'rpt-page-break' : ''}">
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
