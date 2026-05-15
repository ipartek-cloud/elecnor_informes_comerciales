using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.AspNetCore.Hosting;

namespace Elecnor_Informes_Comerciales.Services;

/// <summary>
/// Servicio encargado de ensamblar el HTML final del informe portable.
/// Inyecta estilos, scripts, datos JSON y el adaptador portable en una plantilla HTML base.
/// </summary>
public class HtmlAssemblerService
{
    private readonly AssetInliningService _assetInliningService;
    private readonly IWebHostEnvironment _env;
    private readonly ILogger<HtmlAssemblerService> _logger;

    public HtmlAssemblerService(
        AssetInliningService assetInliningService,
        IWebHostEnvironment env,
        ILogger<HtmlAssemblerService> logger)
    {
        _assetInliningService = assetInliningService;
        _env = env;
        _logger = logger;
    }

    /// <summary>
    /// Construye el HTML completo del informe portable.
    /// </summary>
    public async Task<string> AssembleHtmlAsync(
        string tipoInforme,
        int anio,
        int mesHasta,
        List<int> mesesGenerados,
        Dictionary<int, object> datosPorMes,
        Dictionary<string, string>? filtros)
    {
        var sb = new StringBuilder();

        // 1. HTML Base
        sb.AppendLine("<!DOCTYPE html>");
        sb.AppendLine("<html lang=\"es\">");
        sb.AppendLine("<head>");
        sb.AppendLine("<meta charset=\"utf-8\" />");
        sb.AppendLine("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />");
        sb.AppendLine($"<title>Informe {tipoInforme} - {anio}</title>");

        // 2. Inyectar Bootstrap CSS (solo utilidades usadas)
        var bootstrapCss = await _assetInliningService.GetAssetContentAsync("lib/bootstrap/bootstrap-util.min.css");
        if (!string.IsNullOrWhiteSpace(bootstrapCss))
        {
            sb.AppendLine("<style>");
            sb.AppendLine(MinifyCss(bootstrapCss));
            sb.AppendLine("</style>");
        }

        // 3. Inyectar CSS base de informes
        var cssBase = await _assetInliningService.GetAssetContentAsync("css/informes/informes_base.css");
        sb.AppendLine("<style>");
        sb.AppendLine(MinifyCss(cssBase));
        sb.AppendLine("</style>");

        // 4. Inyectar CSS específico del informe
        var cssEspecifico = await _assetInliningService.GetAssetContentAsync($"css/informes/{tipoInforme}.css");
        if (!string.IsNullOrWhiteSpace(cssEspecifico))
        {
            sb.AppendLine("<style>");
            sb.AppendLine(MinifyCss(cssEspecifico));
            sb.AppendLine("</style>");
        }

        // 5. Inyectar CSS para la botonera de navegación offline
        sb.AppendLine("<style>");
        sb.AppendLine(MinifyCss(GetOfflineNavCss()));
        sb.AppendLine("</style>");

        // 5b. Forzar layout idéntico al modal web (fondo gris, sin márgenes de body)
        sb.AppendLine("<style>");
        sb.AppendLine("html,body{margin:0;padding:0;background-color:#666e76;min-height:100vh;width:100%;box-sizing:border-box}");
        sb.AppendLine("#modalInformeContenido{width:100%;min-height:100vh;padding:0}");
        sb.AppendLine(".rpt-paper{max-width:1050px!important;margin:20px auto!important}");
        sb.AppendLine("</style>");

        sb.AppendLine("</head>");
        sb.AppendLine("<body>");

        // 5. Botonera de navegación por meses (solo los generados)
        sb.AppendLine(GenerateNavigationBar(anio, mesesGenerados, datosPorMes));

        // 6. Contenedor principal del informe (similar al modal)
        sb.AppendLine("<div id=\"modalInformeContenido\" class=\"modal-body-reports\"></div>");

        // 7. Datos JSON embebidos (sanitizados)
        sb.AppendLine("<script>");
        sb.AppendLine("window.__PORTABLE_DATA__ = ");
        sb.AppendLine(SerializeDataSafely(datosPorMes, anio, mesHasta, mesesGenerados, tipoInforme, filtros));
        sb.AppendLine(";");
        sb.AppendLine("</script>");

        // 8. Logo Elecnor en Base64 (para modo offline file://)
        var logoBase64 = await GetLogoBase64Async();

        // 9. Inyectar scripts base (sin site.js)
        var utilsJs = await _assetInliningService.GetAssetContentAsync("js/informes/utils.js");
        var informesUtilsJs = await _assetInliningService.GetAssetContentAsync("js/informes/informes_unificados_utils.js");

        // 11. Inyectar scripts base inline, adaptados y minificados
        if (!string.IsNullOrWhiteSpace(utilsJs))
        {
            var utilsAdaptado = MinifyJs(ReplaceLogoPath(AdaptJsModuleForOffline(utilsJs), logoBase64));
            sb.AppendLine("<script>");
            sb.AppendLine(utilsAdaptado);
            sb.AppendLine("</script>");
        }
        if (!string.IsNullOrWhiteSpace(informesUtilsJs))
        {
            var informesUtilsAdaptado = MinifyJs(ReplaceLogoPath(AdaptJsModuleForOffline(informesUtilsJs), logoBase64));
            sb.AppendLine("<script>");
            sb.AppendLine(informesUtilsAdaptado);
            sb.AppendLine("</script>");
        }

        // 12. Adaptador Portable (Mock de ApiClient, etc.)
        sb.AppendLine("<script>");
        sb.AppendLine(MinifyJs(GetPortableAdapterJs()));
        sb.AppendLine("</script>");

        // 13. Script específico del informe con adaptación de imports
        var informeJs = await _assetInliningService.GetAssetContentAsync($"js/informes/{tipoInforme}.js");
        if (!string.IsNullOrWhiteSpace(informeJs))
        {
            var jsAdaptado = MinifyJs(ReplaceLogoPath(AdaptJsModuleForOffline(informeJs), logoBase64));
            sb.AppendLine("<script>");
            sb.AppendLine(jsAdaptado);
            sb.AppendLine("if(typeof ejecutar!=='undefined')window.ejecutar=ejecutar");
            sb.AppendLine("</script>");
        }

        // 14. Script de inicialización
        sb.AppendLine("<script>");
        sb.AppendLine(MinifyJs(GetInitializationScript(anio, mesesGenerados)));
        sb.AppendLine("</script>");

        sb.AppendLine("</body>");
        sb.AppendLine("</html>");

        return MinifyHtml(sb.ToString());
    }

