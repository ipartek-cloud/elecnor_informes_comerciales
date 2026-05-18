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
/**
 * Registro oficial de informes habilitados en el sistema (V-22).
 * El nombre de la clave debe coincidir con el nombre del archivo .js en wwwroot/js/informes/
 */
const _whitelistInformes = {
    'cartera_diferida_consejo': 'Cartera Diferida Consejo',
    'mercados': 'Mercados',
    'mercados_dg': 'Mercados DG',
    'mercados_sg_delegaciones': 'Mercados SG Delegaciones',
    'paises': 'Países',
    'paises_all': 'Países (Todos)',
    'actividades': 'Actividades',
    'actividades_objetivos': 'Actividades Objetivos',
    'contrataciones': 'Contrataciones',
    'contrataciones_ai': 'Contrataciones AI',
    'contrataciones_significativas': 'Contrataciones Significativas',
    'contrataciones_significativas_ri': 'Contrataciones Significativas RI',
    'ranking_contratacion_clientes': 'Ranking Contratación Clientes',
    'gerencias': 'Gerencias',
    'cartera_contratacion_detalle': 'Cartera Contratación (Detalle)',
    'cartera_contratacion_resumen_sdg': 'Cartera Contratación (Resumen)',
    'cartera_contratacion_detalle_org_paises': 'Cartera Contratación (Detalle Org. Países)',
    'cartera_contratacion_detalle_paises': 'Cartera Contratación (Detalle Países)',
    'actividades_internacional_detalle': 'Detalle Actividades Internacional'
};

const _registroModulos = {};

/**
 * Elimina del DOM todos los links de CSS dinámicos de informes.
 * Evita la acumulación de etiquetas <link> y posibles colisiones de estilos.
 */
export function limpiarCssInformes() {
    const links = document.querySelectorAll('link[id^="css-informe-"]');
    links.forEach(link => link.remove());
}

/**
 * Inicializa los bocadillos de previsualización (Tooltips) para los botones de informe.
 * Utiliza Tippy.js para mostrar los filtros reales que se aplicarán.
 */
function inicializarTooltipsFiltros() {
    if (typeof tippy === 'undefined') return;

    // Destruir instancias previas para evitar duplicados
    tippy.destroyAll?.();

    tippy('.btn.rpt-btn-index', {
        theme: 'elecnor',
        placement: 'top',
        allowHTML: true,
        animation: 'fade',
        arrow: true,
        onShow(instance) {
            const btn = instance.reference;
            const ds = btn.dataset;
            
            // 1. Obtener valores globales (Inputs)
            const valorInputMonto = parseFloat(document.getElementById('inputLimiteMonto')?.value || 0);
            const valorInputPaises = parseInt(document.getElementById('inputLimiteNumeroPaises')?.value || 0, 10);

            // 2. Obtener valores por defecto del botón
            const limiteImporteDefault = ds.limiteimporte ? parseFloat(ds.limiteimporte) : null;
            const limitePaisesDefault = ds.limitepaises ? parseInt(ds.limitepaises, 10) : null;

            // 3. Resolver Jerarquía (REPLICA EXACTA DE CARGARINFORME)
            // Lógica: Si el input es 0 o vacío, manda el botón. Si el input tiene valor, manda el input.
            const montoReal = (!valorInputMonto || valorInputMonto === 0) && limiteImporteDefault
                ? limiteImporteDefault
                : (valorInputMonto || limiteImporteDefault || 13000);

            const paisesReal = (!valorInputPaises || valorInputPaises === 0) && limitePaisesDefault
                ? limitePaisesDefault
                : (valorInputPaises || limitePaisesDefault || 20);

            let umbral = ds.umbral;

            // 4. Construir HTML del bocadillo
            let content = `<div class="rpt-p-1">`;
            content += `<div class="rpt-mb-1"><strong>Filtros Activos</strong></div>`;
            
            let tieneInfo = false;

            // B. Filtro de Monto
            if (ds.limiteimporte !== undefined || ds.informe?.includes('cartera') || ds.informe?.includes('detalle')) {
                const valorM = montoReal / 1000;
                // Formatear a 1 decimal y convertir de nuevo a número para eliminar .0 si existe
                const displayMonto = Number(valorM.toFixed(1));
                content += `<div>Monto: ${displayMonto}M</div>`;
                tieneInfo = true;
            }

            // C. Filtro de Países
            if (ds.limitepaises !== undefined || ds.informe?.includes('cartera') || ds.informe?.includes('detalle')) {
                content += `<div>Países: ${paisesReal}</div>`;
                tieneInfo = true;
            }

            // D. Umbral de Filtrado
            if (umbral !== undefined && umbral !== null && umbral !== "") {
                const num = parseFloat(umbral);
                const displayUmbral = num === 0 ? "0" : Math.round(num / 1000) + "k";
                content += `<div>Umbral: ${displayUmbral}</div>`;
                tieneInfo = true;
            }

            content += `</div>`;

            if (!tieneInfo) return false;

            instance.setContent(content);
        }
    });
}

