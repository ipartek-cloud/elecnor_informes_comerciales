namespace Elecnor_Informes_Comerciales.Models.Informes.ActividadesObjetivos;

public class ActividadObjetivoPoco
{
    public string Pais { get; set; } = string.Empty;
    public string Actividad { get; set; } = string.Empty;
    public int Orden { get; set; }
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
    public decimal ImporteContratadoAcumuladoLastYear { get; set; }
    public decimal ImporteObjetivos { get; set; }
}
