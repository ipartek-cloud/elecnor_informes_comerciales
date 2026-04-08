namespace Elecnor_Informes_Comerciales.Models.Informes.ContratacionesSignificativas;

/// <summary>
/// POCO para el subinforme de detalle mensual de Contrataciones Significativas.
/// </summary>
public class ContratacionesSignificativasMesPoco
{
    public int Orden { get; set; }
    public string NombreDirNegocio { get; set; } = string.Empty;

    /// <summary>Nombre del cliente (sin comillas simples).</summary>
    public string NombreCliente_OK { get; set; } = string.Empty;

    /// <summary>Descripción de la oferta (sin comillas simples).</summary>
    public string DescripcionOferta_OK { get; set; } = string.Empty;

    /// <summary>Importe en miles de euros (procedente de rptPrincipalesContratacion).</summary>
    public decimal ImporteContratado { get; set; }
}