// Inicializar cuando el DOM esté listo o se cargue el script
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', inicializarTooltipsFiltros);
} else {
    inicializarTooltipsFiltros();
}

window.cargarInforme = async function (btn, nombreInforme) {

    // Mantener compatibilidad si se llama solo con nombreInforme
    if (typeof btn === 'string') {
        nombreInforme = btn;
        btn = null;
    }

    const anio = document.getElementById('txtAnno').value;
    const mes  = document.getElementById('txtMes').value;
    
    // 0. Verificar si está activado el modo HTML Portable
    const chkPortable = document.getElementById('chkGenerarHtmlPortable');
    if (chkPortable && chkPortable.checked) {
        const labelBoton = btn?.textContent?.trim() || nombreInforme;
        const mesesSeleccionados = await _mostrarSelectorMeses(labelBoton, mes);
        if (mesesSeleccionados) {
            _generarHtmlPortable(btn, nombreInforme, mesesSeleccionados, labelBoton);
        }
        return;
    }
    if (!_whitelistInformes[nombreInforme]) {
        console.error(`El informe '${nombreInforme}' no está registrado en el manager.`);
        GlobalUI.showAlert('Informe no autorizado o inexistente', 'error');
        return;
    }

    // Capturar nro de página si el botón indica un input de origen
    // Normalizar: parsear a entero y tratar 0 como null (sin número de página)
    const idInputPag = btn?.dataset?.inputPag;
    const rawPag = idInputPag ? document.getElementById(idInputPag)?.value : null;
    const nroPagina = rawPag != null ? parseInt(rawPag, 10) : null;
    const nroPaginaFinal = nroPagina > 0 ? nroPagina : null;

    // Capturar mercado si existe (para informes duales como Ranking Clientes)
    const mercado = btn?.dataset?.mercado;

    // Capturar umbral si existe (para informes como Paises/Paises Relevantes)
    const umbral = btn?.dataset?.umbral;

    // Capturar si se debe mostrar el título
    const mostrarTitulo = btn?.dataset?.mostrarTitulo !== 'false';

    // Resolver limiteImporte: inputLimiteMonto vs data-limiteimporte del botón
    const limiteImporteInput = document.getElementById('inputLimiteMonto');
    const valorInputMonto = limiteImporteInput ? parseFloat(limiteImporteInput.value) : 0;
    const limiteImporteDefault = btn?.dataset?.limiteimporte ? parseFloat(btn.dataset.limiteimporte) : null;
    const limiteImporteFinal = (!valorInputMonto || valorInputMonto === 0) && limiteImporteDefault
        ? limiteImporteDefault
        : (valorInputMonto || limiteImporteDefault || 13000);

    // Solo mostrar toast de límite de monto si el informe declara usarlo explícitamente
    const aplicaLimiteMonto = btn?.dataset?.limiteimporte !== undefined;

    // Resolver limitePaises: inputLimiteNumeroPaises vs data-limitepaises del botón
    const limitePaisesInput = document.getElementById('inputLimiteNumeroPaises');
    const valorInputPaises = limitePaisesInput ? parseInt(limitePaisesInput.value, 10) : 0;
    const limitePaisesDefault = btn?.dataset?.limitepaises ? parseInt(btn.dataset.limitepaises, 10) : null;
    const limitePaisesFinal = (!valorInputPaises || valorInputPaises === 0) && limitePaisesDefault
        ? limitePaisesDefault
        : (valorInputPaises || limitePaisesDefault || 20);

    let exito = false;

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

        // 2. Cargar módulo (Forzar siempre carga fresca para asegurar que los cambios de escala se aplican)
        const path = `./${nombreInforme}.js?v=${Date.now()}`;
        _registroModulos[nombreInforme] = await import(path);

        const modulo = _registroModulos[nombreInforme];

        if (modulo && modulo.ejecutar) {
            const _codSubDir = btn?.dataset?.subdireccion || null;
            
            // Construir objeto de parámetros (Context Object) para evitar colisiones posicionales
            const parametros = {
                anio: anio,
                mes: mes,
                nroPagina: nroPaginaFinal,
                mercado: mercado,
                umbral: btn?.dataset?.umbral || null,
                codSubDir: _codSubDir,
                mostrarTitulo: mostrarTitulo,
                limiteImporte: limiteImporteFinal,
                limitePaises: limitePaisesFinal,
                informe: btn?.dataset?.informe || null
            };

            await modulo.ejecutar(parametros);
            exito = true;
        } else {
            console.error(`El informe '${nombreInforme}' no exporta la función 'ejecutar'.`);
            GlobalUI.showAlert('Error en la estructura del informe', 'error');
        }

    } catch (error) {
        console.error('Error al cargar el módulo del informe:', error);
        GlobalUI.showAlert('No se pudo cargar el componente del informe', 'error');
    } finally {
        GlobalUI.hideLoading();
        if (exito && aplicaLimiteMonto) {
            const valorMiles = Math.round(limiteImporteFinal / 1000);
            GlobalUI.showAlert(`Limite Monto (miles): ${valorMiles}`, 'info', 'Filtro aplicado');
        }
    }
};

