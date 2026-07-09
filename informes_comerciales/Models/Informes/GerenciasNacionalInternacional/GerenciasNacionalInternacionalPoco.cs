namespace Elecnor_Informes_Comerciales.Models.Informes.GerenciasNacionalInternacional;

/// <summary>
/// POCO que mapea el resultado del SELECT optimizado sobre rptContratacion_GerenciaCentro
/// para el informe Gerencias Nacional/Internacional.
/// </summary>
public class GerenciasNacionalInternacionalPoco
{
    // Origen: [rptContratacion_GerenciaCentro].[Año] -> INT NULL
    public int Año { get; set; }

    // Origen: [CentrosGerentesSQL].[Orden] -> NCHAR(10) NULL
    public string Orden { get; set; } = string.Empty;

    // Origen: [CentrosGerentesSQL].[SumarizaGerentes] -> VARCHAR(150) NULL
    public string SumarizaGerentes { get; set; } = string.Empty;

    // Origen: [rptContratacion_GerenciaCentro].[NombreGerente] -> NVARCHAR(255) NULL
    public string Actividad { get; set; } = string.Empty;

    // Origen: Constante o [CentrosGerentesSQL].[Mercado] ('N'/'I'/'T')
    public string Mercado { get; set; } = string.Empty;

    // Contratación en euros reales (se divide por 1000 en Service)
    public decimal ImporteContratado { get; set; }
    public decimal ImporteContratadoAcumulado { get; set; }
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }

    // Objetivos en euros reales (proveniente de la vista vwObjetivosActividadSQL_Nacional_Internacional)
    public decimal Objetivos { get; set; }

    // Cartera en euros reales (se divide por 1000 en Service)
    public decimal CarteraPdteAñoActual { get; set; }
    public decimal CarteraPdteAñoAnterior { get; set; }
}
