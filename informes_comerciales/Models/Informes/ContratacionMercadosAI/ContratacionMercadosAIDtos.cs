using System;
using System.Collections.Generic;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.ContratacionMercadosAI
{
    /// <summary>
    /// DTO raíz para el informe Contratación Mercados AI.
    /// Usa TotalesEstandarDto para homogeneizar el payload JSON (unificación frontend).
    /// </summary>
    public class ContratacionMercadosAIDto
    {
        public MetaInformeDto Meta { get; set; } = new();
        public List<AgrupacionAñoDto> Agrupaciones { get; set; } = new();
        public TotalesEstandarDto PieTotal { get; set; } = new();
    }

    /// <summary>
    /// Agrupación por año (nivel principal de este informe).
    /// </summary>
    public class AgrupacionAñoDto
    {
        public int Año { get; set; }
        public List<MercadoDetalleDto> Detalles { get; set; } = new();
        public TotalesEstandarDto Totales { get; set; } = new();
        public List<SubMercadoAIDto> SubMercadosAI { get; set; } = new();
        public TotalesEstandarDto TotalesAI { get; set; } = new();
        public CarteraProducirDto CarteraProduccion { get; set; } = new();
        public CarteraDiferidaDto CarteraDiferida { get; set; } = new();
        public VentasDto Ventas { get; set; } = new();
    }

    public class MercadoDetalleDto
    {
        public string Pais { get; set; } = string.Empty;
        public decimal ObjetivoMensual { get; set; }
        public decimal ImporteContratadoMensual { get; set; }
        public decimal ObjetivoAnual { get; set; }
        public decimal ImporteContratadoAcumulado { get; set; }
        public decimal IndiceProduccion { get; set; }
        public string Variacion { get; set; } = string.Empty;
    }

    public class SubMercadoAIDto
    {
        public string Mercado { get; set; } = string.Empty;
        public decimal ImporteContratadoMensual { get; set; }
        public decimal ImporteContratadoAcumulado { get; set; }
        public decimal PorcentajeSobreMercado { get; set; }
        public string Variacion { get; set; } = string.Empty;
    }

    /// <summary>
    /// Fila de detalle del subinforme Ventas (una fila por mercado: Internacional, Nacional).
    /// </summary>
    public class VentasLineaDto
    {
        public string Mercado { get; set; } = string.Empty;
        public decimal? Anio2017 { get; set; }
        public decimal? Anio2018 { get; set; }
        public decimal? Anio2019 { get; set; }
        public decimal? Anio2020 { get; set; }
        public decimal? Anio2021 { get; set; }
        public decimal? Anio2022 { get; set; }
        public decimal? Anio2023 { get; set; }
        public decimal? Anio2024 { get; set; }
        public decimal? Anio2025 { get; set; }
    }

    /// <summary>
    /// Fila de totales del subinforme Ventas (suma de cada columna anual).
    /// </summary>
    public class VentasTotalesDto
    {
        public decimal Total2017 { get; set; }
        public decimal Total2018 { get; set; }
        public decimal Total2019 { get; set; }
        public decimal Total2020 { get; set; }
        public decimal Total2021 { get; set; }
        public decimal Total2022 { get; set; }
        public decimal Total2023 { get; set; }
        public decimal Total2024 { get; set; }
        public decimal Total2025 { get; set; }
    }

    /// <summary>
    /// DTO raíz del subinforme Ventas (contenedor de líneas + totales).
    /// </summary>
    public class VentasDto
    {
        public List<VentasLineaDto> Lineas { get; set; } = new();
        public VentasTotalesDto Totales { get; set; } = new();
    }
}