/**
 * Muestra un modal con checkboxes para seleccionar qué meses incluir en el HTML Portable.
 * Retorna un array con los números de mes seleccionados, o null si el usuario cancela.
 */
async function _mostrarSelectorMeses(nombreInforme, mesHasta) {
    const MESES = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    const mesMax = parseInt(mesHasta, 10);

    let html = '<div style="text-align:left;max-height:350px;overflow-y:auto">';
    html += `<p style="font-size:14px;margin-bottom:10px"><strong>Informe:</strong> ${nombreInforme}</p>`;
    for (let m = 1; m <= mesMax; m++) {
        html += `<div style="margin:4px 0"><label style="cursor:pointer;font-size:14px"><input type="checkbox" class="swal-mes-check" value="${m}" checked style="margin-right:8px">${MESES[m-1]}</label></div>`;
    }
    html += '</div>';

    const result = await Swal.fire({
        title: 'Seleccionar meses',
        html: html,
        showCancelButton: true,
        confirmButtonText: 'Generar HTML',
        cancelButtonText: 'Cancelar',
        confirmButtonColor: '#00468B',
        preConfirm: () => {
            const checks = document.querySelectorAll('.swal-mes-check:checked');
            if (checks.length === 0) {
                Swal.showValidationMessage('Seleccione al menos un mes');
                return false;
            }
            return Array.from(checks).map(c => parseInt(c.value, 10));
        }
    });

    return result.isConfirmed ? result.value : null;
}

/**
 * Genera y descarga un informe HTML Portable (Self-Contained).
 * Captura todos los filtros data-* del botón, construye la petición al endpoint API
 * y gestiona la descarga del archivo .html generado por el servidor.
 */
