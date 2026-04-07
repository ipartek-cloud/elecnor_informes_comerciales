namespace Elecnor_Informes_Comerciales.DTOs.Informes.Contrataciones;
using Elecnor_Informes_Comerciales.Models.Informes.Contrataciones;

/// <summary>
/// DTO contenedor para todos los subinformes de Contrataciones.
/// Diseñado para ser escalable (fácil añadir nuevos subinformes).
/// </summary>
public class SubInformesContratacionesDto
{
    /// <summary>
    /// SubInforme 1: Contrataciones Año Nacional Anterior (meses anteriores al seleccionado).
    /// Umbral: 1.500€
    /// </summary>
    public List<ContratacionesAnnoNacionalAnteriorPoco> AnnoNacionalAnterior { get; set; } = new();

    /// <summary>
    /// SubInforme 2: Mercado Internacional del Mes Seleccionado.
    /// </summary>
    public List<ContratacionesAnnoInternacionalMesPoco> AnnoInternacionalMes { get; set; } = new();

    /// <summary>
    /// SubInforme 3: Mercado Internacional de Meses Anteriores al Seleccionado.
    /// </summary>
    public List<ContratacionesAnnoInternacionalAnteriorPoco> AnnoInternacionalAnterior { get; set; } = new();
}
