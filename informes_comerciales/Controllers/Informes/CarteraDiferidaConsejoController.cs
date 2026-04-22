using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Models.Informes.CarteraDiferidaConsejo;
using Elecnor_Informes_Comerciales.Services.Informes;
using System;
using System.Threading.Tasks;

namespace Elecnor_Informes_Comerciales.Controllers.Informes
{
    /// <summary>
    /// Endpoint para el informe de Cartera Diferida (CONSEJO ELECNOR).
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    [ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any)]
    public class CarteraDiferidaConsejoController : ControllerBase
    {
        private readonly InformeCarteraDiferidaConsejoService _service;

        public CarteraDiferidaConsejoController(InformeCarteraDiferidaConsejoService service)
        {
            _service = service;
        }

        /// <summary>
        /// Obtiene el informe estructurado por años y mercados para renderizado en frontend.
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> Get([FromQuery] int anio, [FromQuery] int mes, [FromQuery] int? nroPagina)
        {
            if (anio > DateTime.Now.Year) return BadRequest("El año de consulta no puede ser superior al año actual.");
            if (mes < 1 || mes > 12) return BadRequest("Mes inválido.");

            // La tabla CarteraDiferida_CJO tiene columnas de proyección hasta [2028].
            // El subinforme Cartera Diferida necesita [anio-1], [anio] y [anio+1].
            // Para anio=2027: necesita [2026], [2027], [2028] → todas existen.
            // Para anio=2028: necesitaría [2029] → no existe.
            const int maxAnioCarteraDiferida = 2027;
            if (anio > maxAnioCarteraDiferida)
            {
                return BadRequest($"El año de consulta ({anio}) excede el límite del subinforme Cartera Diferida (máx. {maxAnioCarteraDiferida}).");
            }

            var resultado = await _service.ObtenerInformeAsync(anio, mes, nroPagina);
            return Ok(resultado);
        }
    }
}
