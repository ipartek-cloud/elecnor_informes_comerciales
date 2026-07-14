namespace Elecnor_Informes_Comerciales.Models.Informes.GerenciasTotalesCruces;

/// <summary>
/// POCO que mapea el ResultSet del SELECT final del Repository.
/// Tipos verificados contra BD/RP_SIC/dbo/.
/// </summary>
public class GerenciasTotalesCrucesPoco
{
    public int Año { get; set; }
    public string? Orden { get; set; }
    public string? NombreGerente { get; set; }
    public string? CodDDirNegocio { get; set; }
    public string? NombreDirNegocio { get; set; }
    public string? CodCentro { get; set; }
    public string? NombreCentro { get; set; }
    public string? Mercado { get; set; }
    public int? OrdenCodDDirNegocio { get; set; }
    public decimal ImporteContratado { get; set; }
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
    public decimal Objetivos { get; set; }
    public decimal CarteraPdteAñoActual { get; set; }
    public decimal CarteraPdteAñoAnterior { get; set; }
}
