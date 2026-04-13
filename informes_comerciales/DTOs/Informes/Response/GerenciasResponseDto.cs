using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.DTOs.Informes.Response;

/// <summary>
/// DTO raíz del informe de Gerencias.
/// Contiene los datos agrupados, totales y metadata para el frontend.
/// </summary>
public class GerenciasResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<GerenciaItemDto> Gerencias { get; set; } = new();
    public TotalesEstandarDto TotalGeneral { get; set; } = new();
}

/// <summary>
/// Representa una fila individual de gerencia en la tabla del informe.
/// DTO plano: propiedades directas, sin sub-objetos anidados.
/// </summary>
public class GerenciaItemDto
{
    public string Actividad { get; set; } = string.Empty;
    public int Orden { get; set; }
    public string SumarizaGerentes { get; set; } = string.Empty;

    // Sección Mensual
    public decimal ObjetivoMensual { get; set; }
    public decimal ContratacionMensual { get; set; }

    // Sección Acumulada
    public decimal ObjetivoAnual { get; set; }
    public decimal ContratacionAcumulada { get; set; }
    public decimal IndiceProduccion { get; set; }

    // Año Anterior (para cálculo de variación)
    public decimal AnoAnterior { get; set; }

    // Variaciones (string formateado: "12%", "-3%", ">1000%", "-")
    public string VariacionContratacion { get; set; } = string.Empty;

    // Sección Cartera
    public decimal CarteraPdteAñoActual { get; set; }
    public decimal CarteraPdteAñoAnterior { get; set; }
    public string VariacionCartera { get; set; } = string.Empty;
}
