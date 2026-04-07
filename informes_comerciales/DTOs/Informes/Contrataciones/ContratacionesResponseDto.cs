namespace Elecnor_Informes_Comerciales.DTOs.Informes.Contrataciones;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

/// <summary>
/// DTO raíz para la respuesta unificada del informe Contrataciones.
/// Contiene el informe principal + todos los subinformes.
/// </summary>
public class ContratacionesResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    
    /// <summary>
    /// Informe Principal: Contrataciones del mes seleccionado.
    /// Umbral: 300.000€
    /// </summary>
    public ContratacionesDto InformePrincipal { get; set; } = new();
    
    /// <summary>
    /// Todos los subinformes asociados.
    /// </summary>
    public SubInformesContratacionesDto SubInformes { get; set; } = new();
}
