namespace Elecnor_Informes_Comerciales.DTOs.Informes.ContratacionesAI;

/// <summary>
/// Detalle individual de contratación AI para el frontend.
/// </summary>
public class ContratacionesAIDetalleDto
{
    public int Anio { get; set; }
    public string Mercado { get; set; } = string.Empty; // "I" o ""
    public string Mes { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public string Cliente { get; set; } = string.Empty;
    public decimal Importe { get; set; }
}
