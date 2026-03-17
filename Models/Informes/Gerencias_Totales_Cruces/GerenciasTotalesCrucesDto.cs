using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.Gerencias_Totales_Cruces;

/// <summary>
/// Objeto raíz que devuelve la API para el informe de Gerencias Totales Cruces.
/// </summary>
public class GerenciasTotalesCrucesDto
{
    public MetaInformeDto Meta { get; set; } = new();
    public List<GerenteSeccionDto> Gerentes { get; set; } = new();
    public TotalesSeccionDto PieTotal { get; set; } = new();
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
}

/// <summary>
/// Agrupa la información de un Gerente (Nivel 1 de agrupamiento en Access).
/// </summary>
public class GerenteSeccionDto
{
    public string NombreGerente { get; set; } = string.Empty;
    public List<DireccionNegocioDto> DireccionesNegocio { get; set; } = new();
    public TotalesSeccionDto TotalesGerente { get; set; } = new();
}

/// <summary>
/// Agrupa la información de una Dirección de Negocio (Nivel 2 de agrupamiento en Access).
/// </summary>
public class DireccionNegocioDto
{
    public string NombreDirNegocio { get; set; } = string.Empty;
    public string NotaAclaratoriaDG { get; set; } = string.Empty;
    public List<GerenciaCentroDetalleDto> Centros { get; set; } = new();
    public TotalesSeccionDto TotalesDireccion { get; set; } = new();
}

/// <summary>
/// Detalle individual de cada Centro (banda de Detalle en Access).
/// </summary>
public class GerenciaCentroDetalleDto
{
    public string CodCentro { get; set; } = string.Empty;
    public string NombreCentro { get; set; } = string.Empty;

    // Mensual
    public decimal ObjetivosMensual { get; set; }
    public decimal ContratacionMensual { get; set; }

    // Acumulado
    public decimal ObjetivosAcumulado { get; set; }
    public decimal ContratacionAcumulada { get; set; }
    public decimal Ip { get; set; }

    // Variaciones (Formateadas desde el Service)
    public string VariacionContratacion { get; set; } = string.Empty;
    public string VariacionCartera { get; set; } = string.Empty;
}

/// <summary>
/// Estructura común para los totales de Pie de Grupo y Pie de Informe.
/// </summary>
public class TotalesSeccionDto
{
    public decimal TotalObjetivoMensual { get; set; }
    public decimal TotalContratacionMensual { get; set; }
    public decimal TotalObjetivoAcumulado { get; set; }
    public decimal TotalContratacionAcumulada { get; set; }
    public decimal IpMedia { get; set; }

    // Variaciones (Cálculo de negocio del Service)
    public string VariacionContratacion { get; set; } = string.Empty;
    public string VariacionCartera { get; set; } = string.Empty;
}
