namespace Elecnor_Informes_Comerciales.Models.Informes.Mercados
{
    /// <summary>
    /// Modelo POCO plano mapeado directamente desde el ResultSet del Procedimiento Almacenado de SQL Server.
    /// No contiene lógica y es la estructura cruda base para la agrupación en el Service.
    /// </summary>
    public class MercadosPoco
    {
        public int Año { get; set; }
        public int Orden { get; set; }
        public string? Pais { get; set; }
        public string? NombreSubDirGeneral { get; set; }
        public string? NombreDirNegocio { get; set; }
        public string? CodDirNegocio { get; set; }
        public decimal ImporteContratado { get; set; }
        public decimal ImporteContratadoAcumulado { get; set; }
        public decimal ImporteContratadoAcumuladoAñoAnterior { get; set; }
        public decimal ImporteObjetivo { get; set; }
        public decimal ObjetivoPais { get; set; }
        public decimal ObjetivoSDGPais { get; set; }
    }
}
