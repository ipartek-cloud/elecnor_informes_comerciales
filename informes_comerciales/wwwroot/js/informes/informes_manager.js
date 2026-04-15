/**
 * Gestor Central de Informes
 * Se encarga de la carga dinámica de módulos de informes para mantener el Index ligero.
 *
 * PATRÓN: Registro de módulos (Module Registry).
 * Cada módulo se importa UNA SOLA VEZ y se reutiliza en sucesivas llamadas.
 * Esto evita la multiplicación de event listeners cuando el usuario abre/cierra
 * el modal varias veces, ya que el import() dinámico con cache-buster generaría
 * un contexto de módulo nuevo (y por tanto variables de estado nuevas) en cada llamada.
 */
import { GlobalUI } from '../site.js';

// Registro interno: { [nombreInforme]: moduloImportado }
const _registroModulos = {};

window.cargarInforme = async function (btn, nombreInforme) {

    // Mantener compatibilidad si se llama solo con nombreInforme
    if (typeof btn === 'string') {
        nombreInforme = btn;
        btn = null;
    }

    const anio = document.getElementById('txtAnno').value;
    const mes  = document.getElementById('txtMes').value;
    
    // Capturar nro de página si el botón indica un input de origen
    const idInputPag = btn?.dataset?.inputPag;
    const nroPagina  = idInputPag ? document.getElementById(idInputPag)?.value : null;

    // Capturar mercado si existe (para informes duales como Ranking Clientes)
    const mercado = btn?.dataset?.mercado;

    // Capturar umbral si existe (para informes como Paises/Paises Relevantes)
    const umbral = btn?.dataset?.umbral;

    // Capturar si se debe mostrar el título
    const mostrarTitulo = btn?.dataset?.mostrarTitulo !== 'false';

    try {
        GlobalUI.showLoading();

        // 1. Cargar CSS específico del informe (si no se ha cargado ya)
        const idCss = `css-informe-${nombreInforme}`;
        if (!document.getElementById(idCss)) {
            const link = document.createElement('link');
            link.id   = idCss;
            link.rel  = 'stylesheet';
            link.href = `/css/informes/${nombreInforme}.css?v=${Date.now()}`;
            // No bloqueamos por el CSS, que cargue en paralelo
            document.head.appendChild(link);
        }

        // 2. Cargar módulo solo si no está ya en el registro
        if (!_registroModulos[nombreInforme]) {
            // Primera carga: incluir versión de build para cache-busting inicial
            const path = `./${nombreInforme}.js?v=${Date.now()}`;
            _registroModulos[nombreInforme] = await import(path);
        }

        const modulo = _registroModulos[nombreInforme];

        if (modulo && modulo.ejecutar) {
            // Obtenemos los parámetros adicionales según el reporte demandado
            const _codSubDir = document.getElementById('cmbSubDireccionGeneral')?.value || null;
            const _codSubDirRi = document.getElementById('cmbSubDireccionGeneral_ri')?.value || null;
            
            let parametroUmbral = umbral;
            if (nombreInforme === 'contrataciones_significativas') {
                parametroUmbral = _codSubDir;
            } else if (nombreInforme === 'contrataciones_significativas_ri') {
                parametroUmbral = _codSubDirRi;
            }

            await modulo.ejecutar(anio, mes, nroPagina, mercado, parametroUmbral, mostrarTitulo);
        } else {
            console.error(`El informe '${nombreInforme}' no exporta la función 'ejecutar'.`);
            GlobalUI.showAlert('Error en la estructura del informe', 'error');
        }

    } catch (error) {
        console.error('Error al cargar el módulo del informe:', error);
        GlobalUI.showAlert('No se pudo cargar el componente del informe', 'error');
    } finally {
        GlobalUI.hideLoading();
    }
};
