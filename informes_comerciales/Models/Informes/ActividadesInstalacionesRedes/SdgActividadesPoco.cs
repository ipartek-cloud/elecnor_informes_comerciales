namespace Elecnor_Informes_Comerciales.Models.Informes.ActividadesInstalacionesRedes;

/// <summary>POCO plano de rptSDG_Actividades_SDG (Service agrupa por Actividad + Sub-actividad).</summary>
public class SdgActividadesPoco
{
    public int Año { get; set; }
    public string? Agrupacion { get; set; }
    public string? Mercado { get; set; }            // "N" | "I"
    public string? CodDirNegocio { get; set; }
    public string? NombreDirNegocio { get; set; }
    public int? Orden { get; set; }
    public decimal Contrat { get; set; }            // Contratacion año actual (EUR)
    public string? ACT1 { get; set; }
    public decimal Contrat_1 { get; set; }          // Contratacion año anterior (EUR)
    public decimal Objetivos { get; set; }          // Objetivo anual (EUR, sin dividir)
    public string? LoginUsuario { get; set; }
    public DateTime? FechaCreacion { get; set; }
}
