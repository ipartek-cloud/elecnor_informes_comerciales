using PdfSharp.Drawing;
using PdfSharp.Fonts;
using PdfSharp.Pdf;
using PdfSharp.Pdf.IO;

namespace Elecnor_Informes_Comerciales.Services;

/// <summary>
/// Servicio de post-proceso para pintar números de página consecutivos
/// sobre un PDF ya generado por Puppeteer.
/// 
/// ESTRATEGIA: El PDF llega SIN número de página visible (fue eliminado del HTML
/// antes de renderizar en Puppeteer). Este servicio simplemente pinta el número
/// correcto (nroPaginaBase + índicePágina) en la posición configurada para cada informe.
/// 
/// COORDENADAS: Cada informe tiene coordenadas calibradas manualmente (Estrategia C).
/// Las coordenadas se expresan en puntos PDF (1 pt = 1/72 pulgada).
/// Una página A4 mide 595.27 × 841.89 pt.
/// </summary>
public class PdfPageNumberService
{
    private readonly ILogger<PdfPageNumberService> _logger;

    public PdfPageNumberService(ILogger<PdfPageNumberService> logger)
    {
        _logger = logger;
        try
        {
            if (GlobalFontSettings.FontResolver == null)
            {
                GlobalFontSettings.FontResolver = new SimpleFontResolver();
                //_logger.LogInformation("[PdfPageNumber] SimpleFontResolver registrado con éxito.");
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "[PdfPageNumber] Advertencia al configurar GlobalFontSettings.FontResolver (tal vez ya asignado).");
        }
    }

    // =========================================================================
    // CONFIGURACIONES DE COORDENADAS POR INFORME
    // =========================================================================
    // Cada entrada define la posición (X, Y) donde pintar el número de página.
    // X: Distancia horizontal desde el borde IZQUIERDO de la página (en puntos).
    // Y: Distancia vertical desde el borde SUPERIOR de la página (en puntos).
    //
    // NOTA: En PDFsharp, Y=0 es el borde SUPERIOR (no el inferior como en matemáticas).
    //
    // Proceso de calibración:
    //   1. Generar un PDF con coordenadas estimadas
    //   2. Abrir el PDF y verificar visualmente
    //   3. Ajustar X e Y hasta que el número quede alineado con el logo
    //   4. Actualizar el diccionario con los valores finales
    // =========================================================================

    private static readonly Dictionary<string, PageNumberConfig> _configs = new(StringComparer.OrdinalIgnoreCase)
    {
        // Contrataciones Significativas
        ["contrataciones_significativas"] = new PageNumberConfig
        {
            X = 550,        // Extremo derecho de alineación (borde derecho de la tabla)
            YFirstPage = 24,  // Página 1: padding-top 8mm + offset del número
            YOtherPages = 24, // Páginas 2+: misma separación vertical que la primera página
            FontSize = 10,
            FontName = "Helvetica"
        },
        // Cartera Contratación (Detalle)
        ["cartera_contratacion_detalle"] = new PageNumberConfig
        {
            X = 550,
            YFirstPage = 24,
            YOtherPages = 24,
            FontSize = 10,
            FontName = "Helvetica"
        },
        // Cartera Contratación (Resumen)
        ["cartera_contratacion_resumen_sdg"] = new PageNumberConfig
        {
            X = 550,
            YFirstPage = 24,
            YOtherPages = 24,
            FontSize = 10,
            FontName = "Helvetica"
        },
        // Cartera Contratación (Detalle Org. Países)
        ["cartera_contratacion_detalle_org_paises"] = new PageNumberConfig
        {
            X = 550,
            YFirstPage = 24,
            YOtherPages = 24,
            FontSize = 10,
            FontName = "Helvetica"
        },
        // Cartera Contratación (Detalle Países)
        ["cartera_contratacion_detalle_paises"] = new PageNumberConfig
        {
            X = 550,
            YFirstPage = 24,
            YOtherPages = 24,
            FontSize = 10,
            FontName = "Helvetica"
        }
    };

    // Configuración por defecto para informes sin configuración específica (alineación derecha en 550)
    private static readonly PageNumberConfig _defaultConfig = new()
    {
        X = 550,
        YFirstPage = 24,
        YOtherPages = 24,
        FontSize = 10,
        FontName = "Helvetica"
    };

