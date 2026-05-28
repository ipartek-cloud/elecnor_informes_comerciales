using Elecnor_Informes_Comerciales.DTOs.Informes.ContratacionesAI;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe de Contrataciones AI (Asociadas a Inversión).
/// </summary>
public class InformeContratacionesAIService
{
    private readonly InformeRepository _repository;

    public InformeContratacionesAIService(InformeRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Obtiene el informe completo de Contrataciones AI incluyendo subinforme acumulado.
    /// </summary>
    public async Task<ContratacionesAIResponseDto> ObtenerInformeCompletoAsync(int anio, int mes, decimal? umbral1 = null, decimal? umbral2 = null)
    {
        // Umbrales específicos según análisis técnico (con valores por defecto)
        decimal u1 = umbral1 ?? 300; // > 0,3M
        decimal u2 = umbral2 ?? 700;  // > 0,7M

        // Ejecutar consultas en paralelo para optimizar rendimiento
        var taskPrincipal = _repository.ObtenerContratacionesAIAsync(anio, mes, u1);
        var taskAnterior = _repository.ObtenerContratacionesAnnoAIAnteriorAsync(anio, mes, u2);

        await Task.WhenAll(taskPrincipal, taskAnterior);

        var datosPlanos = await taskPrincipal;
        var datosAnteriorPlanos = await taskAnterior;

        var response = new ContratacionesAIResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Principales Contrataciones del Año",
                SubTitulo = "Contratos",
                Descripcion = "CONSEJO ELECNOR - Contrataciones Asociadas a Inversión",
                Filtros = new { Anio = anio, Mes = mes, Umbral1 = u1, Umbral2 = u2 },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema"
            }
        };

        // 1. Procesar Datos Principales (Mes actual)
        if (datosPlanos != null && datosPlanos.Any())
        {
            response.Datos = datosPlanos
                .OrderByDescending(x => x.ImporteContratado_OK)
                .Select(MapearADetalle)
                .ToList();
        }

        // 2. Procesar Datos Subinforme (Meses anteriores acumulados)
        if (datosAnteriorPlanos != null && datosAnteriorPlanos.Any())
        {
            response.DatosAnterior = datosAnteriorPlanos
                .OrderByDescending(x => x.ImporteContratado_OK)
                .Select(MapearADetalle)
                .ToList();
        }

        return response;
    }

    /// <summary>
    /// Helper para mapear POCO a DTO de detalle.
    /// </summary>
    private static ContratacionesAIDetalleDto MapearADetalle(Elecnor_Informes_Comerciales.Models.Informes.ContratacionesAI.ContratacionesAIPoco x)
    {
        return new ContratacionesAIDetalleDto
        {
            Anio = x.Año,
            Mercado = x.Paises,
            Mes = x.Meses,
            Descripcion = x.DescripcionOfertas_OK,
            Cliente = x.NombreClientes_OK,
            Importe = x.ImporteContratado_OK
        };
    }

    /// <summary>
    /// Ejecuta la generación de datos AI (si el checkbox está marcado).
    /// </summary>
    public async Task GenerarDatosAIAsync(int anio, int mes)
    {
        await _repository.EjecutarSPObrasAIAsync(anio, mes);
    }
}
