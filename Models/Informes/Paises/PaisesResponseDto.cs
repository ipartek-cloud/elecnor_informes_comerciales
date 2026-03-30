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
/// Totales del informe de Países.
/// Fila 1 (SubTotal*): suma de importes y porcentajes de los países filtrados y mostrados en pantalla.
/// Fila 2 (TotalInternacional*): total global real del mercado internacional (ya viene /1000 desde BD).
/// </summary>
public class TotalesPaisesDto
{
    // --- FILA 1: Subtotal de países visibles (suma de lo mostrado en el detalle) ---
    public decimal SubtotalImporteAnterior { get; set; }
    public decimal SubtotalImporteActual { get; set; }
    public decimal SubtotalPorcentajeAnterior { get; set; }
    public decimal SubtotalPorcentajeActual { get; set; }

    // --- FILA 2: Total Internacional Global (ya dividido entre 1000 en BD) ---
    public decimal TotalInternacionalAnterior { get; set; }
    public decimal TotalInternacionalActual { get; set; }
    
    // Campo extra para el pie del informe (DG Infraestructuras)
    public decimal TotalInternacionalDGInfrActual { get; set; }
}
