namespace Elecnor_Informes_Comerciales.Models.Informes.ContratacionesSignificativas;

public class ContratacionesSignificativasPoco
{
    public int Orden { get; set; }
    public string NombreDirNegocio { get; set; } = string.Empty;
    public decimal ImporteContratado { get; set; }
}
