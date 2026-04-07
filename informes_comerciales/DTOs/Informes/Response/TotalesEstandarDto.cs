namespace Elecnor_Informes_Comerciales.DTOs.Informes.Response;

/// <summary>
/// DTO estándar de totales para todos los informes.
/// Reemplaza a TotalesSeccionDto, TotalesGlobalesDto y TotalesSeccionAIDto.
/// Unifica la nomenclatura de propiedades para permitir reutilización de código frontend.
/// </summary>
public class TotalesEstandarDto
{
    // ─────────────────────────────────────────────────────────
    // BLOQUE MENSUAL (si aplica)
    // ─────────────────────────────────────────────────────────
    
    /// <summary>
    /// Objetivo mensual (anual / 12)
    /// </summary>
    public decimal ObjetivoMensual { get; set; }
    
    /// <summary>
    /// Contratación mensual del periodo actual
    /// </summary>
    public decimal ContratacionMensual { get; set; }

    // ─────────────────────────────────────────────────────────
    // BLOQUE ACUMULADO
    // ─────────────────────────────────────────────────────────
    
    /// <summary>
    /// Objetivo anual acumulado
    /// </summary>
    public decimal ObjetivoAnual { get; set; }
    
    /// <summary>
    /// Contratación acumulada del año actual
    /// </summary>
    public decimal ContratacionAcumulada { get; set; }

    // ─────────────────────────────────────────────────────────
    // RATIOS
    // ─────────────────────────────────────────────────────────
    
    /// <summary>
    /// Índice de Producción (IP) = Contratación Acumulada / (Objetivo Mensual * Mes)
    /// </summary>
    public decimal IndiceProduccion { get; set; }

    // ─────────────────────────────────────────────────────────
    // VARIACIONES (formato string: "12%", ">1000%", "-")
    // ─────────────────────────────────────────────────────────
    
    /// <summary>
    /// Variación de contratación respecto al año anterior
    /// </summary>
    public string VariacionContratacion { get; set; } = string.Empty;
    
    /// <summary>
    /// Variación de cartera pendiente respecto al año anterior (opcional, puede ser null)
    /// </summary>
    public string? VariacionCartera { get; set; }

    // ─────────────────────────────────────────────────────────
    // ESPECÍFICOS (usar solo cuando aplique)
    // ─────────────────────────────────────────────────────────
    
    /// <summary>
    /// Porcentaje sobre el mercado total (solo para subinformes de mercado/AI)
    /// </summary>
    public decimal? PorcentajeSobreMercado { get; set; }
}
