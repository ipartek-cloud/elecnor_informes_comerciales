namespace Elecnor_Informes_Comerciales.Models.Informes.ContratacionesAI;

/// <summary>
/// POCO para mapeo SQL del informe ContratacionesAI (Asociadas a Inversión).
/// Origen: rptPrincipalesObrasAI
/// </summary>
public class ContratacionesAIPoco
{
    public int Año { get; set; }
    public string Paises { get; set; } = string.Empty;
    public string Meses { get; set; } = string.Empty;
    public string DescripcionOfertas_OK { get; set; } = string.Empty;
    public string NombreClientes_OK { get; set; } = string.Empty;
    public decimal ImporteContratado_OK { get; set; }
}