    /// <summary>
    /// Adapta el código JS del módulo del informe para funcionar offline.
    /// Elimina sentencias 'import' y 'export', reemplaza referencias relativas.
    /// Soporta declaraciones multilínea (import/export que abarcan varias líneas).
    /// </summary>
    private string AdaptJsModuleForOffline(string jsContent)
    {
        var lines = jsContent.Replace("\r\n", "\n").Replace("\r", "\n").Split('\n');
        var result = new List<string>();
        bool insideMultilineImport = false;
        bool insideMultilineExportBlock = false;

        foreach (var line in lines)
        {
            var trimmed = line.Trim();

            // Si estamos dentro de un import multilínea, seguir omitiendo hasta encontrar el cierre
            if (insideMultilineImport)
            {
                if (trimmed.EndsWith(";") || trimmed.Contains("from"))
                    insideMultilineImport = false;
                continue;
            }

            // Si estamos dentro de un export { ... } multilínea
            if (insideMultilineExportBlock)
            {
                if (trimmed == "}" || trimmed.StartsWith("}"))
                    insideMultilineExportBlock = false;
                continue;
            }

            // Detectar import multilínea: "import {" sin cierre en la misma línea
            if (trimmed.StartsWith("import {"))
            {
                if (trimmed.EndsWith(";"))
                {
                    // Import en una sola línea: omitir completamente
                    continue;
                }
                else
                {
                    // Import multilínea: entrar en modo omisión
                    insideMultilineImport = true;
                    continue;
                }
            }

            // Import simple: "import X from '...'" o "import '...'" — omitir
            if (trimmed.StartsWith("import ") && !trimmed.StartsWith("import {"))
            {
                continue;
            }

            // Export de función o clase: quitar solo la palabra "export "
            if (trimmed.StartsWith("export async function") ||
                trimmed.StartsWith("export function") ||
                trimmed.StartsWith("export class"))
            {
                result.Add(line.Replace("export ", ""));
                continue;
            }

            // Export de variable/constante: quitar solo la palabra "export "
            if (trimmed.StartsWith("export const ") ||
                trimmed.StartsWith("export let ") ||
                trimmed.StartsWith("export var "))
            {
                result.Add(line.Replace("export ", ""));
                continue;
            }

            // Export de bloque: "export { a, b }" o "export { a, b };"
            if (trimmed.StartsWith("export {"))
            {
                if (trimmed.EndsWith(";") || trimmed.EndsWith("}"))
                {
                    // Export en una sola línea: omitir completamente
                    continue;
                }
                else
                {
                    // Export multilínea: entrar en modo omisión
                    insideMultilineExportBlock = true;
                    continue;
                }
            }

            // Otras líneas de export (export default, etc.): omitir
            if (trimmed.StartsWith("export "))
            {
                continue;
            }

            result.Add(line);
        }

        return string.Join(Environment.NewLine, result);
    }

