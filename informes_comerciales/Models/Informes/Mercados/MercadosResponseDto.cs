using System.Collections.Generic;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Models.Informes.Mercados
{
    public class MercadosResponseDto
    {
        public MetaInformeDto Meta { get; set; } = new();

        // BLOQUE 1: Resumen global Nacional/Internacional
        public List<FilaDatoDto> ResumenGlobal { get; set; } = new();
        public FilaDatoDto TotalGlobal { get; set; } = new();

        // BLOQUE 2: Desglose por DirNegocio (Ej: DG. Elecnor Servicios)
        public List<DirNegocioItemDto> DirNegocios { get; set; } = new();
    }

    public class DirNegocioItemDto
    {
        public string Nombre { get; set; } = string.Empty;

        // Sub-bloque A: Nacional / Internacional de esta DirNegocio
        public List<FilaDatoDto> Mercados { get; set; } = new();
        
        // Sub-bloque B: Unidades de Negocio (SubDirGeneral) de esta DirNegocio
        public List<FilaDatoDto> Unidades { get; set; } = new();
        
        // Total que aplica tanto al sub-bloque A como al B (deben sumar lo mismo)
        public FilaDatoDto Total { get; set; } = new();
    }

    public class FilaDatoDto
    {
        public string Nombre { get; set; } = string.Empty;
        public ValoresSeccionDto Mensual { get; set; } = new();
        public ValoresSeccionDto Acumulado { get; set; } = new();
    }

    public class ValoresSeccionDto
    {
        public decimal ImporteContratado { get; set; }
        public decimal ImporteObjetivo { get; set; }
        public decimal IndiceProduccion { get; set; }
        public decimal ImporteAñoAnterior { get; set; }
        public string Variacion { get; set; } = string.Empty;
    }
}
