namespace Elecnor_Informes_Comerciales.Models.Informes.Gerencias;

/// <summary>
/// POCO que mapea el resultado directo de la consulta SQL del informe de Gerencias.
/// Cada instancia representa una gerencia/actividad con sus datos de contratación, objetivos y cartera.
/// </summary>
public class GerenciasPoco
{
    public int Año { get; set; }
    public int Orden { get; set; }
    public string SumarizaGerentes { get; set; } = string.Empty;
    public string Actividad { get; set; } = string.Empty;

    // Contratación (Euros Reales, sin dividir por 1000)
    public decimal ImporteContratado { get; set; }
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }

    // Objetivos (Euros Reales)
    public decimal Objetivos { get; set; }

    // Cartera Pendiente (Euros Reales)
    public decimal CarteraPdteAñoActual { get; set; }
    public decimal CarteraPdteAñoAnterior { get; set; }
}
