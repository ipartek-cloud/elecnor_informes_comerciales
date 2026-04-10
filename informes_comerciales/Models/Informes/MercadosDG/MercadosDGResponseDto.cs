using System.Collections.Generic;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.Mercados;

namespace Elecnor_Informes_Comerciales.Models.Informes.MercadosDG
{
    /// <summary>
    /// DTO raíz para el informe D.G. Infraestructuras x Mercado.
    /// </summary>
    public class MercadosDGResponseDto
    {
        public MetaInformeDto Meta { get; set; } = new();

        // 1. Resumen Global (Nacional / Internacional)
        public List<FilaDatoDto> ResumenGlobal { get; set; } = new();
        public FilaDatoDto TotalGlobal { get; set; } = new();

        // 2. Desglose por Direcciones de Negocio
        public List<DirNegocioItemDto> DirNegocios { get; set; } = new();

        // 3. Subinforme Cartera Diferida (NUEVO)
        public MercadosDGCarteraDiferidaDto CarteraDiferida { get; set; } = new();

        // 4. Subinformes Adicionales (Preparado para extensiones futuras)
        public List<SubinformeDto> SubinformesAnexos { get; set; } = new();
    }
}
