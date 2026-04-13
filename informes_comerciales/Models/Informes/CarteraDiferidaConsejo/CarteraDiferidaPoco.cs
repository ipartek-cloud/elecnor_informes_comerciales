namespace Elecnor_Informes_Comerciales.Models.Informes.CarteraDiferidaConsejo
{
    /// <summary>
    /// POCO para el subinforme Cartera Diferida (Consejo).
    /// Las columnas SQL se calculan dinámicamente según @Anio - 1.
    /// Para anio=N: ValorCart1_1=[01#01#(N-1)], ValorAnio1=[N-1], ValorAnio2=[N], ValorAnio3=[N+1].
    /// </summary>
    public class CarteraDiferidaPoco
    {
        public int Año { get; set; }
        public int Mes { get; set; }
        public string Mercado { get; set; } = string.Empty;
        public string CarteraDiferida { get; set; } = string.Empty;

        // Cartera al 1.1. del año de referencia (columna dinámica [01#01#NN])
        public decimal ValorCart1_1 { get; set; }

        // Campos preservados de la BD (no dependen del año)
        public decimal Nuevos { get; set; }
        public decimal Total { get; set; }
        public decimal Contr { get; set; }

        // Proyecciones dinámicas (columnas [N], [N+1], [N+2])
        public decimal ValorAnio1 { get; set; }
        public decimal ValorAnio2 { get; set; }
        public decimal ValorAnio3 { get; set; }

        public int Orden { get; set; }
    }
}
