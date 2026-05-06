using System.Text.Json.Serialization;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionDetalleOrgPaises;

/// <summary>
/// DTO raíz del informe Cartera Contratación DG (Detalle) Organización Países.
/// </summary>
public class CarteraContratacionDetalleOrgPaisesResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<CarteraContratacionDetalleOrgPaisesAgrupadoDto> Agrupaciones { get; set; } = new();
    public CarteraContratacionDetalleOrgPaisesTotalesDto Totales { get; set; } = new();
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
}

/// <summary>
/// Agrupación por año de ejercicio.
/// </summary>
public class CarteraContratacionDetalleOrgPaisesAgrupadoDto
{
    public int AnioInforme { get; set; }
    public List<CarteraContratacionDetalleOrgPaisesDNDto> DireccionesNegocio { get; set; } = new();
}

/// <summary>
/// Dirección de Negocio (DN) con sus países.
/// </summary>
public class CarteraContratacionDetalleOrgPaisesDNDto
{
    public string? NombreDirNegocio { get; set; }
    public string? CodDDirNegocio { get; set; }
    public decimal? ImporteCarteraDN { get; set; }
    [JsonPropertyName("importeCarteraDNAnterior")]
    public decimal? ImporteCarteraDNAñoAnterior { get; set; }
    public List<CarteraContratacionDetalleOrgPaisesPaisDto> Paises { get; set; } = new();
}

/// <summary>
/// País con su detalle de ofertas.
/// </summary>
public class CarteraContratacionDetalleOrgPaisesPaisDto
{
    public string? NombrePais { get; set; }
    public decimal? ImporteCarteraPais { get; set; }
    [JsonPropertyName("importeCarteraPaisAnterior")]
    public decimal? ImporteCarteraPaisAñoAnterior { get; set; }
    public List<CarteraContratacionDetalleOrgPaisesDetalleDto> Detalles { get; set; } = new();
}

/// <summary>
/// Línea de detalle del informe.
/// </summary>
public class CarteraContratacionDetalleOrgPaisesDetalleDto
{
    public string? NomCliente { get; set; }
    public string? DesOferta { get; set; }
    public decimal? ImporteCarteraOferta { get; set; }
    public decimal? ImporteContratadoOferta { get; set; }
    [JsonPropertyName("importeCarteraOfertaAnterior")]
    public decimal? ImporteCarteraOfertaAñoAnterior { get; set; }
    public decimal ImporteTotalOferta => (ImporteCarteraOferta ?? 0) + (ImporteContratadoOferta ?? 0);
}

/// <summary>
/// Totales globales del informe.
/// </summary>
public class CarteraContratacionDetalleOrgPaisesTotalesDto
{
    public decimal SumaCarteraPais { get; set; }
    [JsonPropertyName("sumaCarteraPaisAnterior")]
    public decimal? SumaCarteraPaisAñoAnterior { get; set; }
    public decimal? TotalCarteraGeneral { get; set; }
}
