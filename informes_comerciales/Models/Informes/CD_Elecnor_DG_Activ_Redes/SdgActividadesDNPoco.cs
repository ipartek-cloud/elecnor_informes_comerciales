namespace Elecnor_Informes_Comerciales.Models.Informes.CD_Elecnor_DG_Activ_Redes;

/// <summary>POCO plano de rptSDG_Actividades_SDG filtrado por CodDirNegocio.</summary>
public class SdgActividadesDNPoco
{
    public int Año { get; set; }
    public string? Agrupacion { get; set; }
    public string? Mercado { get; set; }
    public string? CodDirNegocio { get; set; }
    public string? NombreDirNegocio { get; set; }
    public int? Orden { get; set; }
    public decimal Contrat { get; set; }
    public string? ACT1 { get; set; }
    public decimal Contrat_1 { get; set; }
    public decimal Objetivos { get; set; }
    public string? LoginUsuario { get; set; }
    public DateTime? FechaCreacion { get; set; }
}
