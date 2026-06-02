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

// Timestamp único por ciclo de vida de la página para evitar caché del navegador en scripts JS
const _cacheBuster = Date.now();

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
 * Inicializa los Popovers interactivos (Tippy.js) para los botones de informe.
 * - Si el informe tiene límites (Monto/Países), muestra una ventana con inputs.
 * - Si NO tiene límites, el botón mantiene su comportamiento directo (excepción UX).
 */
// Helper para formatear un valor numérico con puntos de miles (es-ES)
const formatearMiles = (val) => {
    if (val === undefined || val === null || val === '') return '';
    const num = parseInt(val.toString().replace(/\./g, ''), 10);
    if (isNaN(num)) return '';
    return num.toLocaleString('es-ES');
};

// Helper para obtener el número puro eliminando puntos de miles
const desformatearMiles = (val) => {
    if (val === undefined || val === null || val === '') return null;
    const limpio = val.toString().replace(/\./g, '');
    return limpio ? parseFloat(limpio) : null;
};

/**
 * Inicializa los Popovers interactivos (Tippy.js) para los botones de informe.
 * - Si el informe tiene límites (Monto/Países), muestra una ventana con inputs.
 * - Si NO tiene límites, el botón mantiene su comportamiento directo (excepción UX).
 */
function inicializarTooltipsFiltros() {
    if (typeof tippy === 'undefined') return;

    // 1. Identificar botones que requieren Popover (Límites o Umbral)
    const allBtns = document.querySelectorAll('.btn.rpt-btn-index');
    const btnsConPop = [];
    
    allBtns.forEach(btn => {
        // En HTML5, los data-* siempre se normalizan a minúsculas en el dataset
        const ds = btn.dataset;
        if (ds.limiteimporte !== undefined || ds.limitepaises !== undefined || ds.umbral !== undefined || ds.numeropaises !== undefined || ds.umbral1 !== undefined) {
            
            // Destruir instancia de Tippy previa si existe en este botón para evitar acumulaciones
            if (btn._tippy) {
                btn._tippy.destroy();
            }

            btnsConPop.push(btn);
            
            // Extraer nombre del informe del onclick original y guardarlo en el dataset
            if (!ds.nombreInforme) {
                const onclickAttr = btn.getAttribute('onclick');
                const match = onclickAttr?.match(/cargarInforme\s*\(\s*this\s*,\s*['"]([^'"]+)['"]\s*\)/);
                if (match) {
                    btn.dataset.nombreInforme = match[1];
                    btn.removeAttribute('onclick'); // Evitar ejecución directa
                }
            }
        }
    });

    // 2. Configurar Popovers interactivos
    tippy(btnsConPop, {
        theme: 'elecnor-popover',
        placement: 'top',
        trigger: 'click',
        interactive: true,
        allowHTML: true,
        animation: 'shift-away',
        arrow: true,
        appendTo: () => document.body,
        onShow(instance) {
            const btn = instance.reference;
            const ds = btn.dataset;
            
            // Valores por defecto
            const defaultMonto = ds.limiteimporte || 13000;
            const defaultPaises = ds.limitepaises || 20;
            const defaultUmbral = ds.umbral || 0;
            const defaultNumeroPaises = ds.numeropaises || 0;
            const defaultUmbral1 = ds.umbral1 || 5000;
            const defaultUmbral2 = ds.umbral2 || 15000;
            const defaultUmbral3 = ds.umbral3 || 10000;
            const defaultUmbral4 = ds.umbral4 || 25000;

            let content = `
                <div class="rpt-popover-filtros p-2" style="min-width: 180px; font-family: Verdana, Geneva, sans-serif;">
                    <div class="fw-bold mb-2 pb-1 border-bottom" style="font-size: 0.85rem; color: #005596;">
                        Parámetros del Informe
                    </div>
            `;
            
            if (ds.limiteimporte !== undefined) {
                content += `
                    <div class="mb-2">
                        <label class="small fw-bold d-block mb-1 text-muted">Límite Monto (Miles de Euros):</label>
                        <input type="text" id="pop-monto" class="form-control form-control-sm text-center fw-bold input-miles" 
                               value="${formatearMiles(defaultMonto)}" style="font-size: 0.8rem;">
                    </div>
                `;
            }

            if (ds.limitepaises !== undefined) {
                content += `
                    <div class="mb-2">
                        <label class="small fw-bold d-block mb-1 text-muted">Límite Países:</label>
                        <input type="text" id="pop-paises" class="form-control form-control-sm text-center fw-bold input-miles" 
                               value="${formatearMiles(defaultPaises)}" style="font-size: 0.8rem;">
                    </div>
                `;
            }

            if (ds.umbral !== undefined) {
                content += `
                    <div class="mb-2">
                        <label class="small fw-bold d-block mb-1 text-muted">Umbral de Filtrado (0 = Todos):</label>
                        <input type="text" id="pop-umbral" class="form-control form-control-sm text-center fw-bold input-miles" 
                               value="${formatearMiles(defaultUmbral)}" style="font-size: 0.8rem;">
                    </div>
                `;
            }

            if (ds.numeropaises !== undefined) {
                content += `
                    <div class="mb-2">
                        <label class="small fw-bold d-block mb-1 text-muted">Número de Países (0 = Todos):</label>
                        <input type="text" id="pop-numeropaises" class="form-control form-control-sm text-center fw-bold input-miles" 
                               value="${formatearMiles(defaultNumeroPaises)}" style="font-size: 0.8rem;">
                    </div>
                `;
            }

            if (ds.umbral1 !== undefined) {
                content += `
                    <div class="mb-2">
                        <label class="small fw-bold d-block mb-1 text-muted">Límite Monto 1º (Miles de Euros):</label>
                        <input type="text" id="pop-umbral1" class="form-control form-control-sm text-center fw-bold input-miles" 
                               value="${formatearMiles(defaultUmbral1)}" style="font-size: 0.8rem;">
                    </div>
                `;
            }
            if (ds.umbral2 !== undefined) {
                content += `
                    <div class="mb-2">
                        <label class="small fw-bold d-block mb-1 text-muted">Límite Monto 2º (Miles de Euros):</label>
                        <input type="text" id="pop-umbral2" class="form-control form-control-sm text-center fw-bold input-miles" 
                               value="${formatearMiles(defaultUmbral2)}" style="font-size: 0.8rem;">
                    </div>
                `;
            }
            if (ds.umbral3 !== undefined) {
                content += `
                    <div class="mb-2">
                        <label class="small fw-bold d-block mb-1 text-muted">Límite Monto 3º (Miles de Euros):</label>
                        <input type="text" id="pop-umbral3" class="form-control form-control-sm text-center fw-bold input-miles" 
                               value="${formatearMiles(defaultUmbral3)}" style="font-size: 0.8rem;">
                    </div>
                `;
            }
            if (ds.umbral4 !== undefined) {
                content += `
                    <div class="mb-2">
                        <label class="small fw-bold d-block mb-1 text-muted">Límite Monto 4º (Miles de Euros):</label>
                        <input type="text" id="pop-umbral4" class="form-control form-control-sm text-center fw-bold input-miles" 
                               value="${formatearMiles(defaultUmbral4)}" style="font-size: 0.8rem;">
                    </div>
                `;
            }

            content += `
                <button class="btn btn-primary btn-sm w-100 mt-2 rpt-btn-pop-aceptar" id="btn-pop-aceptar">
                    <i class="fas fa-play me-1"></i> Generar Informe
                </button>
            </div>`;

            instance.setContent(content);
        },
        onMount(instance) {
            // Usar onMount para asegurar que el contenido está en el DOM
            const box = instance.popper;
            const btnAceptar = box.querySelector('#btn-pop-aceptar');
            
            if (btnAceptar) {
                // Formatear automáticamente con separador de miles al escribir
                const inputsMiles = box.querySelectorAll('.input-miles');
                inputsMiles.forEach(input => {
                    input.oninput = () => {
                        let rawVal = input.value.replace(/\D/g, ''); // Eliminar caracteres no numéricos
                        if (!rawVal) {
                            input.value = '';
                            return;
                        }
                        const num = parseInt(rawVal, 10);
                        input.value = num.toLocaleString('es-ES');
                    };
                });

                btnAceptar.onclick = () => {
                    const monto = box.querySelector('#pop-monto')?.value;
                    const paises = box.querySelector('#pop-paises')?.value;
                    const umbral = box.querySelector('#pop-umbral')?.value;
                    const numeroPaises = box.querySelector('#pop-numeropaises')?.value;
                    const umbral1 = box.querySelector('#pop-umbral1')?.value;
                    const umbral2 = box.querySelector('#pop-umbral2')?.value;
                    const umbral3 = box.querySelector('#pop-umbral3')?.value;
                    const umbral4 = box.querySelector('#pop-umbral4')?.value;
                    
                    const nombreInforme = instance.reference.dataset.nombreInforme;
                    
                    instance.hide(); // Cerrar popover
                    
                    // Ejecutar carga de informe con los valores numéricos puros (sin puntos)
                    window.cargarInforme(instance.reference, nombreInforme, {
                        limiteImporte: desformatearMiles(monto),
                        limitePaises: desformatearMiles(paises) ? parseInt(desformatearMiles(paises), 10) : null,
                        umbral: desformatearMiles(umbral),
                        numeroPaises: desformatearMiles(numeroPaises) ? parseInt(desformatearMiles(numeroPaises), 10) : null,
                        umbral1: desformatearMiles(umbral1),
                        umbral2: desformatearMiles(umbral2),
                        umbral3: desformatearMiles(umbral3),
                        umbral4: desformatearMiles(umbral4)
                    });
                };

                // También permitir ejecutar al pulsar Enter en los inputs
                const inputs = box.querySelectorAll('input');
                inputs.forEach(input => {
                    input.onkeydown = (e) => {
                        if (e.key === 'Enter') btnAceptar.click();
                    };
                });
            }
        }
    });
}

