using System;
using System.Collections.Generic;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.DTOs.Informes.ContratacionesSignificativas;

public class ContratacionesSignificativasResponseDto
{
    public List<ContSigDireccionDto> Datos { get; set; } = new();
    public decimal TotalGeneral { get; set; }
    public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
    public MetaContSigDto Meta { get; set; } = new();

    /// <summary>
    /// Subinforme de detalle mensual: contratos individuales >= 1M€.
    /// Tabla plana de 3 columnas: Cliente | Oferta/Descripción | Importe.
    /// Ordenada por ImporteContratado DESC (global, sin agrupamiento).
    /// </summary>
    public List<ContSigMesDto> DatosMes { get; set; } = new();

    /// <summary>
    /// Subinforme de detalle mensual histórico (meses anteriores del mismo año).
    /// </summary>
    public List<ContSigMesDto> DatosMesesAnteriores { get; set; } = new();
}

public class ContSigDireccionDto
{
    public int Orden { get; set; }
    public string NombreDirNegocio { get; set; } = string.Empty;
    public decimal ImporteContratado { get; set; }
}

public class MetaContSigDto
{
    public string Titulo { get; set; } = "Contrataciones Significativas";
    public ContSigFiltrosDto Filtros { get; set; } = new();
    public DateTime FechaGeneracion { get; set; } = DateTime.Now;
}

public class ContSigFiltrosDto
{
    public int Anio { get; set; }
    public int Mes { get; set; }
    public string Mercado { get; set; } = string.Empty;
    public string CodSubDirGeneral { get; set; } = string.Empty;
    public int? NroPagina { get; set; }
    public decimal LimiteImporte { get; set; }
}

/// <summary>
/// DTO de detalle mensual (tabla plana: Cliente | Oferta | Importe).
/// NombreDirNegocio se incluye como clave de vinculación con el informe base,
/// pero NO genera agrupación visual en el frontend.
/// </summary>
public class ContSigMesDto
{
    public int Orden { get; set; }
    public string NombreDirNegocio { get; set; } = string.Empty;

    /// <summary>Nombre del cliente (sin comillas).</summary>
    public string NombreCliente_OK { get; set; } = string.Empty;

    /// <summary>Descripción de la oferta (sin comillas).</summary>
    public string DescripcionOferta_OK { get; set; } = string.Empty;

    /// <summary>Importe en miles de euros.</summary>
    public decimal ImporteContratado { get; set; }
}
