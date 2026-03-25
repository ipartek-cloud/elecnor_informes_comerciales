namespace Elecnor_Informes_Comerciales.Models.Informes.Contrataciones;

/// <summary>
/// POCO para mapeo SQL del informe Principales Contrataciones del Año.
/// </summary>
public class ContratacionesPoco
{
    public string NombreClientes_OK { get; set; } = string.Empty;
    public string DescripcionOfertas_OK { get; set; } = string.Empty;
    public decimal ImporteContratado_OK { get; set; }
}
