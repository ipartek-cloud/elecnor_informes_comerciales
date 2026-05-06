using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionDetalleOrgPaises;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe Cartera Contratación DG (Detalle) Organización Países.
/// </summary>
public class InformeCarteraContratacionDetalleOrgPaisesService
{
    private readonly InformeRepository _repository;

    public InformeCarteraContratacionDetalleOrgPaisesService(InformeRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Obtiene el informe de Cartera Contratación Detalle Organización Países.
    /// </summary>
    public async Task<CarteraContratacionDetalleOrgPaisesResponseDto> ObtenerInformeAsync(
        int anio, int mes, int? nroPagina, decimal limiteImporte, int limitePaises, string mercado, string informe, string? codSubDirGeneral)
    {
        int todoInternacional = mercado.Equals("Todo", StringComparison.OrdinalIgnoreCase) ? 1 : 0;

        // Ejecutar consultas en paralelo para minimizar latencia
        var tDatos = _repository.ObtenerCarteraContratacionDetalleOrgPaisesAsync(anio, mes, todoInternacional, limiteImporte, limitePaises, informe);
        var tTotalGeneral = _repository.ObtenerTotalCarteraGeneralAsync(anio, mes, todoInternacional);

        await Task.WhenAll(tDatos, tTotalGeneral);

        var datosPlanos = await tDatos;
        var totalGeneral = await tTotalGeneral;

        var response = new CarteraContratacionDetalleOrgPaisesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = $"Cartera Contratación DG {(codSubDirGeneral == "286" ? "Proyectos" : "Servicios")} (Detalle)",
                Descripcion = "CONSEJO ELECNOR - Informe de Contratación",
                Filtros = new { Anio = anio, Mes = mes, Mercado = mercado, LimiteImporte = limiteImporte, LimitePaises = limitePaises, CodSubDirGeneral = codSubDirGeneral },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema",
                NroPagina = nroPagina
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // ═══════════════════════════════════════════════════════════════════════
        // FILTRO POST-QUERY: CodSubDirGeneral (286=Proyectos, 221=Servicios)
        // El SP 8.1 no filtra por CodSubDirGeneral; lo hacemos aquí.
        // ═══════════════════════════════════════════════════════════════════════
        var datosFiltrados = string.IsNullOrEmpty(codSubDirGeneral)
            ? datosPlanos
            : datosPlanos.Where(x => x.CodSubDirGeneral == codSubDirGeneral).ToList();

        // ══════════════════════════════════════════════════════════════════════
        // ORDENAMIENTO: EXCLUSIVAMENTE EN SERVICE.
        // Criterio: NombreDirNegocio ASC (alfabético), luego ImporteCarteraPais DESC, luego ImporteCarteraOferta DESC.
        // ═══════════════════════════════════════════════════════════════════════
        var datosOrdenados = datosFiltrados
            .OrderBy(x => x.NombreDirNegocio)
            .ThenByDescending(x => x.ImporteCarteraPais ?? 0)
            .ThenByDescending(x => x.ImporteCarteraOferta ?? 0)
            .ToList();

        // Agrupación jerárquica: Año -> DN -> País -> Detalle
        var agrupaciones = datosOrdenados
            .GroupBy(x => x.AnioInforme)
            .Select(gAnio => new CarteraContratacionDetalleOrgPaisesAgrupadoDto
            {
                AnioInforme = gAnio.Key,
                DireccionesNegocio = gAnio
                    .GroupBy(x => x.NombreDirNegocio)
                    .OrderBy(g => g.Key)
                    .Select(gDn => new CarteraContratacionDetalleOrgPaisesDNDto
                    {
                        NombreDirNegocio = gDn.Key,
                        CodDDirNegocio = gDn.First().CodDDirNegocio,
                        ImporteCarteraDN = gDn.First().ImporteCarteraDN,
                        ImporteCarteraDNAñoAnterior = gDn.First().ImporteCarteraDNAñoAnterior,
                        Paises = gDn
                            .GroupBy(x => x.Pais)
                            .OrderByDescending(g => g.First().ImporteCarteraPais ?? 0)
                            .Select(gPais => new CarteraContratacionDetalleOrgPaisesPaisDto
                            {
                                NombrePais = gPais.Key,
                                ImporteCarteraPais = gPais.First().ImporteCarteraPais,
                                ImporteCarteraPaisAñoAnterior = gPais.First().ImporteCarteraPaisAñoAnterior,
                                Detalles = gPais
                                    .OrderByDescending(d => d.ImporteCarteraOferta ?? 0)
                                    .Select(d => new CarteraContratacionDetalleOrgPaisesDetalleDto
                                    {
                                        NomCliente = d.NomCliente,
                                        DesOferta = d.DesOferta,
                                        ImporteCarteraOferta = d.ImporteCarteraOferta,
                                        ImporteContratadoOferta = d.ImporteContratadoOferta,
                                        ImporteCarteraOfertaAñoAnterior = d.ImporteCarteraOfertaAñoAnterior
                                    }).ToList()
                            }).ToList()
                    }).ToList()
            }).ToList();

        response.Agrupaciones = agrupaciones;

        // ══════════════════════════════════════════════════════════════════════
        // TOTALES GLOBALES: Suma de lo que se muestra en el informe (detalles visibles).
        // Importante: No sumar ImporteCarteraPais/DN de datosFiltrados porque se repite por fila.
        // ══════════════════════════════════════════════════════════════════════
        response.Totales = new CarteraContratacionDetalleOrgPaisesTotalesDto
        {
            SumaCarteraPais = datosFiltrados.Sum(x => x.ImporteCarteraOferta ?? 0),
            SumaCarteraPaisAñoAnterior = datosFiltrados.Sum(x => x.ImporteCarteraOfertaAñoAnterior ?? 0),
            TotalCarteraGeneral = (totalGeneral ?? 0) / 1000
        };

        return response;
    }
}
