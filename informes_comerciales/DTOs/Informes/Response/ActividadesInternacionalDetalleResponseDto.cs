namespace Elecnor_Informes_Comerciales.DTOs.Informes.Response;

public class ActividadesInternacionalDetalleResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<ActividadPrincipalDto> Actividades { get; set; } = new();
    public TotalesDto Totales { get; set; } = new();
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
}

public class ActividadPrincipalDto
{
    public string Nombre { get; set; } = string.Empty;
    public int Orden { get; set; }
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
    public decimal ImporteObjetivos { get; set; }
    public decimal PorcentajeSobreMercado { get; set; }
    public decimal PorcentajeSobreMercadoAnterior { get; set; }
    public decimal IndiceProduccion { get; set; }
    public string VariacionPorcentaje { get; set; } = string.Empty;
    public List<SubActividadDto> SubActividades { get; set; } = new();
}

public class SubActividadDto
{
    public string Nombre { get; set; } = string.Empty;
    public int Orden { get; set; }
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
    public decimal PorcentajeSobreMercado { get; set; }
    public decimal PorcentajeSobreMercadoAnterior { get; set; }
}

public class TotalesDto
{
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
    public decimal ImporteObjetivos { get; set; }
    public decimal PorcentajeSobreMercado { get; set; }
    public decimal PorcentajeSobreMercadoAnterior { get; set; }
    public decimal IndiceProduccion { get; set; }
    public string VariacionPorcentaje { get; set; } = string.Empty;
}
