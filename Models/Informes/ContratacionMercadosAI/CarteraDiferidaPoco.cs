namespace Elecnor_Informes_Comerciales.Models.Informes.ContratacionMercadosAI
{
    public class CarteraDiferidaPoco
    {
        public int Año { get; set; }
        public int Mes { get; set; }
        public string Mercado { get; set; } = string.Empty;
        public string CarteraDiferida { get; set; } = string.Empty;
        public decimal Cart1_1 { get; set; }
        public decimal Nuevos { get; set; }
        public decimal Total { get; set; }
        public decimal Contr { get; set; }
        public decimal Anio1 { get; set; }
        public decimal Anio2 { get; set; }
        public decimal Anio3 { get; set; }
        public int Orden { get; set; }
    }
}
