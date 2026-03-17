/**
 * Utilidades comunes para el sistema de informes.
 * Módulo compartido para funciones de formateo y clasificación.
 */

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
