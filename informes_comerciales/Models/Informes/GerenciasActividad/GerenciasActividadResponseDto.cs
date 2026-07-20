using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.GerenciasActividad;

/// <summary>
/// DTO raíz del informe "Gerencias Actividad" (Gerente × Mercado × DN × Centro).
/// Estructura jerárquica:
///   GruposGerente → GruposMercado → DireccionesNegocio → Centros
/// con totales por cada nivel (TotalGerencia, TotalMercado, TotalDN) y un TotalGeneral global.
/// </summary>
public class GerenciasActividadResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<GrupoGerenteDto> GruposGerente { get; set; } = new();
    public TotalesEstandarDto TotalGeneral { get; set; } = new();

    // Mandato arquitectónico (scaffold-nuevo-informe §DTOs): todo DTO raíz incluye SubinformesAnexos
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
}

/// <summary>
/// Agrupación por Gerente. Contiene la lista de mercados (Nacional + Internacional) y
/// el gran total "Total Nacional+Internacional".
/// </summary>
public class GrupoGerenteDto
{
    public string NombreGerente { get; set; } = string.Empty;
    public List<GrupoMercadoDto> GruposMercado { get; set; } = new();
    public TotalesEstandarDto TotalGerente { get; set; } = new();
}

/// <summary>
/// Agrupación por Mercado (Nacional | Internacional). En el Access original no tiene cabecera
/// visual: el "Subtotal Nacional"/"Subtotal Internacional" se muestra como una fila azul al final
/// de cada mercado (PieGrupo1), no como banner.
/// </summary>
public class GrupoMercadoDto
{
    public string Mercado { get; set; } = string.Empty; // "Nacional" | "Internacional"
    public List<BloqueDireccionNegocioDto> DireccionesNegocio { get; set; } = new();
    public TotalesEstandarDto TotalMercado { get; set; } = new();
}

/// <summary>
/// Bloque por Dirección de Negocio dentro de un mercado. El subtotal DN (PieGrupo2) se muestra
/// como una fila sin etiqueta visible (celda central vacía con `&nbsp;`). Si CodDDirNegocio = "800",
/// se renderiza la nota "(*) Incluye 20.000 de internacional" en una fila italic bajo el subtotal.
/// </summary>
public class BloqueDireccionNegocioDto
{
    public string CodDDirNegocio { get; set; } = string.Empty;
    public string NombreDirNegocio { get; set; } = string.Empty; // Sin prefijo "DIR." (fgsustituye Access)
    public int? OrdenCodDDirNegocio { get; set; }
    public bool MostrarNotaDN800 { get; set; }
    public List<CentroItemDto> Centros { get; set; } = new();
    public TotalesEstandarDto TotalDN { get; set; } = new();
}

/// <summary>
/// Detalle por centro. CodCentro con PadLeft(3, '0'). Importes en miles de euros
/// (división por 1000 aplicada en Service). IP y variaciones calculadas en Service
/// mediante InformeCalculosUtils.
/// </summary>
public class CentroItemDto
{
    public string CodCentro { get; set; } = string.Empty;
    public string NombreCentro { get; set; } = string.Empty;
    public decimal ObjetivoMensual { get; set; }     // Objetivos / 12
    public decimal ContratacionMensual { get; set; } // ImporteContratado / 1000
    public decimal ObjetivoAnual { get; set; }       // Objetivos
    public decimal ContratacionAcumulada { get; set; } // ImporteContratadoAcumulado / 1000
    public decimal IndiceProduccion { get; set; }    // InformeCalculosUtils.CalcularIp
    public decimal AnoAnterior { get; set; }          // ImporteContratadoAcumuladoAñoAnterior / 1000
    public string VariacionContratacion { get; set; } = string.Empty; // CalcularVariacionContratacion
    public string VariacionCartera { get; set; } = string.Empty;       // CalcularVariacionCartera
    public decimal CarteraPdteAñoActual { get; set; }   // CarteraPdteAñoActual / 1000
    public decimal CarteraPdteAñoAnterior { get; set; } // CarteraPdteAñoAnterior / 1000
}