async function _generarHtmlPortable(btn, nombreInforme, mesesSeleccionados, labelInforme) {
    try {
        GlobalUI.showLoading('Generando informe portable...');

        const anio = document.getElementById('txtAnno').value;
        const mes = document.getElementById('txtMes').value;

        // 1. Construir URL base del endpoint
        let url = `/api/InformePortable/${encodeURIComponent(nombreInforme)}?anio=${anio}&mes=${mes}`;

        // 1b. Añadir meses seleccionados y label del informe
        if (labelInforme) {
            url += `&label=${encodeURIComponent(labelInforme)}`;
        }

        // 1b. Añadir meses seleccionados (ej: &meses=1,3,4)
        if (mesesSeleccionados && mesesSeleccionados.length > 0) {
            url += `&meses=${mesesSeleccionados.join(',')}`;
        }

        // 1b. Capturar número de página desde el input asociado al botón (si existe)
        const idInputPag = btn?.dataset?.inputPag;
        if (idInputPag) {
            const rawPag = document.getElementById(idInputPag)?.value;
            const nroPagina = rawPag != null ? parseInt(rawPag, 10) : null;
            if (nroPagina > 0) {
                url += `&nroPagina=${nroPagina}`;
            }
        }

        // 2. Capturar todos los filtros data-* del botón y agregarlos como query params
        if (btn && btn.dataset) {
            for (const [key, value] of Object.entries(btn.dataset)) {
                // Ignorar atributos propios del manager (inputPag, etc.)
                if (key === 'inputPag') continue;
                if (value !== undefined && value !== null && value !== '') {
                    url += `&${encodeURIComponent(key)}=${encodeURIComponent(value)}`;
                }
            }
        }

        // 3. También capturar los inputs globales si aplican (umbral, limiteImporte, limitePaises)
        const umbralGlobal = document.getElementById('inputUmbral')?.value;
        if (umbralGlobal) {
            url += `&umbral=${encodeURIComponent(umbralGlobal)}`;
        }

        const limiteMontoGlobal = document.getElementById('inputLimiteMonto')?.value;
        if (limiteMontoGlobal && parseFloat(limiteMontoGlobal) > 0) {
            url += `&limiteImporte=${encodeURIComponent(limiteMontoGlobal)}`;
        }

        const limitePaisesGlobal = document.getElementById('inputLimiteNumeroPaises')?.value;
        if (limitePaisesGlobal && parseInt(limitePaisesGlobal, 10) > 0) {
            url += `&limitePaises=${encodeURIComponent(limitePaisesGlobal)}`;
        }

        // 4. Verificar autenticación antes de la petición
        const token = sessionStorage.getItem('jwt_token');
        if (!token) {
            GlobalUI.showAlert('Sesión no iniciada. Por favor, recargue la página y vuelva a autenticarse.', 'warning');
            return;
        }

        // 5. Realizar la petición Fetch al endpoint (con JWT para autenticación)
        const response = await fetch(url, {
            method: 'GET',
            headers: {
                'Accept': 'text/html',
                'Authorization': `Bearer ${token}`
            }
        });

        if (!response.ok) {
            if (response.status === 401) {
                GlobalUI.showAlert('Su sesión ha expirado. Recargue la página y vuelva a iniciar sesión.', 'warning');
            } else if (response.status === 400) {
                const errorText = await response.text();
                GlobalUI.showAlert(`Error en la petición: ${errorText}`, 'error');
            } else {
                GlobalUI.showAlert('Error al generar el informe portable. Intente de nuevo.', 'error');
            }
            return;
        }

        // 6. Convertir la respuesta a blob y descargar el archivo
        const blob = await response.blob();
        const contentDisposition = response.headers.get('content-disposition');
        const MESES_ABREV = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
        const sufijoMeses = mesesSeleccionados && mesesSeleccionados.length > 0
            ? '_' + mesesSeleccionados.map(m => MESES_ABREV[m-1]).join('_')
            : '';
        const nombreArchivo = (labelInforme || nombreInforme).normalize('NFD').replace(/[\u0300-\u036f]/g, '');
        let fileName = `${nombreArchivo}${sufijoMeses}.html`;

        // Intentar extraer el nombre del archivo desde el header Content-Disposition
        if (contentDisposition) {
            const match = contentDisposition.match(/filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/);
            if (match && match[1]) {
                fileName = match[1].replace(/['"]/g, '');
            }
        }

        // Crear enlace temporal para descarga automática
        const downloadUrl = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = downloadUrl;
        a.download = fileName;
        document.body.appendChild(a);
        a.click();

        // Limpieza
        setTimeout(() => {
            document.body.removeChild(a);
            window.URL.revokeObjectURL(downloadUrl);
        }, 100);

        GlobalUI.showAlert('Informe portable descargado correctamente', 'success');

    } catch (error) {
        console.error('Error al generar HTML portable:', error);
        GlobalUI.showAlert('Error al generar el informe portable. Verifique su conexión e inténtelo de nuevo.', 'error');
    } finally {
        GlobalUI.hideLoading();
    }
}
