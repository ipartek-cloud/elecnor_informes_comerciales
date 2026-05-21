namespace Elecnor_Informes_Comerciales.Services;

/// <summary>
/// Interfaz para el servicio de generación de PDFs a partir de contenido HTML.
/// </summary>
public interface IPdfGeneratorService
{
    /// <summary>
    /// Genera un documento PDF en memoria (array de bytes) a partir del HTML proporcionado.
    /// </summary>
    /// <param name="htmlContent">El contenido HTML completo, incluyendo estilos inyectados.</param>
    /// <param name="cancellationToken">Token para cancelar la operación (timeout 60s).</param>
    /// <returns>El PDF en bytes.</returns>
    Task<byte[]> GeneratePdfFromHtmlAsync(string htmlContent, CancellationToken cancellationToken = default);
}
