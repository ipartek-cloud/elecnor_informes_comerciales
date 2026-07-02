using System.Collections.Generic;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.ContratacionMercadosSDGDN;

/// <summary>DTO raiz del informe Contratacion Mercados SDG Agrupado DN.</summary>
public class ContratacionMercadosSDGDNResponseDto
{
    public MetaInformeDto Meta { get; set; } = new();

    public List<ResumenMercadoDto> ResumenPorMercado { get; set; } = new();
    public TotalesGlobalesDto TotalGlobal { get; set; } = new();
    public List<DetalleDNDto> DetallesPorDN { get; set; } = new();
}

/// <summary>Fila del bloque 1 (resumen por mercado: Nacional / Internacional).</summary>
public class ResumenMercadoDto
{
    public string Pais { get; set; } = string.Empty;

    public decimal ContratacionMensual { get; set; }
    public decimal ContratacionAcumulado { get; set; }
    public decimal ContratacionAcumuladoAnterior { get; set; }

    public decimal ObjetivoMensual { get; set; }
    public decimal ObjetivoAnual { get; set; }

    public decimal Ip { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
    public string UmbralTexto { get; set; } = string.Empty;
}

/// <summary>Total global (suma de Nacional + Internacional).</summary>
public class TotalesGlobalesDto
{
    public decimal ContratacionMensual { get; set; }
    public decimal ContratacionAcumulado { get; set; }
    public decimal ContratacionAcumuladoAnterior { get; set; }
    public decimal ObjetivoMensual { get; set; }
    public decimal ObjetivoAnual { get; set; }
    public decimal Ip { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
}

/// <summary>Fila del bloque 2 (detalle por Direccion de Negocio + Area + Delegacion + Pais).</summary>
public class DetalleDNDto
{
    public int OrdenDN { get; set; }
    public string CodDDirNegocio { get; set; } = string.Empty;
    public string NombreDirNegocio { get; set; } = string.Empty;
    public string CodSubDirNegocioArea { get; set; } = string.Empty;
    public string NombreSubDirNegocioArea { get; set; } = string.Empty;
    public string CodDelegacion { get; set; } = string.Empty;
    public string NombreDelegacion { get; set; } = string.Empty;
    public string CodSubDirGeneral { get; set; } = string.Empty;
    public string NombreSubDirGeneral { get; set; } = string.Empty;
    public string Pais { get; set; } = string.Empty;

    public decimal ContratacionMensual { get; set; }
    public decimal ContratacionAcumulado { get; set; }
    public decimal ContratacionAcumuladoAnterior { get; set; }

    public decimal ObjetivoAnual { get; set; }
    public decimal ObjetivoMensual => ObjetivoAnual / 12m;
    public bool EsSubtotal { get; set; }

    public decimal Ip { get; set; }
    public string VariacionContratacion { get; set; } = string.Empty;
    public decimal Umbral { get; set; }
    public string UmbralTexto { get; set; } = string.Empty;
    public bool SuperaUmbral { get; set; }
}
