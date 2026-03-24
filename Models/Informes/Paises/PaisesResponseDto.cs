using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.Paises;

/// <summary>
/// DTO raíz para la respuesta del informe de Países.
/// </summary>
public class PaisesResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<PaisDetalleDto> Paises { get; set; } = new();
    public TotalesPaisesDto Totales { get; set; } = new();
}

/// <summary>
/// Detalle de cada país con comparativa anual.
/// </summary>
public class PaisDetalleDto
{
    public string Pais { get; set; } = string.Empty;
    public bool EsNuevo { get; set; } // Flag para el asterisco '*'
    
    // Año Anterior (Cierre 2025)
    public decimal ImporteAnterior { get; set; }
    public decimal PorcentajeSobreInternacionalAnterior { get; set; }
    public int PosicionAnterior { get; set; }

    // Año Actual (2026)
    public decimal ImporteActual { get; set; }
    public decimal PorcentajeSobreInternacionalActual { get; set; }
    public int PosicionActual { get; set; }
}

/// <summary>
/// Totales del informe.
/// </summary>
public class TotalesPaisesDto
{
    public decimal TotalInternacionalAnterior { get; set; }
    public decimal TotalInternacionalActual { get; set; }
    public decimal PorcentajeTotalAnterior { get; set; } // Normalmente 100% o subtotal
    public decimal PorcentajeTotalActual { get; set; }
    
    // Campo extra para el pie del informe
    public decimal TotalInternacionalDGInfrActual { get; set; }
}
