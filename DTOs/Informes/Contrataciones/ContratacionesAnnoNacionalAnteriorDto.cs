namespace Elecnor_Informes_Comerciales.DTOs.Informes.Contrataciones;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.Contrataciones;

/// <summary>
/// DTO raíz para el subinforme Contrataciones Año Nacional Anterior.
/// Contiene los contratos acumulados de meses ANTERIORES al seleccionado (excluye mes actual).
/// Umbral: 1.500€
/// </summary>
public class ContratacionesAnnoNacionalAnteriorDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<ContratacionesAnnoNacionalAnteriorPoco> Datos { get; set; } = new();
}
