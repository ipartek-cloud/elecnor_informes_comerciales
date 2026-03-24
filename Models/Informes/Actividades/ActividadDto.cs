using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.Actividades;

public class ActividadesResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<PaisActividadesDto> Paises { get; set; } = new();
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
}

public class PaisActividadesDto
{
    public string NombrePais { get; set; } = string.Empty;
    public List<ActividadDetalleDto> Detalle { get; set; } = new();
    public TotalesActividadDto Totales { get; set; } = new();
}

public class ActividadDetalleDto
{
    public string Actividad { get; set; } = string.Empty;
    public decimal ImporteActual { get; set; }
    public decimal ImporteAnterior { get; set; }
    public decimal PorcentajeActualMercado { get; set; }
    public decimal PorcentajeAnteriorMercado { get; set; }
    public string VariacionPorcentaje { get; set; } = string.Empty;
    public int Orden { get; set; }
}

public class TotalesActividadDto
{
    public decimal ImporteActual { get; set; }
    public decimal ImporteAnterior { get; set; }
    public string VariacionPorcentaje { get; set; } = string.Empty;
    public int PorcentajeTotal { get; set; } = 100; // Siempre 100% de su propio mercado
}
