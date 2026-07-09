using Elecnor_Informes_Comerciales.Services;
using Microsoft.AspNetCore.Mvc;
using System.Reflection;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio orquestador principal para la generación de Informes HTML Portables.
/// Coordina la obtención secuencial de datos multi-mes, el inlining de assets
/// y el ensamblado del HTML final auto-contenido.
/// </summary>
public class InformePortableService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly AssetInliningService _assetInliningService;
    private readonly HtmlAssemblerService _htmlAssemblerService;
    private readonly ILogger<InformePortableService> _logger;

    // Mapeo de tipos de informe a sus servicios correspondientes y métodos Obtener
    private static readonly Dictionary<string, (Type ServiceType, string MethodName)> _serviceMap = new(StringComparer.OrdinalIgnoreCase)
    {
        { "mercados", (typeof(InformeMercadosService), "ObtenerInformeMercadosAsync") },
        { "paises", (typeof(InformePaisesService), "ObtenerInformePaisesAsync") },
        { "paises_all", (typeof(InformePaisesService), "ObtenerInformePaisesAllAsync") },
        { "mercados_dg", (typeof(InformeMercadosDGService), "ObtenerInformeMercadosDGAsync") },
        { "mercados_sg_delegaciones", (typeof(InformeMercadosSGDelegacionesService), "ObtenerInformeAsync") },
        { "actividades", (typeof(InformeActividadesService), "ObtenerInformeAsync") },
        { "actividades_instalaciones_redes", (typeof(InformeActividadesInstalacionesRedesService), "ObtenerInformeAsync") },
        { "CD_Elecnor_DG_Activ_Redes", (typeof(InformeCD_Elecnor_DG_Activ_RedesService), "ObtenerInformeAsync") },
        { "actividades_objetivos", (typeof(InformeActividadesObjetivosService), "ObtenerInformeAsync") },
        { "contrataciones", (typeof(InformeContratacionesService), "ObtenerInformeCompletoAsync") },
        { "contrataciones_ai", (typeof(InformeContratacionesAIService), "ObtenerInformeCompletoAsync") },
        { "contrataciones_significativas", (typeof(InformeContratacionesSignificativasService), "ObtenerInformeAsync") },
        { "contrataciones_significativas_ri", (typeof(InformeContratacionesSignificativasRiService), "ObtenerInformeAsync") },
        { "ranking_contratacion_clientes", (typeof(InformeRankingContratacionClientesService), "ObtenerRankingAsync") },
        { "gerencias", (typeof(InformeGerenciasService), "ObtenerInformeGerenciasAsync") },
        { "gerencias_nacional_internacional", (typeof(InformeGerenciasNacionalInternacionalService), "ObtenerInformeAsync") },
        { "cartera_contratacion_detalle", (typeof(InformeCarteraContratacionDetalleService), "ObtenerInformeAsync") },
        { "cartera_contratacion_resumen_sdg", (typeof(InformeCarteraContratacionResumenSDGService), "ObtenerInformeAsync") },
        { "cartera_contratacion_detalle_org_paises", (typeof(InformeCarteraContratacionDetalleOrgPaisesService), "ObtenerInformeAsync") },
        { "cartera_contratacion_detalle_paises", (typeof(InformeCarteraContratacionDetallePaisesService), "ObtenerInformeAsync") },
        { "actividades_internacional_detalle", (typeof(InformeActividadesInternacionalDetalleService), "ObtenerInformeAsync") },
        { "cartera_diferida_consejo", (typeof(InformeCarteraDiferidaConsejoService), "ObtenerInformeAsync") },
        { "contratacion_mercados_sdg_dn", (typeof(InformeContratacionMercadosSDGDNService), "ObtenerInformeAsync") },
        { "CD_Elecnor_DG_Centros_DGRI_Nuevo", (typeof(CD_Elecnor_DG_Centros_DGRI_NuevoService), "ObtenerInformeAsync") }
    };


    public InformePortableService(
        IServiceProvider serviceProvider,
        AssetInliningService assetInliningService,
        HtmlAssemblerService htmlAssemblerService,
        ILogger<InformePortableService> logger)
    {
        _serviceProvider = serviceProvider;
        _assetInliningService = assetInliningService;
        _htmlAssemblerService = htmlAssemblerService;
        _logger = logger;
    }

    /// <summary>
    /// Genera el HTML portable para un informe dado.
    /// Ejecuta el bucle secuencial de obtención de datos para cada mes (1 a mesHasta).
    /// </summary>
    public async Task<string?> GenerarInformePortableAsync(
        string tipoInforme,
        int anio,
        int mesHasta,
        List<int>? mesesSeleccionados,
        Dictionary<string, string>? filtros,
        string loginUsuario)
    {
        // Normalizar filtros a case-insensitive: los data-* del frontend llegan en minúsculas (ej: "limitepaises")
        // pero los parámetros de servicio usan camelCase (ej: "limitePaises").
        var filtrosNormalizados = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        if (filtros != null)
        {
            foreach (var kvp in filtros)
                filtrosNormalizados[kvp.Key] = kvp.Value;
        }

        _logger.LogInformation(
            "[InformePortable] Generando informe portable: {Tipo}, Año: {Anio}, Meses: {Meses}, Filtros: {@Filtros}",
            tipoInforme, anio, mesesSeleccionados != null ? string.Join(",", mesesSeleccionados) : $"1-{mesHasta}", filtrosNormalizados);

        if (!_serviceMap.ContainsKey(tipoInforme))
        {
            _logger.LogError("[InformePortable] Tipo de informe no soportado: {Tipo}", tipoInforme);
            return null;
        }

        var datosPorMes = new Dictionary<int, object>();
        using var scope = _serviceProvider.CreateScope();

        var mesesAIterar = mesesSeleccionados ?? Enumerable.Range(1, mesHasta).ToList();

        foreach (var mes in mesesAIterar)
        {
            try
            {
                var datosMes = await ObtenerDatosMesAsync(scope, tipoInforme, anio, mes, filtrosNormalizados, loginUsuario);
                if (datosMes != null)
                {
                    datosPorMes[mes] = datosMes;
                    _logger.LogDebug("[InformePortable] Mes {Mes}: {Count} registros obtenidos.", mes, datosMes.ToString()?.Length ?? 0);
                }
                else
                {
                    _logger.LogWarning("[InformePortable] Mes {Mes}: Sin datos.", mes);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[InformePortable] Error al obtener datos para mes {Mes}.", mes);
                // Continuamos con los demás meses incluso si uno falla
            }
        }

        if (!datosPorMes.Any())
        {
            _logger.LogError("[InformePortable] No se obtuvo ningún dato para ningún mes.");
            return null;
        }

        // 3. Ensamblar el HTML final
        var html = await _htmlAssemblerService.AssembleHtmlAsync(
            tipoInforme, anio, mesHasta, mesesAIterar, datosPorMes, filtrosNormalizados);

        return html;
    }

    /// <summary>
    /// Obtiene los datos de un mes específico invocando dinámicamente al servicio correspondiente.
    /// </summary>
    private async Task<object?> ObtenerDatosMesAsync(
        IServiceScope scope, string tipoInforme, int anio, int mes, Dictionary<string, string>? filtros, string loginUsuario)
    {
        if (!_serviceMap.TryGetValue(tipoInforme, out var serviceInfo))
        {
            return null;
        }

        // 1. Obtener el servicio a través del scope compartido (evita crear uno por mes)
        var service = scope.ServiceProvider.GetService(serviceInfo.ServiceType);

        if (service == null)
        {
            _logger.LogError("[InformePortable] No se pudo obtener instancia del servicio {ServiceType}", serviceInfo.ServiceType.FullName);
            return null;
        }

        // 2. Obtener el método por reflection
        var method = serviceInfo.ServiceType.GetMethod(serviceInfo.MethodName,
            System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.Instance);

        if (method == null)
        {
            _logger.LogError("[InformePortable] Método {MethodName} no encontrado en {ServiceType}",
                serviceInfo.MethodName, serviceInfo.ServiceType.FullName);
            return null;
        }

        // 3. Preparar argumentos según el tipo de informe y filtros disponibles
        var parameters = PrepareMethodParameters(method, anio, mes, filtros, tipoInforme, loginUsuario);

        // 4. Invocar el método asincrónicamente
        try
        {
            var result = method.Invoke(service, parameters.ToArray());

            if (result is Task taskResult)
            {
                await taskResult.ConfigureAwait(false);
                var property = taskResult.GetType().GetProperty("Result");
                return property?.GetValue(taskResult);
            }

            return result;
        }
        catch (TargetInvocationException tie) when (tie.InnerException != null)
        {
            // Relanzamos la excepción interna para que se registre correctamente
            throw tie.InnerException;
        }
    }

    /// <summary>
    /// Prepara los parámetros para el método del servicio considerando los filtros data-* del frontend.
    /// </summary>
    private List<object?> PrepareMethodParameters(
        System.Reflection.MethodInfo method,
        int anio,
        int mes,
        Dictionary<string, string>? filtros,
        string tipoInforme,
        string loginUsuario)
    {
        var parameters = method.GetParameters();
        var args = new List<object?>();

        foreach (var param in parameters)
        {
            var paramName = param.Name?.ToLowerInvariant() ?? string.Empty;

            // Parámetro de loginUsuario
            if (paramName == "loginusuario" || paramName == "loginUsuario")
            {
                args.Add(loginUsuario);
                continue;
            }

            // Parámetro básico: anio
            if (paramName == "anio" || paramName == "año")
            {
                args.Add(anio);
                continue;
            }

            // Parámetro básico: mes
            if (paramName == "mes")
            {
                args.Add(mes);
                continue;
            }

            // Parámetro de paginación (nroPagina)
            if (paramName == "nropagina" || paramName == "nroPagina")
            {
                if (filtros != null && filtros.TryGetValue("nroPagina", out var nroPaginaStr)
                    && int.TryParse(nroPaginaStr, out var nroPagina))
                {
                    args.Add(nroPagina);
                }
                else
                {
                    args.Add(ResolveDefaultValue(param));
                }
                continue;
            }

            // Parámetro de umbral (para Países, Ranking, etc.)
            if (paramName == "umbral")
            {
                if (filtros != null && filtros.TryGetValue("umbral", out var umbralStr) && int.TryParse(umbralStr, out var umbral))
                {
                    args.Add(umbral);
                }
                else
                {
                    // Valor por defecto según tipo de informe
                    if (tipoInforme == "paises")
                        args.Add(100000);
                    else
                        args.Add(0);
                }
                continue;
            }

            // Parámetro de mercado (Nacional/Internacional)
            if (paramName == "mercado")
            {
                if (filtros != null && filtros.TryGetValue("mercado", out var mercado))
                    args.Add(mercado);
                else
                    args.Add(ResolveDefaultValue(param));
                continue;
            }

            // Parámetro de subdireccion / codSubDirGeneral
            if (paramName == "subdireccion" || paramName == "codSubDir" || paramName == "codSubdir"
                || paramName == "codsubdirgeneral")
            {
                if (filtros != null && filtros.TryGetValue("subdireccion", out var subdireccion))
                    args.Add(subdireccion);
                else if (filtros != null && filtros.TryGetValue("codSubDir", out var codSubDir))
                    args.Add(codSubDir);
                else if (filtros != null && filtros.TryGetValue("codSubDirGeneral", out var codSubDirGeneral))
                    args.Add(codSubDirGeneral);
                else
                    args.Add(param.HasDefaultValue ? param.DefaultValue : "221");
                continue;
            }

            // Parámetro de mostrarTítulo
            if (paramName == "mostrartitulo" || paramName == "mostrarTitulo")
            {
                if (filtros != null && filtros.TryGetValue("mostrarTitulo", out var mostrarTituloStr) && bool.TryParse(mostrarTituloStr, out var mostrarTitulo))
                    args.Add(mostrarTitulo);
                else
                    args.Add(true);
                continue;
            }

            // Parámetro de limite de importe
            if (paramName == "limiteimporte" || paramName == "limiteImporte")
            {
                if (filtros != null && filtros.TryGetValue("limiteImporte", out var limiteImporteStr) && decimal.TryParse(limiteImporteStr, out var limiteImporte))
                    args.Add(limiteImporte);
                else
                    args.Add(2000m);
                continue;
            }

            // Parámetro de limite de países
            if (paramName == "limitepaises" || paramName == "limitePaises")
            {
                if (filtros != null && filtros.TryGetValue("limitePaises", out var limitePaisesStr) && int.TryParse(limitePaisesStr, out var limitePaises))
                    args.Add(limitePaises);
                else
                    args.Add(20);
                continue;
            }

            // Parámetro de número de países (nuevo filtro del informe Paises)
            if (paramName == "numeropaises" || paramName == "numeroPaises")
            {
                if (filtros != null && filtros.TryGetValue("numeroPaises", out var numeroPaisesStr) && int.TryParse(numeroPaisesStr, out var numeroPaises))
                    args.Add(numeroPaises);
                else
                    args.Add(0); // Por defecto: 0 (todos)
                continue;
            }

            // Parámetro informe (variante del informe, ej: "cartera_contratacion_detalle")
            if (paramName == "informe")
            {
                if (filtros != null && filtros.TryGetValue("informe", out var informe))
                    args.Add(informe);
                else
                    args.Add(tipoInforme);
                continue;
            }

            // Parámetro todoInt (1 = Todo/Internacional, 0 = Nacional)
            // Se deriva del filtro 'mercado': "Todo" o "Internacional" → 1, resto → 0
            if (paramName == "todoint")
            {
                if (filtros != null && filtros.TryGetValue("mercado", out var mercadoVal)
                    && (mercadoVal.Equals("Todo", StringComparison.OrdinalIgnoreCase)
                        || mercadoVal.Equals("Internacional", StringComparison.OrdinalIgnoreCase)))
                    args.Add(1);
                else
                    args.Add(0);
                continue;
            }

            // Parámetros de umbrales dinámicos (umbral1-4) para informe Contrataciones
            if (paramName == "umbral1" || paramName == "umbral2" || paramName == "umbral3" || paramName == "umbral4")
            {
                if (filtros != null && filtros.TryGetValue(paramName, out var umbralStr) && decimal.TryParse(umbralStr, out var umbralVal))
                    args.Add(umbralVal);
                else
                    args.Add(ResolveDefaultValue(param));
                continue;
            }

            // Parámetro: contratacionAnioAnteriorEspana (paises_all)
            // El atributo del botón es 'data-contratacionanioanteriorespania' (con 'i' final),
            // por lo que se inyecta como query param tal cual. Aceptamos ambas variantes del paramName
            // (con/sin 'i' final) para máxima robustez.
            if (paramName == "contratacionanioanteriorespana" || paramName == "contratacionanioanteriorespania")
            {
                if (filtros != null
                    && (filtros.TryGetValue("contratacionanioanteriorespania", out var caeStr1)
                        || filtros.TryGetValue("contratacionAnioAnteriorEspana", out caeStr1))
                    && decimal.TryParse(caeStr1, out var caeVal))
                {
                    args.Add(caeVal);
                }
                else
                {
                    args.Add(1950280m);
                }
                continue;
            }

            // Para cualquier otro parámetro, usar el valor por defecto del método si existe
            args.Add(ResolveDefaultValue(param));
        }

        return args;
    }

    /// <summary>
    /// Resuelve el valor por defecto para un parámetro, respetando el default de C# si existe
    /// (necesario para reflection, que no aplica valores por defecto automáticamente).
    /// </summary>
    private static object? ResolveDefaultValue(ParameterInfo param)
    {
        if (param.HasDefaultValue)
            return param.DefaultValue;
        return GetDefaultValue(param.ParameterType);
    }

    /// <summary>
    /// Devuelve el valor por defecto para un tipo dado.
    /// </summary>
    private static object? GetDefaultValue(Type t)
    {
        if (t.IsValueType)
            return Activator.CreateInstance(t);
        return null;
    }
}
