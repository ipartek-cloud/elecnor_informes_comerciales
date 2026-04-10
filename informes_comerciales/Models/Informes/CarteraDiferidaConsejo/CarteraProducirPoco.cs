namespace Elecnor_Informes_Comerciales.Models.Informes.CarteraDiferidaConsejo
{
    public class CarteraProducirPoco
    {
        public int Año { get; set; }
        public int Mes { get; set; }
        public string Concepto { get; set; } = string.Empty;
        public decimal ImporteInicial { get; set; }
        public decimal ImporteActual { get; set; }
        public decimal? PorcentajeIncrementoAñoAnterior { get; set; }
        public int SumarCartera { get; set; }
        public decimal CarteraAñoAnterior { get; set; }
    }
}
