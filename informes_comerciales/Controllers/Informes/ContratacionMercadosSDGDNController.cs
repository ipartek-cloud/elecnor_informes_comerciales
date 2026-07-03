using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.Services.Informes;
using Elecnor_Informes_Comerciales.Models.Informes.ContratacionMercadosSDGDN;

namespace Elecnor_Informes_Comerciales.Controllers.Informes
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class ContratacionMercadosSDGDNController : ControllerBase
    {
        private readonly InformeContratacionMercadosSDGDNService _service;

        public ContratacionMercadosSDGDNController(
            InformeContratacionMercadosSDGDNService service)
        {
            _service = service;
        }

        [HttpGet]
        [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any,
            VaryByHeader = "Authorization",
            VaryByQueryKeys = new[] { "anio", "mes", "subdireccion" })]
        public async Task<ActionResult<ContratacionMercadosSDGDNResponseDto>> Get(
            [FromQuery] int anio,
            [FromQuery] int mes,
            [FromQuery] string? subdireccion = null)
        {
            if (anio > DateTime.Now.Year)
                return BadRequest("El año de consulta no puede ser superior al año actual.");
            if (anio < 2000)
                return BadRequest("El año de consulta debe ser posterior a 2000.");
            if (mes < 1 || mes > 12)
                return BadRequest("Mes inválido. Debe estar entre 1 y 12.");

            var loginUsuario = User.Identity?.Name ?? "ANONIMO";
            var datos = await _service.ObtenerInformeAsync(anio, mes, loginUsuario, subdireccion);
            return Ok(datos);
        }
    }
}
