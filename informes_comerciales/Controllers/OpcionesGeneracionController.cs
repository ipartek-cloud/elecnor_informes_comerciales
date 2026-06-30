using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Elecnor_Informes_Comerciales.Services.Informes;

namespace Elecnor_Informes_Comerciales.Controllers.Informes;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class OpcionesGeneracionController : ControllerBase
{
    private readonly OpcionesGeneracionService _service;

    public OpcionesGeneracionController(OpcionesGeneracionService service)
    {
        _service = service;
    }

    [HttpPost("sincronizar-ofertas")]
    public async Task<IActionResult> SincronizarOfertas([FromBody] SincronizarConAnioMes request)
    {
        await _service.SincronizarOfertasAsync(request.Anio, request.Mes);
        return Ok();
    }

    [HttpPost("sincronizar-clientes")]
    public async Task<IActionResult> SincronizarClientes()
    {
        await _service.SincronizarClientesAsync();
        return Ok();
    }

    [HttpPost("sincronizar-sumarigrama")]
    public async Task<IActionResult> SincronizarSumarigrama()
    {
        await _service.SincronizarSumarigramaAsync();
        return Ok();
    }

    [HttpPost("sincronizar-obras")]
    public async Task<IActionResult> SincronizarObras([FromBody] SincronizarConAnioMes request)
    {
        await _service.SincronizarObrasAsync(request.Anio, request.Mes);
        return Ok();
    }
}

public class SincronizarConAnioMes
{
    public int Anio { get; set; }
    public int Mes { get; set; }
}
