namespace Elecnor_Informes_Comerciales.Models.Informes.Paises;

/// <summary>
/// POCO para mapeo de la consulta SQL del informe de Países.
/// </summary>
public class PaisesPoco
{
    public int Año { get; set; }
    public string Pais { get; set; } = string.Empty;
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
    public string SinContratacionAñoAnterior { get; set; } = string.Empty;
    public int OrdenAñoAnterior { get; set; }
    public int Ajuste { get; set; }
}
