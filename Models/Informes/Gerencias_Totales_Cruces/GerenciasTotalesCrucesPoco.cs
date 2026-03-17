namespace Elecnor_Informes_Comerciales.Models.Informes.Gerencias_Totales_Cruces;

/// <summary>
/// Clase POCO que mapea el resultado directo de SQL para el informe de Gerencias Totales Cruces.
/// </summary>
public class GerenciasTotalesCrucesPoco
{
    // Identificadores y Agrupadores
    public int Año { get; set; }
    public int Orden { get; set; }
    public string NombreGerente { get; set; } = string.Empty;
    public int CodDDirNegocio { get; set; }
    public string NombreDirNegocio { get; set; } = string.Empty;
    public string CodCentro { get; set; } = string.Empty;
    public string NombreCentro { get; set; } = string.Empty;
    public string Mercado { get; set; } = string.Empty;
    public string Orden_CodDDirNegocio { get; set; } = string.Empty;

    // Datos Numéricos (Raw del SQL)
    public decimal ImporteContratadoS { get; set; }
    public decimal ImporteContratadoAcumuladoS { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnteriorS { get; set; }
    public decimal Objetivos { get; set; }
    public decimal CarteraPdteAñoActualS { get; set; }
    public decimal CarteraPdteAñoAnteriorS { get; set; }
}
