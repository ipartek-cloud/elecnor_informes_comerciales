namespace Elecnor_Informes_Comerciales.DTOs.Informes;

/// <summary>
/// Sobre envolvente para la respuesta de la API REST de datos JSON (un solo mes).
/// Añade el contexto de la petición al DTO crudo del informe.
/// </summary>
public class JsonRptResponseDto
{
    public string TipoInforme { get; set; } = string.Empty;
    public int Anio { get; set; }
    public int Mes { get; set; }
    public DateTime GeneradoEn { get; set; }
    public string Usuario { get; set; } = string.Empty;

    /// <summary>
    /// DTO crudo del informe (idéntico al que consume el frontend web y el HTML Portable).
    /// </summary>
    public object Datos { get; set; } = new { };
}

/// <summary>
/// Sobre envolvente para la respuesta de la API REST de datos JSON (multi-mes).
/// </summary>
public class JsonRptMultiMesResponseDto
{
    public string TipoInforme { get; set; } = string.Empty;
    public int Anio { get; set; }
    public List<int> MesesSolicitados { get; set; } = new();
    public DateTime GeneradoEn { get; set; }
    public string Usuario { get; set; } = string.Empty;

    /// <summary>
    /// DTO crudo del informe indexado por mes (claves "1".."12" en el JSON resultante).
    /// </summary>
    public Dictionary<int, object> DatosPorMes { get; set; } = new();

    /// <summary>
    /// Meses solicitados para los que no se obtuvieron datos (información al consumidor).
    /// </summary>
    public List<int> MesesSinDatos { get; set; } = new();
}
