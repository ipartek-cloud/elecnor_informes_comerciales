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

    /// <summary>
    /// Genera un documento PDF en memoria a partir de HTML y le aplica numeración de páginas consecutiva si se solicita.
    /// </summary>
    /// <param name="htmlContent">El contenido HTML completo, incluyendo estilos inyectados.</param>
    /// <param name="nroPagina">Número de página base para la numeración consecutiva. Si es null, no se realiza post-proceso.</param>
    /// <param name="reportName">Nombre clave del informe para determinar la configuración de coordenadas.</param>
    /// <param name="cancellationToken">Token de cancelación.</param>
    /// <returns>El PDF en bytes con la numeración aplicada si corresponde.</returns>
    Task<byte[]> GeneratePdfFromHtmlAsync(string htmlContent, int? nroPagina, string? reportName, CancellationToken cancellationToken = default);
}
