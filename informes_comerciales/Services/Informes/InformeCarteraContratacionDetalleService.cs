using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionDetalle;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe Cartera Contratación (Detalle) Nacional - Internacional.
/// </summary>
public class InformeCarteraContratacionDetalleService
{
    private readonly InformeRepository _repository;

    public InformeCarteraContratacionDetalleService(InformeRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Obtiene el informe de Cartera Contratación Detalle.
    /// </summary>
    public async Task<CarteraContratacionDetalleResponseDto> ObtenerInformeAsync(
        int anio, int mes, int? nroPagina, decimal limiteImporte, int limitePaises, string mercado, string informe)
    {
        int todoInternacional = mercado.Equals("Todo", StringComparison.OrdinalIgnoreCase) ? 1 : 0;

        // Ejecutar consultas en paralelo para minimizar latencia
        var tDatos = _repository.ObtenerCarteraContratacionDetalleAsync(
            anio, mes, todoInternacional, limiteImporte, limitePaises, informe);
        var tTotalGeneral = _repository.ObtenerTotalCarteraGeneralAsync(anio, mes);

        await Task.WhenAll(tDatos, tTotalGeneral);

        var datosPlanos = await tDatos;
        var totalGeneral = await tTotalGeneral;

        var response = new CarteraContratacionDetalleResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Cartera de Contratación (Detalle)",
                Descripcion = "CONSEJO ELECNOR - Informe de Contratación",
                Filtros = new { Anio = anio, Mes = mes, Mercado = mercado, LimiteImporte = limiteImporte, LimitePaises = limitePaises },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema",
                NroPagina = nroPagina
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // ═══════════════════════════════════════════════════════════════════════
        // ORDENAMIENTO: EXCLUSIVAMENTE EN SERVICE (NUNCA EN SQL).
        // Criterio: ImporteCarteraOferta DESC.
        // ═══════════════════════════════════════════════════════════════════════
        var datosOrdenados = datosPlanos
            .OrderByDescending(x => x.ImporteCarteraOferta ?? 0)
            .ThenBy(x => x.DesOferta)
            .ToList();

        // Agrupación por año (único nivel de agrupación del informe Access)
        var agrupaciones = datosOrdenados
            .GroupBy(x => x.AnioInforme)
            .Select(g => new CarteraContratacionDetalleAgrupadoDto
            {
                AnioInforme = g.Key,
                Detalles = g.Select(d => new CarteraContratacionDetalleItemDto
                {
                    DesOferta = d.DesOferta,
                    NomCliente = d.NomCliente,
                    ImporteCarteraOferta = d.ImporteCarteraOferta ?? 0,
                    ImporteContratadoOferta = d.ImporteContratadoOferta ?? 0
                }).ToList()
            })
            .ToList();

        response.Agrupaciones = agrupaciones;

        // Totales globales
        response.Totales = new CarteraContratacionTotalesDto
        {
            SumaCartera = datosOrdenados.Sum(x => x.ImporteCarteraOferta ?? 0),
            SumaTotal = datosOrdenados.Sum(x => (x.ImporteCarteraOferta ?? 0) + (x.ImporteContratadoOferta ?? 0)),
            TotalCarteraGeneral = totalGeneral
        };

        return response;
    }
}
