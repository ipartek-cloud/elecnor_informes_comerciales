using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

public class OpcionesGeneracionService
{
    private readonly InformeRepository _repository;

    public OpcionesGeneracionService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task SincronizarOfertasAsync(int anio, int mes)
        => await _repository.EjecutarSPSincronizarOfertasAsync(anio, mes);

    public async Task SincronizarClientesAsync()
        => await _repository.EjecutarSPSincronizarClientesAsync();

    public async Task SincronizarSumarigramaAsync()
        => await _repository.EjecutarSPSincronizarSumarigramaAsync();

    public async Task SincronizarObrasAsync(int anio, int mes)
        => await _repository.EjecutarSPSincronizarObrasAsync(anio, mes);
}