    /// <summary>
    /// Aplica numeración consecutiva sobre un PDF ya generado.
    /// Para cada página física del PDF, pinta el número: nroPaginaBase + índice.
    /// </summary>
    /// <param name="pdfBytes">PDF original (sin números de página).</param>
    /// <param name="nroPaginaBase">Número de la primera página (ej: 9).</param>
    /// <param name="reportName">Nombre del informe para buscar configuración de coordenadas.</param>
    /// <returns>PDF modificado con números de página pintados.</returns>
    public byte[] AplicarNumeracion(byte[] pdfBytes, int nroPaginaBase, string? reportName)
    {
        try
        {
            // Obtener configuración de coordenadas para este informe
            var config = _defaultConfig;
            if (!string.IsNullOrWhiteSpace(reportName) && _configs.TryGetValue(reportName, out var specificConfig))
            {
                config = specificConfig;
            }

            //_logger.LogInformation("[PdfPageNumber] Aplicando numeración consecutiva. Base={Base}, Informe={Report}, Páginas a procesar...", nroPaginaBase, reportName ?? "default");

            using var inputStream = new MemoryStream(pdfBytes);
            var document = PdfReader.Open(inputStream, PdfDocumentOpenMode.Modify);
            int totalPages = document.PageCount;

            //_logger.LogInformation("[PdfPageNumber] PDF abierto: {PageCount} páginas.", totalPages);

            // Color azul corporativo Elecnor: #00468B → RGB(0, 70, 139)
            var brushBlue = new XSolidBrush(XColor.FromArgb(0, 70, 139));

            for (int i = 0; i < totalPages; i++)
            {
                var page = document.Pages[i];
                int numeroReal = nroPaginaBase + i;
                string textoNumero = numeroReal.ToString();

                // Determinar Y según si es primera página o siguientes
                double posY = (i == 0) ? config.YFirstPage : config.YOtherPages;
                double posX = config.X;

                using var gfx = XGraphics.FromPdfPage(page);

                // Crear fuente (PDFsharp 6 usa XFontStyleEx)
                var font = new XFont(config.FontName, config.FontSize, XFontStyleEx.Regular);

                // Medir el texto para alinear a la derecha de la coordenada X
                var size = gfx.MeasureString(textoNumero, font);
                double posXReal = posX - size.Width;

                // Dibujar el número de página
                gfx.DrawString(textoNumero, font, brushBlue, new XPoint(posXReal, posY));

                _logger.LogDebug("[PdfPageNumber] Página {Index}: número {Numero} pintado en ({X}, {Y}) (posX original: {OrigX})", i + 1, numeroReal, posXReal, posY, posX);
            }

            using var outputStream = new MemoryStream();
            document.Save(outputStream);
            var result = outputStream.ToArray();

            //_logger.LogInformation("[PdfPageNumber] Post-proceso completado. {PageCount} páginas numeradas.", totalPages);
            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[PdfPageNumber] Error en post-proceso. Devolviendo PDF original sin números.");
            return pdfBytes; // Fallback: devolver PDF sin modificar
        }
    }

    /// <summary>
    /// Configuración de coordenadas de número de página para un informe.
    /// </summary>
    private class PageNumberConfig
    {
        /// <summary>Posición X (horizontal desde borde izquierdo) en puntos PDF.</summary>
        public double X { get; init; }

        /// <summary>Posición Y para la primera página del PDF.</summary>
        public double YFirstPage { get; init; }

        /// <summary>Posición Y para las páginas 2+ (incluye offset de thead::before).</summary>
        public double YOtherPages { get; init; }

        /// <summary>Tamaño de fuente en puntos.</summary>
        public double FontSize { get; init; } = 10;

        /// <summary>Nombre de la fuente.</summary>
        public string FontName { get; init; } = "Helvetica";
    }

    /// <summary>
    /// Resolvedor de fuentes básico para PDFsharp 6.x en Windows.
    /// Resuelve Helvetica y Verdana cargando las fuentes TrueType de Windows.
    /// </summary>
    private class SimpleFontResolver : IFontResolver
    {
        public byte[] GetFont(string faceName)
        {
            string fontPath = faceName.ToLower() switch
            {
                "helvetica-bold" => @"C:\Windows\Fonts\arialbd.ttf",
                "helvetica" => @"C:\Windows\Fonts\arial.ttf",
                "verdana-bold" => @"C:\Windows\Fonts\verdanab.ttf",
                "verdana" => @"C:\Windows\Fonts\verdana.ttf",
                _ => @"C:\Windows\Fonts\arial.ttf"
            };

            // Intentar cargar desde la ruta específica
            if (File.Exists(fontPath))
            {
                return File.ReadAllBytes(fontPath);
            }

            // Fallback: buscar la carpeta de fuentes a través del System de Windows
            var systemFonts = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "..", "Fonts");
            var alternativePath = Path.Combine(systemFonts, Path.GetFileName(fontPath));
            if (File.Exists(alternativePath))
            {
                return File.ReadAllBytes(alternativePath);
            }

            // Si falla y hay algún archivo ttf en la carpeta, cargarlo como fallback de emergencia
            if (Directory.Exists(systemFonts))
            {
                var fallbackFile = Directory.GetFiles(systemFonts, "*.ttf").FirstOrDefault();
                if (fallbackFile != null)
                {
                    return File.ReadAllBytes(fallbackFile);
                }
            }

            throw new InvalidOperationException($"No se pudo resolver la fuente {faceName} en la ruta {fontPath}.");
        }

        public FontResolverInfo ResolveTypeface(string familyName, bool isBold, bool isItalic)
        {
            string name = familyName.ToLower();
            if (name.Contains("helvetica") || name.Contains("arial"))
            {
                if (isBold) return new FontResolverInfo("Helvetica-Bold");
                return new FontResolverInfo("Helvetica");
            }
            if (name.Contains("verdana"))
            {
                if (isBold) return new FontResolverInfo("Verdana-Bold");
                return new FontResolverInfo("Verdana");
            }
            return new FontResolverInfo("Helvetica");
        }
    }
}
