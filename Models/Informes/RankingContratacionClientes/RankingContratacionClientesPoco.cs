namespace Elecnor_Informes_Comerciales.Models.Informes.RankingContratacionClientes;

/// <summary>
/// POCO para el informe Ranking de Contratación por Clientes.
/// Mapeo directo desde rptContratacion_Clientes y lógica de histórico.
/// </summary>
public class RankingContratacionClientesPoco
{
    public int Año { get; set; }
    public int Row { get; set; }
    public string Mercado { get; set; } = string.Empty;
    public string Pais { get; set; } = string.Empty;
    public string AI { get; set; } = string.Empty;
    public string Cliente { get; set; } = string.Empty;
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumulado_AñoAnterior { get; set; }
    public int VerAñoAnterior { get; set; } // 1: Sí, 0: No
}
