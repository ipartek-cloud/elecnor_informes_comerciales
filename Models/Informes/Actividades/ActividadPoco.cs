namespace Elecnor_Informes_Comerciales.Models.Informes.Actividades;

public class ActividadPoco
{
    public int? Año { get; set; }
    public string Pais { get; set; } = string.Empty;
    public string Actividad { get; set; } = string.Empty;
    public decimal ImporteContratadoAcumulados { get; set; }
    public decimal ImporteContratadoAcumuladosAñoAnterior { get; set; }
    public decimal ImporteContratadoAcumuladosLY { get; set; }
    public int Orden { get; set; }
}
