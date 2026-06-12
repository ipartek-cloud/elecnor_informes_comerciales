using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionDetallePaises;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe Cartera Contratación Países (Detalle) Nacional - Internacional.
/// </summary>
public class InformeCarteraContratacionDetallePaisesService
{
    private readonly InformeRepository _repository;

    public InformeCarteraContratacionDetallePaisesService(InformeRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Obtiene el informe de Cartera Contratación Detalle Países.
    /// </summary>
    public async Task<CarteraContratacionDetallePaisesResponseDto> ObtenerInformeAsync(
        int anio, int mes, int? nroPagina, decimal limiteImporte, int limitePaises, string mercado, string informe, string loginUsuario)
    {
        int todoInternacional = mercado.Equals("Todo", StringComparison.OrdinalIgnoreCase) ? 1 : 0;
        string sufijoMercado = mercado.Equals("Internacional", StringComparison.OrdinalIgnoreCase) ? " Internacional" : "";

        // Ejecutar consultas en paralelo para minimizar latencia
        var tDatos = _repository.ObtenerCarteraContratacionDetallePaisesAsync(anio, mes, todoInternacional, limiteImporte, limitePaises, informe, loginUsuario);
        var tTotalGeneral = _repository.ObtenerTotalCarteraGeneralAsync(anio, mes, todoInternacional);

        await Task.WhenAll(tDatos, tTotalGeneral);

        var datosPlanos = await tDatos;
        var totalGeneral = await tTotalGeneral;

        var response = new CarteraContratacionDetallePaisesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = $"Cartera Contratación Países (Detalle){sufijoMercado}",
                Descripcion = "CONSEJO ELECNOR - Informe de Contratación",
                Filtros = new
                {
                    Anio = anio,
                    Mes = mes,
                    Mercado = mercado,
                    LimiteImporte = limiteImporte,
                    LimitePaises = limitePaises
                },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema",
                NroPagina = nroPagina
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // ═══════════════════════════════════════════════════════════════════════
        // ORDENAMIENTO: EXCLUSIVAMENTE EN SERVICE (NUNCA EN SQL).
        // Criterio principal: ImporteCarteraPais DESC.
        // Criterio secundario: ImporteCarteraOferta DESC (paridad con ORDER BY del subinforme Access).
        // ═══════════════════════════════════════════════════════════════════════
        var datosOrdenados = datosPlanos
            .OrderByDescending(x => x.ImporteCarteraPais ?? 0)
            .ThenByDescending(x => x.ImporteCarteraOferta ?? 0)
            .ToList();

        // Agrupación jerárquica: Año -> País -> Detalle
        var agrupaciones = datosOrdenados
            .GroupBy(x => x.AnioInforme)
            .Select(gAnio => new CarteraContratacionDetallePaisesAgrupadoDto
            {
                AnioInforme = gAnio.Key,
                Paises = gAnio
                    .GroupBy(x => x.Pais)
                    .OrderByDescending(g => g.First().ImporteCarteraPais ?? 0)
                    .Select(gPais => new CarteraContratacionDetallePaisesPaisDto
                    {
                        NombrePais = gPais.Key,
                        ImporteCarteraPais = gPais.First().ImporteCarteraPais,
                        ImporteCarteraPaisAñoAnterior = gPais.First().ImporteCarteraPaisAñoAnterior,
                        Detalles = gPais
                            .Where(d => (d.ImporteCarteraOferta ?? 0) + (d.ImporteContratadoOferta ?? 0) != 0)
                            .Select(d => new CarteraContratacionDetallePaisesDetalleDto
                            {
                                NomCliente = d.NomCliente,
                                DesOferta = d.DesOferta,
                                ImporteCarteraOferta = d.ImporteCarteraOferta,
                                ImporteContratadoOferta = d.ImporteContratadoOferta,
                                ImporteCarteraOfertaAñoAnterior = d.ImporteCarteraOfertaAñoAnterior,
                                ImporteTotalOferta = (d.ImporteCarteraOferta ?? 0) + (d.ImporteContratadoOferta ?? 0)
                            }).ToList()
                    }).ToList()
            }).ToList();

        response.Agrupaciones = agrupaciones;

        // Totales: sumar los valores únicos por País (no sumar duplicados por cada oferta)
        var totalesPorPais = datosOrdenados
            .GroupBy(x => x.Pais)
            .Select(g => new
            {
                ImporteActual = g.First().ImporteCarteraPais ?? 0,
                ImporteAnterior = g.First().ImporteCarteraPaisAñoAnterior ?? 0
            })
            .ToList();

        response.Totales = new CarteraContratacionDetallePaisesTotalesDto
        {
            SumaCarteraPais = totalesPorPais.Sum(x => x.ImporteActual),
            SumaCarteraPaisAñoAnterior = totalesPorPais.Sum(x => x.ImporteAnterior),
            TotalCarteraGeneral = totalGeneral
        };

        return response;
    }
}
