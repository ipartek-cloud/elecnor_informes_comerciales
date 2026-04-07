namespace Elecnor_Informes_Comerciales.Models.Informes.RankingContratacionClientes;

/// <summary>
/// POCO para el detalle de desglose de clientes.
/// </summary>
public class RankingContratacionClientesDesglosePoco
{
    public string Pais { get; set; } = string.Empty;
    public string AI { get; set; } = string.Empty;
    public string Cliente { get; set; } = string.Empty;
    public string ClienteDesglose { get; set; } = string.Empty;
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
}
