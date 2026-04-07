using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.DTOs.Informes.ContratacionesAI;

/// <summary>
/// DTO raíz para la respuesta del informe ContratacionesAI.
/// </summary>
public class ContratacionesAIResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    
    /// <summary>
    /// Lista de contrataciones AI correspondientes al mes seleccionado.
    /// </summary>
    public List<ContratacionesAIDetalleDto> Datos { get; set; } = new();

    /// <summary>
    /// Lista de contrataciones AI correspondientes a los meses anteriores acumulados (Subinforme).
    /// </summary>
    public List<ContratacionesAIDetalleDto> DatosAnterior { get; set; } = new();
    
    /// <summary>
    /// Totales destacados del informe (Principal).
    /// </summary>
    public decimal TotalImporte => Math.Round(Datos.Sum(x => x.Importe), 0, MidpointRounding.AwayFromZero);
    
    /// <summary>
    /// Subinformes asociados (Fase 2: ContratacionesAnnoAnterior).
    /// </summary>
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
}
