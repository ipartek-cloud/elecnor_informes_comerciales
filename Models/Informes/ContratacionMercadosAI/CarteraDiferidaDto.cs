using System.Collections.Generic;

namespace Elecnor_Informes_Comerciales.Models.Informes.ContratacionMercadosAI
{
    public class CarteraDiferidaDto
    {
        public string TituloColInicial { get; set; } = string.Empty;
        public string TituloColAnio1 { get; set; } = string.Empty;
        public string TituloColAnio2 { get; set; } = string.Empty;
        public string TituloColAnio3 { get; set; } = string.Empty;
        
        public List<CarteraDiferidaLineaDto> Lineas { get; set; } = new();
        public CarteraDiferidaTotalesDto Totales { get; set; } = new();
    }

    public class CarteraDiferidaLineaDto
    {
        public string Concepto { get; set; } = string.Empty;
        public decimal Cart1_1 { get; set; }
        public decimal Nuevos { get; set; }
        public decimal Total { get; set; }
        public decimal Contr { get; set; }
        public decimal Ip { get; set; }
        public decimal Anio1 { get; set; }
        public decimal Anio2 { get; set; }
        public decimal Anio3 { get; set; }
    }

    public class CarteraDiferidaTotalesDto
    {
        public decimal Cart1_1 { get; set; }
        public decimal Nuevos { get; set; }
        public decimal Total { get; set; }
        public decimal Contr { get; set; }
        public decimal Ip { get; set; }
        public decimal Anio1 { get; set; }
        public decimal Anio2 { get; set; }
        public decimal Anio3 { get; set; }
    }
}
