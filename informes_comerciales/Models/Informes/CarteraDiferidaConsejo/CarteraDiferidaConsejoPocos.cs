using System.Collections.Generic;

namespace Elecnor_Informes_Comerciales.Models.Informes.CarteraDiferidaConsejo
{
    public class CarteraDiferidaConsejoPoco
    {
        public int Año { get; set; }
        public string Pais { get; set; } = string.Empty;
        public decimal Importe_Contratado { get; set; }
        public decimal Importe_ContratadoAcumulado { get; set; }
        public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
        public decimal Objetivos { get; set; }
        public decimal ObjetivosMensual { get; set; }
    }

    public class MercadoAIPoco
    {
        public int Año { get; set; }
        public decimal Mensual_Contratacion { get; set; }
        public string Mercado { get; set; } = string.Empty;
        public decimal Acumulado_Contratacion { get; set; }
        public decimal Acumulado_ContratacionAñoAnterior { get; set; }
        public decimal Mer { get; set; }
    }

    /// <summary>
    /// POCO para mapeo directo de VentasRPT (lectura directa, sin tabla de trabajo).
    /// Las propiedades usan alias definidos en el SELECT del repositorio (columnas numéricas).
    /// </summary>
    public class VentasPoco
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
}
