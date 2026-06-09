using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.Services.Informes;
using Elecnor_Informes_Comerciales.Models.Informes.Mercados;

namespace Elecnor_Informes_Comerciales.Controllers.Informes
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class MercadosController : ControllerBase
    {
        private readonly InformeMercadosService _informeMercadosService;

        public MercadosController(InformeMercadosService informeMercadosService)
        {
            _informeMercadosService = informeMercadosService;
        }

        [HttpGet]
        [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByHeader = "Authorization")]
        public async Task<ActionResult<MercadosResponseDto>> Get([FromQuery] int anio, [FromQuery] int mes, [FromQuery] int nroPagina = 1)
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

            if (nroPagina < 1)
            {
                nroPagina = 1;
            }

            var loginUsuario = User.Identity?.Name ?? "ANONIMO";
            var datos = await _informeMercadosService.ObtenerInformeMercadosAsync(anio, mes, nroPagina, loginUsuario);
            return Ok(datos);
        }
    }
}
