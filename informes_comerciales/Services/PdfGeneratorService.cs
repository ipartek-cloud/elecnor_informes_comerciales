using PuppeteerSharp;
using PuppeteerSharp.Media;

namespace Elecnor_Informes_Comerciales.Services;

/// <summary>
/// Servicio que utiliza PuppeteerSharp para compilar HTML a PDF.
/// Mantiene una instancia singleton del browser Chromium para evitar el coste
/// de lanzamiento en cada petición (2-5s + ~150MB RAM por arranque).
/// Cada petición abre una nueva pestaña (IPage), genera el PDF y cierra la pestaña.
/// </summary>
public class PdfGeneratorService : IPdfGeneratorService, IAsyncDisposable
{
    private readonly ILogger<PdfGeneratorService> _logger;
    private readonly SemaphoreSlim _initSemaphore = new(1, 1);
    private IBrowser? _browser;
    private readonly string _chromiumDownloadPath;
    private readonly string _chromiumRevision;

    private string? ResolveChromeExecutable()
    {
        // BrowserFetcher descarga dentro de un subdirectorio "Chrome"
        var exePath = Path.Combine(_chromiumDownloadPath, "Chrome", _chromiumRevision, "chrome-win64", "chrome.exe");
        if (File.Exists(exePath)) return exePath;

        // Fallback: instalación manual sin subdirectorio "Chrome"
        exePath = Path.Combine(_chromiumDownloadPath, _chromiumRevision, "chrome-win64", "chrome.exe");
        return File.Exists(exePath) ? exePath : null;
    }

    private LaunchOptions BuildLaunchOptions()
    {
        var options = new LaunchOptions
        {
            Headless = true,
            Args = new[] { "--no-sandbox", "--disable-setuid-sandbox" }
        };
        var chromeExe = ResolveChromeExecutable();
        if (chromeExe is not null)
            options.ExecutablePath = chromeExe;
        return options;
    }

    public PdfGeneratorService(ILogger<PdfGeneratorService> logger, IConfiguration configuration)
    {
        _logger = logger;
        var chromiumSection = configuration.GetSection("Chromium");
        _chromiumDownloadPath = chromiumSection["DownloadPath"]
            ?? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "puppeteer_chromium");
        _chromiumRevision = chromiumSection["Revision"] ?? "Win64-119.0.6045.105";
    }

    /// <summary>
    /// Garantiza que el browser está disponible. Si no existe o ha muerto, lo lanza.
    /// Usa double-checked locking para seguridad en concurrencia.
    /// </summary>
    private async Task<IBrowser> GetBrowserAsync()
    {
        if (_browser is { IsConnected: true })
            return _browser;

        await _initSemaphore.WaitAsync();
        try
        {
            // Segunda comprobación dentro del semáforo
            if (_browser is { IsConnected: true })
                return _browser;

            // Cerrar instancia anterior si existe pero no está conectada
            if (_browser is not null)
            {
                _logger.LogWarning("El browser Chromium no está conectado. Relanzando...");
                try { await _browser.DisposeAsync(); } catch { /* ignorar */ }
                _browser = null;
            }

            // Verificar si chrome.exe ya está descargado localmente
            var launchOptions = BuildLaunchOptions();
            if (launchOptions.ExecutablePath is null)
            {
                _logger.LogInformation("Descargando Chromium...");
                var browserFetcher = new BrowserFetcher(new BrowserFetcherOptions { Path = _chromiumDownloadPath });
                await browserFetcher.DownloadAsync();
            }

            _logger.LogDebug("Lanzando instancia singleton de Chromium...");
            _browser = await Puppeteer.LaunchAsync(launchOptions);
            _logger.LogDebug("Browser Chromium listo y conectado.");

            return _browser;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error crítico al inicializar el browser Puppeteer.");
            throw;
        }
        finally
        {
            _initSemaphore.Release();
        }
    }

    public async Task<byte[]> GeneratePdfFromHtmlAsync(string htmlContent, CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();

        var browser = await GetBrowserAsync();

        _logger.LogDebug("Abriendo nueva pestaña de Puppeteer para renderizar PDF...");
        await using var page = await browser.NewPageAsync();

        await page.SetContentAsync(htmlContent, new NavigationOptions
        {
            WaitUntil = new[] { WaitUntilNavigation.Networkidle0 }
        });

        await page.EmulateMediaTypeAsync(PuppeteerSharp.Media.MediaType.Print);

        var pdfOptions = new PdfOptions
        {
            Format = PaperFormat.A4,
            PrintBackground = true,
            MarginOptions = new MarginOptions
            {
                Top = "0px",
                Bottom = "0px",
                Left = "0px",
                Right = "0px"
            }
        };

        _logger.LogDebug("Generando bytes del PDF...");
        return await page.PdfDataAsync(pdfOptions);
    }

    /// <summary>
    /// Libera el browser al detener la aplicación (IAsyncDisposable).
    /// </summary>
    public async ValueTask DisposeAsync()
    {
        if (_browser is not null)
        {
            _logger.LogInformation("Cerrando instancia singleton de Chromium...");
            try { await _browser.DisposeAsync(); } catch { /* ignorar */ }
            _browser = null;
        }
        _initSemaphore.Dispose();
    }
}
