using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.ActividadesObjetivos;

public class ActividadesObjetivosResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<PaisActividadesObjetivosDto> Paises { get; set; } = new();
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
}

public class PaisActividadesObjetivosDto
{
    public string NombrePais { get; set; } = string.Empty;
    public List<ActividadObjetivoDetalleDto> Detalle { get; set; } = new();
    public TotalesActividadObjetivoDto Totales { get; set; } = new();
}

public class ActividadObjetivoDetalleDto
{
    public string Actividad { get; set; } = string.Empty;
    public decimal ImporteActual { get; set; }
    public decimal ImporteAnterior { get; set; }
    public decimal ImporteObjetivos { get; set; }
    public decimal Ip { get; set; }
    public string VariacionPorcentaje { get; set; } = string.Empty;
    public decimal PorcentajeActualMercado { get; set; }
    public decimal PorcentajeAnteriorMercado { get; set; }
    public decimal PorcentajeCumplimiento { get; set; }
    public int Orden { get; set; }
}

public class TotalesActividadObjetivoDto
{
    public decimal ImporteActual { get; set; }
    public decimal ImporteAnterior { get; set; }
    public decimal ImporteObjetivos { get; set; }
    public decimal Ip { get; set; }
    public string VariacionPorcentaje { get; set; } = string.Empty;
    public int PorcentajeTotal { get; set; } = 100;
    public decimal PorcentajeCumplimiento { get; set; }
}
