namespace Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionResumenSDG;

/// <summary>
/// POCO que mapea el resultado del SP spCartera_Contratacion_Resumen_SDG.
/// El SP devuelve euros brutos; la división por 1000 se realiza en el frontend.
/// </summary>
public class CarteraContratacionResumenSDGPoco
{
    public int Año { get; set; }
    public int Mes { get; set; }
    public string CodSubDirGeneral { get; set; } = string.Empty;
    public string CodDDirNegocio { get; set; } = string.Empty;
    public string? NombreSubDirGeneral { get; set; }
    public string DN { get; set; } = string.Empty;
    public decimal? TotAño { get; set; }
    public decimal? TotAñoAnterior { get; set; }
}