// Inicializar cuando el DOM esté listo o se cargue el script
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', inicializarTooltipsFiltros);
} else {
    inicializarTooltipsFiltros();
}

window.cargarInforme = async function (btn, nombreInforme, filtrosManuales = null) {

    // Mantener compatibilidad si se llama solo con nombreInforme
    if (typeof btn === 'string') {
        nombreInforme = btn;
        btn = null;
    }

    const anio = document.getElementById('txtAnno').value;
    const mes  = document.getElementById('txtMes').value;

    // --- RESOLUCIÓN DE LÍMITES (Contextual) ---
    // Si vienen filtros manuales (desde Popover), tienen prioridad absoluta.
    // Si no, se usan los data-attributes del botón o valores por defecto.
    let limiteImporteFinal;
    if (filtrosManuales && filtrosManuales.limiteImporte !== undefined && filtrosManuales.limiteImporte !== null) {
        limiteImporteFinal = filtrosManuales.limiteImporte;
    } else {
        limiteImporteFinal = btn?.dataset?.limiteimporte ? parseFloat(btn.dataset.limiteimporte) : 13000;
    }

    let limitePaisesFinal;
    if (filtrosManuales && filtrosManuales.limitePaises !== undefined && filtrosManuales.limitePaises !== null) {
        limitePaisesFinal = filtrosManuales.limitePaises;
    } else {
        limitePaisesFinal = btn?.dataset?.limitepaises ? parseInt(btn.dataset.limitepaises, 10) : 20;
    }

    let umbralFinal;
    if (filtrosManuales && filtrosManuales.umbral !== undefined && filtrosManuales.umbral !== null) {
        umbralFinal = filtrosManuales.umbral;
    } else {
        umbralFinal = btn?.dataset?.umbral || null;
    }
    
    let numeroPaisesFinal;
    if (filtrosManuales && filtrosManuales.numeroPaises !== undefined && filtrosManuales.numeroPaises !== null) {
        numeroPaisesFinal = filtrosManuales.numeroPaises;
    } else {
        numeroPaisesFinal = btn?.dataset?.numeropaises !== undefined ? parseInt(btn.dataset.numeropaises, 10) : null;
    }

    let umbral1Final;
    if (filtrosManuales && filtrosManuales.umbral1 !== undefined && filtrosManuales.umbral1 !== null) {
        umbral1Final = filtrosManuales.umbral1;
    } else {
        umbral1Final = btn?.dataset?.umbral1 ? parseFloat(btn.dataset.umbral1) : null;
    }

    let umbral2Final;
    if (filtrosManuales && filtrosManuales.umbral2 !== undefined && filtrosManuales.umbral2 !== null) {
        umbral2Final = filtrosManuales.umbral2;
    } else {
        umbral2Final = btn?.dataset?.umbral2 ? parseFloat(btn.dataset.umbral2) : null;
    }

    let umbral3Final;
    if (filtrosManuales && filtrosManuales.umbral3 !== undefined && filtrosManuales.umbral3 !== null) {
        umbral3Final = filtrosManuales.umbral3;
    } else {
        umbral3Final = btn?.dataset?.umbral3 ? parseFloat(btn.dataset.umbral3) : null;
    }

    let umbral4Final;
    if (filtrosManuales && filtrosManuales.umbral4 !== undefined && filtrosManuales.umbral4 !== null) {
        umbral4Final = filtrosManuales.umbral4;
    } else {
        umbral4Final = btn?.dataset?.umbral4 ? parseFloat(btn.dataset.umbral4) : null;
    }
    
    // 0. Verificar si está activado el modo HTML Portable
    const chkPortable = document.getElementById('chkGenerarHtmlPortable');
    if (chkPortable && chkPortable.checked) {
        const labelBoton = btn?.textContent?.trim() || nombreInforme;
        const mesesSeleccionados = await _mostrarSelectorMeses(labelBoton, mes);
        if (mesesSeleccionados) {
            _generarHtmlPortable(btn, nombreInforme, mesesSeleccionados, labelBoton, {
                limiteImporte: limiteImporteFinal,
                limitePaises: limitePaisesFinal,
                umbral: umbralFinal,
                numeroPaises: numeroPaisesFinal,
                umbral1: umbral1Final,
                umbral2: umbral2Final,
                umbral3: umbral3Final,
                umbral4: umbral4Final
            });
        }
        return;
    }

    if (!_whitelistInformes[nombreInforme]) {
        console.error(`El informe '${nombreInforme}' no está registrado en el manager.`);
        GlobalUI.showAlert('Informe no autorizado o inexistente', 'error');
        return;
    }

    // Capturar nro de página si el botón indica un input de origen
    const idInputPag = btn?.dataset?.inputPag;
    const rawPag = idInputPag ? document.getElementById(idInputPag)?.value : null;
    const nroPagina = rawPag != null ? parseInt(rawPag, 10) : null;
    const nroPaginaFinal = nroPagina > 0 ? nroPagina : null;

    const mercado = btn?.dataset?.mercado;
    const mostrarTitulo = btn?.dataset?.mostrarTitulo !== 'false';
    const aplicaLimiteMonto = btn?.dataset?.limiteimporte !== undefined;

    let exito = false;

    try {
        GlobalUI.showLoading();

        // 1. Cargar CSS específico del informe
        const idCss = `css-informe-${nombreInforme}`;
        if (!document.getElementById(idCss)) {
            const link = document.createElement('link');
            link.id   = idCss;
            link.rel  = 'stylesheet';
            link.href = `/css/informes/${nombreInforme}.css?v=${Date.now()}`;
            document.head.appendChild(link);
        }

        // 2. Cargar módulo (cacheado por ES modules nativo)
        const path = `./${nombreInforme}.js?v=${_cacheBuster}`;
        if (!_registroModulos[nombreInforme]) {
            _registroModulos[nombreInforme] = await import(path);
        }

        const modulo = _registroModulos[nombreInforme];

        if (modulo && modulo.ejecutar) {
            const _codSubDir = btn?.dataset?.subdireccion || null;
            
            const parametros = {
                anio: anio,
                mes: mes,
                nroPagina: nroPaginaFinal,
                mercado: mercado,
                umbral: umbralFinal,
                numeroPaises: numeroPaisesFinal,
                codSubDir: _codSubDir,
                mostrarTitulo: mostrarTitulo,
                limiteImporte: limiteImporteFinal,
                limitePaises: limitePaisesFinal,
                informe: btn?.dataset?.informe || null,
                umbral1: umbral1Final,
                umbral2: umbral2Final,
                umbral3: umbral3Final,
                umbral4: umbral4Final
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
async function _generarHtmlPortable(btn, nombreInforme, mesesSeleccionados, labelInforme, limitesExtras = null) {
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

        // 3. Aplicar filtros de límites si vienen explícitamente (desde el Popover)
        if (limitesExtras) {
            if (limitesExtras.limiteImporte) {
                url += `&limiteImporte=${encodeURIComponent(limitesExtras.limiteImporte)}`;
            }
            if (limitesExtras.limitePaises) {
                url += `&limitePaises=${encodeURIComponent(limitesExtras.limitePaises)}`;
            }
            if (limitesExtras.umbral !== undefined && limitesExtras.umbral !== null) {
                url += `&umbral=${encodeURIComponent(limitesExtras.umbral)}`;
            }
            if (limitesExtras.numeroPaises !== undefined && limitesExtras.numeroPaises !== null) {
                url += `&numeroPaises=${encodeURIComponent(limitesExtras.numeroPaises)}`;
            }
            if (limitesExtras.umbral1 !== undefined && limitesExtras.umbral1 !== null) {
                url += `&umbral1=${encodeURIComponent(limitesExtras.umbral1)}`;
            }
            if (limitesExtras.umbral2 !== undefined && limitesExtras.umbral2 !== null) {
                url += `&umbral2=${encodeURIComponent(limitesExtras.umbral2)}`;
            }
            if (limitesExtras.umbral3 !== undefined && limitesExtras.umbral3 !== null) {
                url += `&umbral3=${encodeURIComponent(limitesExtras.umbral3)}`;
            }
            if (limitesExtras.umbral4 !== undefined && limitesExtras.umbral4 !== null) {
                url += `&umbral4=${encodeURIComponent(limitesExtras.umbral4)}`;
            }
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
