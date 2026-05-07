using System.Text.Json.Serialization;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionDetallePaises;

public class CarteraContratacionDetallePaisesResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<CarteraContratacionDetallePaisesAgrupadoDto> Agrupaciones { get; set; } = new();
    public CarteraContratacionDetallePaisesTotalesDto Totales { get; set; } = new();
}

public class CarteraContratacionDetallePaisesAgrupadoDto
{
    public int AnioInforme { get; set; }
    public List<CarteraContratacionDetallePaisesPaisDto> Paises { get; set; } = new();
}

public class CarteraContratacionDetallePaisesPaisDto
{
    public string? NombrePais { get; set; }
    public decimal? ImporteCarteraPais { get; set; }

    [JsonPropertyName("importeCarteraPaisAnterior")]
    public decimal? ImporteCarteraPaisAñoAnterior { get; set; }

    public List<CarteraContratacionDetallePaisesDetalleDto> Detalles { get; set; } = new();
}

public class CarteraContratacionDetallePaisesDetalleDto
{
    public string? NomCliente { get; set; }
    public string? DesOferta { get; set; }
    public decimal? ImporteCarteraOferta { get; set; }
    public decimal? ImporteContratadoOferta { get; set; }

    [JsonPropertyName("importeCarteraOfertaAnterior")]
    public decimal? ImporteCarteraOfertaAñoAnterior { get; set; }

    public decimal ImporteTotalOferta { get; set; }
}

public class CarteraContratacionDetallePaisesTotalesDto
{
    public decimal SumaCarteraPais { get; set; }

    [JsonPropertyName("sumaCarteraPaisAnterior")]
    public decimal? SumaCarteraPaisAñoAnterior { get; set; }

    public decimal? TotalCarteraGeneral { get; set; }
}
