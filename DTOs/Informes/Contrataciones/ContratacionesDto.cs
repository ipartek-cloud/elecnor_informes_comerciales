namespace Elecnor_Informes_Comerciales.DTOs.Informes.Contrataciones;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.Contrataciones;

/// <summary>
/// DTO raíz que devuelve el Service para el informe Principales Contrataciones del Año.
/// </summary>
public class ContratacionesDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<ContratacionesPoco> Datos { get; set; } = new();
    public TotalesEstandarDto TotalesGlobales { get; set; } = new();
}