    /// <summary>
    /// Serializa los datos de forma segura, escapando secuencias peligrosas.
    /// </summary>
    private string SerializeDataSafely(Dictionary<int, object> datos, int anio, int mesHasta, List<int> mesesGenerados, string tipoInforme, Dictionary<string, string>? filtros)
    {
        var mostrarTitulo = filtros == null ||
            !filtros.TryGetValue("mostrarTitulo", out var mt) || mt != "false";

        // Extraer nroPagina de los filtros (viene del input de página del frontend)
        int? nroPagina = null;
        if (filtros != null && filtros.TryGetValue("nroPagina", out var nroPaginaStr) && int.TryParse(nroPaginaStr, out var nroPaginaVal))
        {
            nroPagina = nroPaginaVal;
        }

        var dataObj = new
        {
            meta = new
            {
                tipoInforme = tipoInforme,
                anio = anio,
                mesHasta = mesHasta,
                meses = mesesGenerados,
                mostrarTitulo = mostrarTitulo,
                nroPagina = nroPagina,
                mostrarNumeroPagina = nroPagina.HasValue
            },
            data = datos
        };

        var json = JsonSerializer.Serialize(dataObj, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            WriteIndented = false
        });

        // Sanitización crítica: escapar </script> para prevenir XSS
        return json.Replace("</script>", "<\\/script>")
                   .Replace("<script", "<\\/script")
                   .Replace("</SCRIPT>", "<\\/SCRIPT>");
    }

    /// <summary>
    /// Verifica si los datos de un mes contienen información real (colecciones no vacías).
    /// Búsqueda recursiva para soportar DTOs con estructura jerárquica anidada (ej: ContratacionesResponseDto).
    /// </summary>
    private static bool MesTieneDatosReales(object? datos)
    {
        if (datos == null) return false;

        var type = datos.GetType();

        // Tipos simples/valor sin datos de negocio
        if (type.IsPrimitive || type == typeof(string) || type == typeof(decimal)
            || type == typeof(DateTime) || type.IsEnum || type.IsValueType)
            return false;

        // Si es una colección, verificar si tiene elementos
        if (datos is System.Collections.IEnumerable enumerable && !(type == typeof(string)))
        {
            foreach (var item in enumerable)
                return true;
            return false;
        }

        // Objeto complejo: buscar recursivamente en sus propiedades
        var properties = type.GetProperties(System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance);
        foreach (var prop in properties)
        {
            if (prop.GetIndexParameters().Length > 0) continue;

            var value = prop.GetValue(datos);
            if (value == null) continue;
            if (MesTieneDatosReales(value)) return true;
        }

        return false;
    }

    /// <summary>
    /// Genera la botonera de navegación por meses.
    /// Los meses sin datos aparecen deshabilitados (difuminados).
    /// </summary>
    private string GenerateNavigationBar(int anio, List<int> mesesGenerados, Dictionary<int, object> datosPorMes)
    {
        var sb = new StringBuilder();
        sb.AppendLine("<div class=\"rpt-offline-nav no-print\">");
        sb.AppendLine("<span class=\"rpt-offline-nav-title\">Mes:</span>");

        var meses = new[] { "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic" };

        foreach (var m in mesesGenerados)
        {
            bool hasData = datosPorMes.TryGetValue(m, out var datosMes) && MesTieneDatosReales(datosMes);
            string clickAttr = hasData
                ? $"onclick=\"window.navegarMesOffline({anio}, {m})\""
                : $"onclick=\"window.alertarMesSinDatos({m})\"";
            string extraClass = hasData ? "" : " disabled";

            sb.AppendLine($"<button type=\"button\" class=\"{extraClass}\" data-m=\"{m}\" {clickAttr}>{meses[m - 1]}</button>");
        }

        sb.AppendLine("</div>");
        return sb.ToString();
    }

    /// <summary>
    /// Genera el CSS para la botonera de navegación offline.
    /// </summary>
    private string GetOfflineNavCss()
    {
        return @"
.rpt-offline-nav { position: sticky; top: 0; z-index: 1000; background-color: #f8f9fa; border-bottom: 1px solid #dee2e6; padding: 10px; display: flex; justify-content: center; gap: 6px; align-items: center; }
.rpt-offline-nav-title { font-family: Verdana, sans-serif; font-size: 10pt; color: #00468B; margin-right: 12px; font-weight: bold; }
.rpt-offline-nav button { padding: 6px 18px; border: 1px solid #00468B; background-color: #fff; color: #00468B; cursor: pointer; font-family: Verdana, sans-serif; font-size: 10pt; border-radius: 3px; transition: all 0.2s; }
.rpt-offline-nav button:hover { background-color: #e6f0fa; }
.rpt-offline-nav button.active { background-color: #00468B; color: #fff; }
.rpt-offline-nav button.disabled { opacity: 0.4; cursor: not-allowed; background-color: #e9ecef; color: #6c757d; border-color: #ced4da; }
.rpt-offline-nav button.disabled:hover { background-color: #e9ecef; }
@media print { .rpt-offline-nav { display: none !important; } .no-print { display: none !important; } }
";
    }

    /// <summary>
    /// Genera el Adaptador Portable (Mock de ApiClient y GlobalUI).
    /// Este es el núcleo del modo offline.
    /// </summary>
    private string GetPortableAdapterJs()
    {
        return @"
// === ADAPTADOR PORTABLE ===
// Mockea el entorno web para funcionamiento offline

// 1. Mock de ApiClient - intercepta peticiones y devuelve datos locales
window.ApiClient = {
    get: async function(url) {
        const urlObj = new URL(url, 'http://localhost');
        const mesParam = urlObj.searchParams.get('mes');
        const mes = mesParam ? parseInt(mesParam) : null;

        if (!mes || !window.__PORTABLE_DATA__ || !window.__PORTABLE_DATA__.data[mes]) {
            return { ok: true, json: async () => ({ meta: { titulo: 'Sin datos' } }) };
        }

        return {
            ok: true,
            json: async () => window.__PORTABLE_DATA__.data[mes]
        };
    },
    post: async function(url, body) {
        // No se usa en informes offline, pero se define para evitar errores
        return { ok: false };
    }
};

// 2. Mock de GlobalUI - funciones vacías para evitar errores
window.GlobalUI = {
    showLoading: function() { /* no-op */ },
    hideLoading: function() { /* no-op */ },
    showAlert: function(msg, tipo, titulo) { console.log('[Portable Alert]', msg); },
    showConfirm: async function(msg, titulo) { return true; }
};

// 3. Mock de Swal (SweetAlert2) para evitar errores en modo offline
window.Swal = window.Swal || {
    fire: function(opts) { console.log('[Portable Swal]', opts); return Promise.resolve({ isConfirmed: true }); }
};

// 4. Función de alerta para meses sin datos
window.alertarMesSinDatos = function(mes) {
    var meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    alert('No hay datos disponibles para el mes de ' + (meses[mes-1] || mes) + '.');
};

// 5. Función de navegación entre meses
window.navegarMesOffline = function(anio, mes) {
    var datosMes = window.__PORTABLE_DATA__?.data?.[mes];
    if (!datosMes) {
        window.alertarMesSinDatos(mes);
        return;
    }

    // Actualizar meta con el mes actual
    if (window.__PORTABLE_DATA__.meta) {
        window.__PORTABLE_DATA__.meta.mes = mes;
    }

    // Actualizar estado visual de la botonera
    document.querySelectorAll('.rpt-offline-nav button').forEach(btn => {
        btn.classList.toggle('active', parseInt(btn.dataset.m) === mes);
    });

    // Extraer nroPagina: primero de los datos del mes, luego del meta global (fallback)
    var nroPagina = null;
    if (datosMes.meta && datosMes.meta.filtros && datosMes.meta.filtros.nroPagina != null) {
        nroPagina = datosMes.meta.filtros.nroPagina;
    } else if (datosMes.meta && datosMes.meta.nroPagina != null) {
        nroPagina = datosMes.meta.nroPagina;
    }
    // Fallback: usar el nroPagina global de la petición original (para servicios que no reciben nroPagina)
    if (nroPagina == null && window.__PORTABLE_DATA__.meta && window.__PORTABLE_DATA__.meta.nroPagina != null) {
        nroPagina = window.__PORTABLE_DATA__.meta.nroPagina;
    }

    // Invocar la función ejecutar del módulo del informe pasando objeto de parámetros (Context Object)
    if (typeof window.ejecutar === 'function') {
        const meta = window.__PORTABLE_DATA__?.meta || {};
        window.ejecutar({
            anio: anio,
            mes: mes,
            nroPagina: nroPagina,
            mostrarTitulo: meta.mostrarTitulo !== false
        });
    } else {
        console.error('La función ejecutar no está disponible.');
    }
};

// 6. Simular estructura básica de Bootstrap Modal si no existe
if (!window.bootstrap) {
    window.bootstrap = { Modal: { getOrCreateInstance: function(el) { return { show: function() {}, hide: function() {} }; } } };
}
";
    }

    /// <summary>
    /// Genera el script de inicialización que se ejecuta al cargar la página.
    /// </summary>
    private string GetInitializationScript(int anio, List<int> mesesGenerados)
    {
        var ultimoMes = mesesGenerados[mesesGenerados.Count - 1];
        return $@"
(function() {{
    if (window.__PORTABLE_DATA__ && window.__PORTABLE_DATA__.data) {{
        window.__PORTABLE_DATA__.meta = window.__PORTABLE_DATA__.meta || {{}};
        window.__PORTABLE_DATA__.meta.anio = {anio};
        window.navegarMesOffline({anio}, {ultimoMes});
    }}
}})();
";
    }

    /// <summary>
    /// Lee el logo Elecnor del disco y lo convierte a data URI Base64.
    /// </summary>
    private async Task<string> GetLogoBase64Async()
    {
        var logoPath = Path.Combine(_env.WebRootPath, "images", "logoElecnor.png");
        if (!File.Exists(logoPath))
        {
            _logger.LogWarning("[HtmlAssembler] Logo no encontrado en {Path}", logoPath);
            return "/images/logoElecnor.png";
        }

        var bytes = await File.ReadAllBytesAsync(logoPath);
        return $"data:image/png;base64,{Convert.ToBase64String(bytes)}";
    }

    /// <summary>
    /// Reemplaza la ruta del logo por su versión Base64 en el contenido JS adaptado.
    /// </summary>
    private static string ReplaceLogoPath(string jsContent, string logoBase64)
    {
        return jsContent.Replace("/images/logoElecnor.png", logoBase64);
    }

    /// <summary>
    /// Minifica CSS: elimina comentarios y colapsa espacios innecesarios.
    /// </summary>
    private static string MinifyCss(string css)
    {
        css = Regex.Replace(css, @"/\*.*?\*/", "", RegexOptions.Singleline);
        css = Regex.Replace(css, @"\s+", " ");
        css = Regex.Replace(css, @"\s*([{};:,>])\s*", "$1");
        return css.Trim();
    }

    /// <summary>
    /// Minifica JS: elimina comentarios de bloque, líneas solo-comentario y colapsa líneas vacías.
    /// </summary>
    private static string MinifyJs(string js)
    {
        js = Regex.Replace(js, @"/\*[\s\S]*?\*/", "");
        var lines = js.Replace("\r\n", "\n").Replace("\r", "\n").Split('\n');
        var result = new List<string>();
        bool prevEmpty = false;
        foreach (var line in lines)
        {
            var trimmed = line.Trim();
            if (string.IsNullOrEmpty(trimmed))
            {
                if (!prevEmpty && result.Count > 0)
                    result.Add("");
                prevEmpty = true;
                continue;
            }
            if (trimmed.StartsWith("//") || trimmed.StartsWith("*"))
            {
                if (!prevEmpty && result.Count > 0)
                    result.Add("");
                prevEmpty = true;
                continue;
            }
            result.Add(line);
            prevEmpty = false;
        }
        return string.Join("\n", result).Trim();
    }

    /// <summary>
    /// Minifica HTML: elimina la inyección de Browser Link de Visual Studio.
    /// </summary>
    private static string MinifyHtml(string html)
    {
        return Regex.Replace(html, @"<!-- Visual Studio Browser Link -->.*?<!-- End Browser Link -->", "",
            RegexOptions.Singleline);
    }
}
