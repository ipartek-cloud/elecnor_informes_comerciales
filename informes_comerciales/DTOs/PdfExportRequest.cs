using System.ComponentModel.DataAnnotations;

namespace Elecnor_Informes_Comerciales.DTOs;

/// <summary>
/// DTO para recibir el contenido HTML del informe y el nombre de archivo sugerido para exportar a PDF.
/// </summary>
public class PdfExportRequest
{
    /// <summary>
    /// Contenido HTML del informe a ser renderizado por Puppeteer.
    /// </summary>
    [Required]
    public string HtmlContent { get; set; } = string.Empty;

    /// <summary>
    /// Nombre de archivo con el que se guardará el PDF (ej: 1.pdf).
    /// </summary>
    [Required]
    public string FileName { get; set; } = string.Empty;

    /// <summary>
    /// Nombre clave del informe (ej: mercados, actividades) para cargar su CSS específico.
    /// </summary>
    public string? ReportName { get; set; }

    /// <summary>
    /// Número de página base para numeración consecutiva en PDF.
    /// Si tiene valor, se aplica post-proceso: se eliminan los spans .rpt-page-number
    /// del HTML y se pintan los números consecutivos (base + índice) en cada página del PDF.
    /// Si es null, el PDF se genera sin modificaciones (comportamiento actual).
    /// </summary>
    public int? NroPagina { get; set; }
}
