namespace Elecnor_Informes_Comerciales.Models.Informes.ActividadesInternacionalDetalle;

public class ActividadesInternacionalDetallePoco
{
    public int Año { get; set; }
    public string? Pais { get; set; }
    public string? ActividadPrincipal { get; set; }
    public string? ActividadDetalle { get; set; }
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
    public int Orden { get; set; }
    public decimal ImporteObjetivos { get; set; }
    public int EsSubActividad { get; set; }
}
