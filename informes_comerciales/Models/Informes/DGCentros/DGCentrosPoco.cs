namespace Elecnor_Informes_Comerciales.Models.Informes.DGCentros;

public class DGCentrosPoco
{
    public int OrdenSubDirGeneral { get; set; }
    public string CodSubDirGeneral { get; set; } = string.Empty;
    public string NombreSubDirGeneral { get; set; } = string.Empty;
    public int? Orden_CodDDirNegocio { get; set; }
    public string CodDDirNegocio { get; set; } = string.Empty;
    public string NomDirNegocio { get; set; } = string.Empty;
    public string CodDelegacion { get; set; } = string.Empty;
    public string NombreDelegacion { get; set; } = string.Empty;
    public string CodCentro { get; set; } = string.Empty;
    public string NombreCentro { get; set; } = string.Empty;
    public string Pais { get; set; } = string.Empty;
    public decimal ImporteContratado { get; set; }
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
    public decimal Objetivos { get; set; }
    public decimal CarteraPdteAñoActual { get; set; }
    public decimal CarteraPdteAñoAnterior { get; set; }
}
