using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionDetalle;

/// <summary>
/// DTO raíz del informe Cartera Contratación (Detalle).
/// </summary>
public class CarteraContratacionDetalleResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<CarteraContratacionDetalleAgrupadoDto> Agrupaciones { get; set; } = new();
    public CarteraContratacionTotalesDto Totales { get; set; } = new();
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
}

/// <summary>
/// Agrupación por año de ejercicio.
/// </summary>
public class CarteraContratacionDetalleAgrupadoDto
{
    public int AnioInforme { get; set; }
    public List<CarteraContratacionDetalleItemDto> Detalles { get; set; } = new();
    public decimal TotalCarteraGrupo => Detalles.Sum(d => d.ImporteCarteraOferta);
    public decimal TotalContratadoGrupo => Detalles.Sum(d => d.ImporteContratadoOferta);
    public decimal TotalSumaGrupo => Detalles.Sum(d => d.Total);
}

/// <summary>
/// Línea de detalle del informe.
/// </summary>
public class CarteraContratacionDetalleItemDto
{
    public string? DesOferta { get; set; }
    public string? NomCliente { get; set; }
    public decimal ImporteCarteraOferta { get; set; }
    public decimal ImporteContratadoOferta { get; set; }
    public decimal Total => ImporteCarteraOferta + ImporteContratadoOferta;
}

/// <summary>
/// Totales globales del informe.
/// </summary>
public class CarteraContratacionTotalesDto
{
    public decimal SumaCartera { get; set; }
    public decimal SumaTotal { get; set; }
    /// <summary>
    /// Equivalente a txtTotalImporte de Access. Calculado sobre CarterasContratacionSQL,
    /// no sobre el recordset filtrado.
    /// </summary>
    public decimal? TotalCarteraGeneral { get; set; }
}
