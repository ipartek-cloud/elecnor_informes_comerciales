using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.Services.Informes;
using Elecnor_Informes_Comerciales.Models.Informes.MercadosDG;

namespace Elecnor_Informes_Comerciales.Controllers.Informes
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class MercadosDGController : ControllerBase
    {
        private readonly InformeMercadosDGService _informeMercadosDGService;

        public MercadosDGController(InformeMercadosDGService informeMercadosDGService)
        {
            _informeMercadosDGService = informeMercadosDGService;
        }

        [HttpGet]
        [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any)]
        public async Task<ActionResult<MercadosDGResponseDto>> Get([FromQuery] int anio, [FromQuery] int mes)
        {
            if (anio > DateTime.Now.Year)
            {
                return BadRequest("El año de consulta no puede ser superior al año actual.");
            }

            if (anio < 2000)
            {
                return BadRequest("El año de consulta debe ser posterior a 2000.");
            }

            if (mes < 1 || mes > 12)
            {
                return BadRequest("Mes inválido. Debe estar entre 1 y 12.");
            }

            // La tabla CarteraDiferida_CJO tiene columnas hasta [2028].
            const int maxAnioCartera = 2027;
            if (anio > maxAnioCartera)
            {
                return BadRequest($"El año de consulta ({anio}) excede el límite del subinforme Cartera Diferida (máx. {maxAnioCartera}).");
            }

            var datos = await _informeMercadosDGService.ObtenerInformeMercadosDGAsync(anio, mes);
            return Ok(datos);
        }
    }
}
