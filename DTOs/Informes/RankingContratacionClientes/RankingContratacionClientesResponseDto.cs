using System;
using System.Collections.Generic;
using System.Linq;

namespace Elecnor_Informes_Comerciales.DTOs.Informes.RankingContratacionClientes;

public class RankingContratacionClientesResponseDto
{
    public List<RankingContratacionClientesDetalleDto> Datos { get; set; } = new();
    
    /// <summary>
    /// Suma de los 30 primeros (los que se visualizan en la lista)
    /// </summary>
    public decimal SumaTop30 => Datos.Sum(x => x.Importe);
    
    /// <summary>
    /// Total de todo el mercado (obtenido de fnSumaContratacionActual_Clientes)
    /// </summary>
    public decimal TotalMercado { get; set; }

    /// <summary>
    /// Porcentaje de los 30 primeros sobre el total del mercado
    /// </summary>
    public decimal PorcentajeTop30 => TotalMercado > 0 
        ? (SumaTop30 / TotalMercado) * 100 
        : 0;
        
    public object? Meta { get; set; }
}

public class RankingContratacionClientesDetalleDto
{
    public int Row { get; set; }
    public string Cliente { get; set; } = string.Empty;
    public decimal Importe { get; set; } // Acumulado actual
    public decimal? ImporteAnterior { get; set; } // Acumulado año anterior (null si no aplica)
    public string AI { get; set; } = string.Empty;

    // Cálculo del porcentaje sobre el total del mercado (no solo sobre el top 30)
    // Se asignará en el Mapper o el Service
    public decimal PorcentajeSobreTotal { get; set; }
}
