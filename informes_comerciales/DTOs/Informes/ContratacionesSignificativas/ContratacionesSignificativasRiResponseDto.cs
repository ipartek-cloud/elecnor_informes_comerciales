using System;
using System.Collections.Generic;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.DTOs.Informes.ContratacionesSignificativas;

/// <summary>
/// DTO de respuesta para el informe de Contrataciones Significativas (Resto de Informes).
/// Versión limpia sin histórico de meses anteriores.
/// </summary>
public class ContratacionesSignificativasRiResponseDto
{
    public List<ContSigDireccionDto> Datos { get; set; } = new();
    public decimal TotalGeneral { get; set; }
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
    public MetaContSigRiDto Meta { get; set; } = new();

    /// <summary>
    /// Detalle mensual: contratos individuales superiores al umbral.
    /// </summary>
    public List<ContSigMesDto> DatosMes { get; set; } = new();
}

public class MetaContSigRiDto
{
    public string Titulo { get; set; } = "Contrataciones Significativas";
    public string UmbralTexto { get; set; } = "> 2 M"; // Para pintar dinámicamente en el frontend
    public ContSigFiltrosDto Filtros { get; set; } = new();
    public DateTime FechaGeneracion { get; set; } = DateTime.Now;
}
