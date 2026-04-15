namespace Elecnor_Informes_Comerciales.Models.Informes.MercadosSGDelegaciones;

public class MercadoSGDelegacionPoco
{
    public int OrdenSubDirGeneral { get; set; }
    public string CodSubDirGeneral { get; set; } = string.Empty;
    public string NombreSubDirGeneral { get; set; } = string.Empty;
    public int? Orden_CodDDirNegocio { get; set; }
    public string CodDDirNegocio { get; set; } = string.Empty;
    public string NomDirNegocio { get; set; } = string.Empty;
    public string Area { get; set; } = string.Empty;
    public string CodDelegacion { get; set; } = string.Empty;
    public string NombreDelegacion { get; set; } = string.Empty;
    public decimal ImporteContratado { get; set; }
    public decimal ImporteContratadoNacional { get; set; }
    public decimal ImporteContratadoInternacional { get; set; }
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoNacional { get; set; }
    public decimal ImporteContratadoAcumuladoInternacional { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
    public decimal Objetivos { get; set; }
    public decimal ObjetivosNacional { get; set; }
    public decimal ObjetivosInternacional { get; set; }
    public decimal CarteraPdteAñoActual { get; set; }
    public decimal CarteraPdteAñoAnterior { get; set; }
}
