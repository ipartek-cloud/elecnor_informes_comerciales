namespace Elecnor_Informes_Comerciales.Models.Informes.Contrataciones;

/// <summary>
/// POCO para mapeo SQL del subinforme Contrataciones Año Internacional Mes.
/// </summary>
public class ContratacionesAnnoInternacionalMesPoco
{
    public string Meses { get; set; } = string.Empty;
    public string NombreClientes_OK { get; set; } = string.Empty;
    public string DescripcionOfertas_OK { get; set; } = string.Empty;
    public string NombreDirNegocio_OK { get; set; } = string.Empty;
    public decimal ImporteContratado_OK { get; set; }
    public string AI { get; set; } = string.Empty;
}
