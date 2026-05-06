using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionResumenSDG;

/// <summary>
/// DTO raíz de respuesta del informe Cartera de Contratación (Resumen SDG).
/// </summary>
public class CarteraContratacionResumenSDGResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<CarteraContratacionResumenSDGItemDto> Datos { get; set; } = new();
    public CarteraContratacionResumenSDGTotalesDto Totales { get; set; } = new();
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
}

/// <summary>
/// Representa una SubDirección General con su detalle de Direcciones de Negocio.
/// </summary>
public class CarteraContratacionResumenSDGItemDto
{
    public string CodSubDirGeneral { get; set; } = string.Empty;
    public string? NombreSubDirGeneral { get; set; }

    /// <summary>Suma de TotAñoAnterior de todas las DN de esta SDG.</summary>
    public decimal TotalAñoAnterior { get; set; }

    /// <summary>Suma de TotAño de todas las DN de esta SDG.</summary>
    public decimal TotalAño { get; set; }

    /// <summary>Detalle por Dirección de Negocio.</summary>
    public List<CarteraContratacionResumenSDGDetalleDto> DetalleDN { get; set; } = new();
}

/// <summary>
/// Línea de detalle a nivel de Dirección de Negocio (equivalente al subinforme Access).
/// </summary>
public class CarteraContratacionResumenSDGDetalleDto
{
    public int Año { get; set; }
    public int Mes { get; set; }
    public string CodSubDirGeneral { get; set; } = string.Empty;
    public string CodDDirNegocio { get; set; } = string.Empty;
    public string? NombreSubDirGeneral { get; set; }
    public string DN { get; set; } = string.Empty;
    public decimal? TotAñoAnterior { get; set; }
    public decimal? TotAño { get; set; }
}

/// <summary>
/// Totales globales del informe (suma de todas las SDG).
/// </summary>
public class CarteraContratacionResumenSDGTotalesDto
{
    public decimal TotalGeneralAñoAnterior { get; set; }
    public decimal TotalGeneralAño { get; set; }
}
