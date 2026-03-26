namespace Elecnor_Informes_Comerciales.DTOs.Informes.Response;

/// <summary>
/// Metadatos del informe (Común para todos).
/// </summary>
public class MetaInformeDto
{
    public string Titulo { get; set; } = string.Empty;
    public string? SubTitulo { get; set; }
    public string? Descripcion { get; set; }
    public object Filtros { get; set; } = new { };
    public DateTime FechaGeneracion { get; set; }
    public string Usuario { get; set; } = string.Empty;
}

/// <summary>
/// Respuesta unificada para informes (Común).
/// </summary>
public class InformeCompletoDto
{
    public string Version { get; set; } = "1.0";
    public MetaInformeDto Meta { get; set; } = new();
    public object Datos { get; set; } = new { };
}

/// <summary>
/// Subinforme genérico con estructura flexible para anexos.
/// </summary>
public class SubinformeDto
{
    public string Id { get; set; } = string.Empty;
    public string Titulo { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public int Orden { get; set; }
    public object Estructura { get; set; } = new { };
    public PieSubinformeDto? PieSubinforme { get; set; }
    public FormatoCondicionalDto? FormatoCondicional { get; set; }
}

/// <summary>
/// Pie de subinforme con totales y notas.
/// </summary>
public class PieSubinformeDto
{
    public decimal? SumaObjetivoTotal { get; set; }
    public decimal? SumaContratacionTotal { get; set; }
    public string? NotaCondicional { get; set; }
}

/// <summary>
/// Configuración de formato condicional.
/// </summary>
public class FormatoCondicionalDto
{
    public string CampoEvaluar { get; set; } = string.Empty;
    public string Condicion { get; set; } = string.Empty;
    public decimal ValorReferencia { get; set; }
    public string ClaseCss { get; set; } = string.Empty;
}
