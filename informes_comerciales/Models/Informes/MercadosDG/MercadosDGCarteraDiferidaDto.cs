using System.Collections.Generic;

namespace Elecnor_Informes_Comerciales.Models.Informes.MercadosDG
{
    /// <summary>
    /// DTO del subinforme Cartera Diferida para MercadosDG.
    /// </summary>
    public class MercadosDGCarteraDiferidaDto
    {
        public List<MercadosDGCarteraDiferidaLineaDto> Lineas { get; set; } = new();
        public MercadosDGCarteraDiferidaTotalesDto Totales { get; set; } = new();
    }

    public class MercadosDGCarteraDiferidaLineaDto
    {
        public string Concepto { get; set; } = string.Empty;
        public decimal ValorCartPrev { get; set; }
        public decimal ValorCartAct { get; set; }
        public decimal ValorFuturo1 { get; set; }
        public decimal ValorFuturo2 { get; set; }
    }

    public class MercadosDGCarteraDiferidaTotalesDto
    {
        public decimal ValorCartPrev { get; set; }
        public decimal ValorCartAct { get; set; }
        public decimal ValorFuturo1 { get; set; }
        public decimal ValorFuturo2 { get; set; }
    }
}
