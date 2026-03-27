namespace Elecnor_Informes_Comerciales.DTOs.Informes.RankingContratacionClientes;

/// <summary>
/// DTO para el detalle de desglose de clientes.
/// </summary>
public class RankingContratacionClientesDesgloseDto
{
    public int Anio { get; set; }
    public string Mercado { get; set; } = string.Empty;
    public string Pais { get; set; } = string.Empty;
    public string AI { get; set; } = string.Empty;
    public string Cliente { get; set; } = string.Empty;
    public string ClienteDesglose { get; set; } = string.Empty;
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAnterior { get; set; }

    /// <summary>
    /// Porcentaje de este sub-clien sobre el total del mercado.
    /// </summary>
    public decimal PorcentajeSobreTotal { get; set; }

    /// <summary>
    /// Variación porcentual entre periodo anterior y actual.
    /// Formatos: "-" (anterior=0), "+XX%" (crecimiento), "-XX%" (decrecimiento).
    /// Ejemplos: "+15%", "-8%", "+7569%", "-"
    /// </summary>
    public string Variacion { get; set; } = string.Empty;
}
