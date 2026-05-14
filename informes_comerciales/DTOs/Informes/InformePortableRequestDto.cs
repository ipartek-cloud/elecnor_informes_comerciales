using System.ComponentModel.DataAnnotations;

namespace Elecnor_Informes_Comerciales.DTOs.Informes;

/// <summary>
/// DTO para la solicitud de generación de un Informe HTML Portable (Self-Contained).
/// Captura todos los parámetros necesarios, incluyendo los filtros dinámicos (data-*).
/// </summary>
public class InformePortableRequestDto
{
    /// <summary>
    /// Identificador del tipo de informe (ej: 'mercados', 'paises', 'contrataciones').
    /// Debe coincidir con el nombre del archivo JS en wwwroot/js/informes/
    /// </summary>
    [Required]
    public string TipoInforme { get; set; } = string.Empty;

    /// <summary>
    /// Año de consulta (2000-2100).
    /// </summary>
    [Range(2000, 2100)]
    public int Anio { get; set; }

    /// <summary>
    /// Mes hasta el cual se acumulan los datos (1-12).
    /// El informe portable generará datos desde el mes 1 hasta este mes.
    /// </summary>
    [Range(1, 12)]
    public int Mes { get; set; }

    /// <summary>
    /// Filtros dinámicos adicionales capturados de los atributos data-* del botón.
    /// Ej: { "mercado": "Nacional", "subdireccion": "221", "umbral": "100000" }
    /// </summary>
    public Dictionary<string, string>? Filtros { get; set; }
}
