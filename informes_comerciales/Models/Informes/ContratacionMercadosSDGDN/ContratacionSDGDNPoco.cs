namespace Elecnor_Informes_Comerciales.Models.Informes.ContratacionMercadosSDGDN;

/// <summary>POCO plano devuelto por el Repository (granularidad fina: SDG + DN + Area + Delegacion + Pais).
/// El Service se encarga de agrupar para construir el DTO jerarquico.</summary>
public class ContratacionSDGDNPoco
{
    public string? CodSubDirGeneral { get; set; }
    public string? NombreSubDirGeneral { get; set; }
    public string? CodDDirNegocio { get; set; }
    public string? NombreDirNegocio { get; set; }
    public string? CodSubDirNegocioArea { get; set; }
    public string? NombreSubDirNegocioArea { get; set; }
    public string? CodDelegacion { get; set; }
    public string? NombreDelegacion { get; set; }
    public string? Pais { get; set; }

    public decimal ImporteContratado { get; set; }
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAnterior { get; set; }
    public decimal Objetivo { get; set; }
    public int Orden_CodDDirNegocio { get; set; }
}
