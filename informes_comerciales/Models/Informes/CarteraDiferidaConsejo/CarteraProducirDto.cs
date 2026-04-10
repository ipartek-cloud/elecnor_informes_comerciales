using System;
using System.Collections.Generic;

namespace Elecnor_Informes_Comerciales.Models.Informes.CarteraDiferidaConsejo
{
    public class CarteraProducirDto
    {
        public string TituloColInicial { get; set; } = string.Empty; // "31.12.2025"
        public string TituloColActual { get; set; } = string.Empty;  // "Marzo 2026"
        public string TituloColDelta { get; set; } = string.Empty;   // "Δ Dic 2025"
        public List<CarteraLineaDto> Lineas { get; set; } = new();
        public CarteraTotalesDto Totales { get; set; } = new();
    }

    public class CarteraLineaDto
    {
        public string Concepto { get; set; } = string.Empty;
        public decimal ImporteInicial { get; set; }
        public decimal ImporteActual { get; set; }
        public decimal? PorcentajeIncremento { get; set; }
        public bool IsIndented { get; set; }
        public bool IsMainConcept { get; set; }
    }

    public class CarteraTotalesDto
    {
        public decimal ImporteInicial { get; set; }
        public decimal ImporteActual { get; set; }
        public string VariacionCartera { get; set; } = string.Empty;
        public string VariacionAñoAnterior { get; set; } = string.Empty;
    }
}
