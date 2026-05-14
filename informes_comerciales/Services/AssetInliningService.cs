using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.FileProviders;

namespace Elecnor_Informes_Comerciales.Services;

/// <summary>
/// Servicio encargado de leer y cachear archivos estáticos del servidor.
/// Implementa cacheo inteligente con invalidación automática por cambio de archivo.
/// </summary>
public class AssetInliningService
{
    private readonly IWebHostEnvironment _env;
    private readonly IMemoryCache _cache;
    private readonly ILogger<AssetInliningService> _logger;
    private readonly PhysicalFileProvider _fileProvider;

    public AssetInliningService(
        IWebHostEnvironment env,
        IMemoryCache cache,
        ILogger<AssetInliningService> logger)
    {
        _env = env;
        _cache = cache;
        _logger = logger;

        // Inicializar el file provider con el WebRootPath para detectar cambios
        _fileProvider = new PhysicalFileProvider(_env.WebRootPath);
    }

    /// <summary>
    /// Obtiene el contenido de un asset estático (CSS, JS) del disco.
    /// Utiliza cacheo en memoria con invalidación por cambio de archivo.
    /// </summary>
    /// <param name="relativePath">Ruta relativa desde wwwroot (ej: "css/informes/mercados.css")</param>
    /// <returns>Contenido del archivo como string. String vacío si no existe.</returns>
    public async Task<string> GetAssetContentAsync(string relativePath)
    {
        if (string.IsNullOrWhiteSpace(relativePath))
            return string.Empty;

        // Normalizar separadores de ruta
        relativePath = relativePath.Replace('/', Path.DirectorySeparatorChar).Replace('\\', Path.DirectorySeparatorChar);

        var cacheKey = $"asset:{relativePath}";

        if (_cache.TryGetValue(cacheKey, out string? cachedContent))
        {
            return cachedContent ?? string.Empty;
        }

        var fullPath = Path.Combine(_env.WebRootPath, relativePath);

        if (!File.Exists(fullPath))
        {
            _logger.LogWarning("[AssetInlining] Asset no encontrado: {Path}", fullPath);
            return string.Empty;
        }

        try
        {
            var content = await File.ReadAllTextAsync(fullPath);

            // Cachear con invalidación por cambio de archivo (PollingFileChangeToken)
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .AddExpirationToken(_fileProvider.Watch(relativePath));

            _cache.Set(cacheKey, content, cacheEntryOptions);

            return content;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[AssetInlining] Error al leer asset: {Path}", fullPath);
            return string.Empty;
        }
    }
}
