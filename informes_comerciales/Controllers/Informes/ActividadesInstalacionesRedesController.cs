using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.Services.Informes;
using Elecnor_Informes_Comerciales.Models.Informes.ActividadesInstalacionesRedes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes
{
    /// <summary>API REST del informe "Actividades SDG". RLS aplicada en el SP.</summary>
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class ActividadesInstalacionesRedesController : ControllerBase
    {
        private readonly InformeActividadesInstalacionesRedesService _service;

        public ActividadesInstalacionesRedesController(
            InformeActividadesInstalacionesRedesService service)
        {
            _service = service;
        }

        [HttpGet]
        [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any,
            VaryByHeader = "Authorization",
            VaryByQueryKeys = new[] { "anio", "mes", "subdireccion" })]
        public async Task<ActionResult<ActividadesInstalacionesRedesResponseDto>> Get(
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
