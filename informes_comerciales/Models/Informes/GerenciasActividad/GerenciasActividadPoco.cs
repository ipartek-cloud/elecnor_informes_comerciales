namespace Elecnor_Informes_Comerciales.Models.Informes.GerenciasActividad;

/// <summary>
/// POCO que mapea el ResultSet del SELECT final del Repository del informe
/// "Gerencias Actividad" (Gerente × Mercado × DN × Centro).
/// Tipos verificados contra BD/RP_SIC/dbo/ (ver Analisis_Gerencias_Totales.md §2.2).
/// </summary>
public class GerenciasActividadPoco
{
    // Origen: [dbo].[rptContratacion_GerenciaCentro].[Año] -> INT NULL
    public int Año { get; set; }

    // Origen: [dbo].[rptContratacion_GerenciaCentro].[NombreGerente] -> NVARCHAR(255) NULL
    public string? NombreGerente { get; set; }

    // Origen: [dbo].[Sumarigrama].[CodDDirNegocio] -> VARCHAR(3) NULL
    public string? CodDDirNegocio { get; set; }

    // Origen: [dbo].[Sumarigrama].[NombreDirNegocio] -> VARCHAR NULL
    public string? NombreDirNegocio { get; set; }

    // Origen: [dbo].[rptContratacion_GerenciaCentro].[CodCentro] -> NVARCHAR(255) NULL
    public string? CodCentro { get; set; }

    // Origen: [dbo].[Sumarigrama].[NombreCentro] -> VARCHAR NULL
    public string? NombreCentro { get; set; }

    // Origen: calculado en SQL (CASE cg.Mercado WHEN 'I' THEN 'Internacional' ELSE 'Nacional' END)
    public string? Mercado { get; set; }

    // Origen: [dbo].[Orden_CodDDirNegocio].[Orden_CodDDirNegocio] -> INT NULL
    public int? OrdenCodDDirNegocio { get; set; }

    // Origen: [dbo].[rptContratacion_GerenciaCentro].[ImporteContratado] -> DECIMAL(18,2) NULL
    public decimal ImporteContratado { get; set; }

    // Origen: [dbo].[rptContratacion_GerenciaCentro].[ImporteContratadoAcumulado] -> DECIMAL(18,2) NULL
    public decimal ImporteContratadoAcumulado { get; set; }

    // Origen: [dbo].[rptContratacion_GerenciaCentro].[ImporteContratadoAcumuladoAñoAnterior] -> DECIMAL(18,2) NULL
    public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }

    // Origen: [dbo].[vwObjetivosActividadSQL_Nacional_Internacional].[importe] (sumado)
    public decimal Objetivos { get; set; }

    // Origen: TVF [dbo].[fn_veCarteraPdteProducirSQL_AnioActual] (sumado)
    public decimal CarteraPdteAñoActual { get; set; }

    // Origen: TVF [dbo].[fn_veCarteraPdteProducirSQL_AnioAnterior] (sumado)
    public decimal CarteraPdteAñoAnterior { get; set; }
}
