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
        int anio, int mes, int? nroPagina, decimal limiteImporte, int limitePaises, string mercado, string informe, string? codSubDirGeneral, string loginUsuario)
    {
        int todoInternacional = mercado.Equals("Todo", StringComparison.OrdinalIgnoreCase) ? 1 : 0;
        string sufijoMercado = mercado.Equals("Internacional", StringComparison.OrdinalIgnoreCase) ? " Internacional" : "";

        // Ejecutar consultas en paralelo para minimizar latencia
        var tDatos = _repository.ObtenerCarteraContratacionDetalleOrgPaisesAsync(anio, mes, todoInternacional, limiteImporte, limitePaises, informe, loginUsuario);
        var tTotalGeneral = _repository.ObtenerTotalCarteraGeneralAsync(anio, mes, todoInternacional);

        await Task.WhenAll(tDatos, tTotalGeneral);

        var datosPlanos = await tDatos;
        var totalGeneral = await tTotalGeneral;

        var response = new CarteraContratacionDetalleOrgPaisesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = $"Cartera Contratación DG {(codSubDirGeneral == "286" ? "Proyectos" : "Servicios")}{sufijoMercado} (Detalle)",
                Descripcion = "CONSEJO ELECNOR - Informe de Contratación",
                Filtros = new { Anio = anio, Mes = mes, Mercado = mercado, LimiteImporte = limiteImporte, LimitePaises = limitePaises, CodSubDirGeneral = codSubDirGeneral },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema",
                NroPagina = nroPagina
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // Filtro post-query por Dirección General (286=Proyectos, 221=Servicios)
        var datosFiltrados = string.IsNullOrEmpty(codSubDirGeneral)
            ? datosPlanos
            : datosPlanos.Where(x => x.CodSubDirGeneral == codSubDirGeneral).ToList();

        // Ordenación: DN alfabético, Importe País DESC, Importe Oferta DESC
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

        // Totales: Suma de los totales únicos por Dirección de Negocio (DN) para paridad de totales con Access
        var totalesPorDN = datosFiltrados
            .GroupBy(x => x.CodDDirNegocio)
            .Select(g => new 
            { 
                ImporteActual = g.First().ImporteCarteraDN ?? 0,
                ImporteAnterior = g.First().ImporteCarteraDNAñoAnterior ?? 0
            })
            .ToList();

        response.Totales = new CarteraContratacionDetalleOrgPaisesTotalesDto
        {
            SumaCarteraPais = totalesPorDN.Sum(x => x.ImporteActual),
            SumaCarteraPaisAñoAnterior = totalesPorDN.Sum(x => x.ImporteAnterior),
            TotalCarteraGeneral = totalGeneral
        };

        return response;
    }
}
