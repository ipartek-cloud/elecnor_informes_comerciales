namespace Elecnor_Informes_Comerciales.Models.Informes.MercadosDG
{
    /// <summary>
    /// POCO para el subinforme Cartera Diferida de MercadosDG.
    /// Las columnas SQL se calculan dinámicamente según @Anio.
    /// </summary>
    public class MercadosDGCarteraDiferidaPoco
    {
        public string CarteraDiferida { get; set; } = string.Empty;
        public decimal ValorCartPrev { get; set; }
        public decimal ValorCartAct { get; set; }
        public decimal ValorFuturo1 { get; set; }
        public decimal ValorFuturo2 { get; set; }
        public decimal ValorFuturo3 { get; set; }
        public int Orden { get; set; }
    }
}
