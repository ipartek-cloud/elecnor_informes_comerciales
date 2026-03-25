using System;

namespace Elecnor_Informes_Comerciales.Models.Informes.Contrataciones
{
    /// <summary>
    /// POCO para los datos del subinforme de Contrataciones Año Internacional Anterior.
    /// Mapeado desde la tabla rptPrincipalesObras (Acumulado meses anteriores).
    /// </summary>
    public class ContratacionesAnnoInternacionalAnteriorPoco
    {
        public string AI { get; set; } = string.Empty;
        public string DescripcionOfertas_OK { get; set; } = string.Empty;
        public string NombreClientes_OK { get; set; } = string.Empty;
        public decimal ImporteContratado_OK { get; set; }
        public string NombreDirNegocio_OK { get; set; } = string.Empty;
        public string Meses { get; set; } = string.Empty;
    }
}
