using Elecnor_Informes_Comerciales.DTOs.Informes;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para carga de catálogos y datos auxiliares.
/// </summary>
public class CatalogoService
{
    private readonly InformeRepository _repository;

    public CatalogoService(InformeRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Obtiene las SubDirecciones Generales ordenadas.
    /// </summary>
    public async Task<List<SubDireccionGeneralDto>> ObtenerSubDireccionesAsync()
    {
        return await _repository.ObtenerSubDireccionesAsync();
    }
}
