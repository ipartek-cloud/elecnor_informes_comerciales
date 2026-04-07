using Elecnor_Informes_Comerciales.Models.Informes.Gerencias_Totales_Cruces;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe Gerencias Totales Cruces.
/// Orquesta la agrupación jerárquica y los cálculos de negocio.
/// Usa InformeCalculosUtils para cálculos compartidos (DRY principle).
/// </summary>
public class InformeGerenciasTotalesCrucesService
{
    private readonly InformeRepository _repository;

    public InformeGerenciasTotalesCrucesService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task<GerenciasTotalesCrucesDto> ObtenerInformeAsync(int anio, int mes, int? nroPagina)
    {
        var datosPlanos = await _repository.ObtenerGerenciasTotalesCrucesAsync(anio, mes);

        // Validación de datos nulos o vacíos
        if (datosPlanos == null || !datosPlanos.Any())
        {
            return new GerenciasTotalesCrucesDto
            {
                Meta = new MetaInformeDto
                {
                    Titulo = "Gerencias Totales Cruces",
                    Descripcion = "Informe de Contratación por Gerencias",
                    Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina },
                    FechaGeneracion = DateTime.Now,
                    Usuario = "Sistema"
                },
                Gerentes = new List<GerenteSeccionDto>(),
                PieTotal = new TotalesEstandarDto()
            };
        }

        var response = new GerenciasTotalesCrucesDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Gerencias Totales Cruces",
                Descripcion = "Informe de Contratación por Gerencias",
                Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema" // En producción se obtendría del User claim
            },
            Gerentes = datosPlanos
                .GroupBy(p => new { p.Orden, p.NombreGerente })
                .OrderBy(g => g.Key.Orden)
                .ThenBy(g => g.Key.NombreGerente)
                .Select(gGerente => new GerenteSeccionDto
                {
                    NombreGerente = gGerente.Key.NombreGerente,
                    DireccionesNegocio = gGerente
                        .GroupBy(p => new { p.Orden_CodDDirNegocio, p.NombreDirNegocio })
                        .OrderBy(gDN => {
                            // Intentamos ordenar numéricamente si es posible
                            return int.TryParse(gDN.Key.Orden_CodDDirNegocio, out int o) ? o : 999999;
                        })
                        .ThenBy(gDN => gDN.Key.NombreDirNegocio)
                        .Select(gDN => new DireccionNegocioDto
                        {
                            NombreDirNegocio = gDN.Key.NombreDirNegocio.Replace("DIR. ", ""),
                            NotaAclaratoriaDG = gDN.Any(p => p.CodDDirNegocio == 800) ? "(*) Incluye 20.000 de internacional" : string.Empty,
                            Centros = gDN
                                .OrderByDescending(c => c.Objetivos)
                                .ThenBy(c => c.NombreCentro)
                                .Select(c => new GerenciaCentroDetalleDto
                            {
                                CodCentro = c.CodCentro,
                                NombreCentro = c.NombreCentro,
                                ObjetivosMensual = Math.Round(c.Objetivos / 12, 2, MidpointRounding.AwayFromZero),
                                ContratacionMensual = Math.Round(c.ImporteContratadoS / 1000, 2, MidpointRounding.AwayFromZero),
                                ObjetivosAcumulado = Math.Round(c.Objetivos, 2, MidpointRounding.AwayFromZero),
                                ContratacionAcumulada = Math.Round(c.ImporteContratadoAcumuladoS / 1000, 2, MidpointRounding.AwayFromZero),
                                Ip = InformeCalculosUtils.CalcularIp(c.ImporteContratadoAcumuladoS / 1000, c.Objetivos / 12, mes),
                                VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(c.ImporteContratadoAcumuladoAñoAnteriorS / 1000, c.ImporteContratadoAcumuladoS / 1000),
                                VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(c.CarteraPdteAñoAnteriorS, c.CarteraPdteAñoActualS)
                            }).ToList(),
                            TotalesDireccion = CalcularTotales(gDN, mes)
                        })
                        .ToList(),
                    TotalesGerente = CalcularTotales(gGerente, mes)
                })
                .ToList(),
            PieTotal = CalcularTotales(datosPlanos, mes)
        };

        return response;
    }

    /// <summary>
    /// Calcula totales para un grupo de datos.
    /// Retorna TotalesEstandarDto para homogeneizar el payload JSON.
    /// </summary>
    private TotalesEstandarDto CalcularTotales(IEnumerable<GerenciasTotalesCrucesPoco> datos, int mes)
    {
        var lista = datos.ToList();

        if (!lista.Any()) return new TotalesEstandarDto();

        var totalObjAnual = lista.Sum(x => x.Objetivos);
        var totalContrActual = lista.Sum(x => x.ImporteContratadoAcumuladoS) / 1000;
        var totalContrAnterior = lista.Sum(x => x.ImporteContratadoAcumuladoAñoAnteriorS) / 1000;

        var totalCartActual = lista.Sum(x => x.CarteraPdteAñoActualS);
        var totalCartAnterior = lista.Sum(x => x.CarteraPdteAñoAnteriorS);

        return new TotalesEstandarDto
        {
            ObjetivoMensual = Math.Round(totalObjAnual / 12, 2, MidpointRounding.AwayFromZero),
            ContratacionMensual = Math.Round(lista.Sum(x => x.ImporteContratadoS) / 1000, 2, MidpointRounding.AwayFromZero),
            ObjetivoAnual = Math.Round(totalObjAnual, 2, MidpointRounding.AwayFromZero),
            ContratacionAcumulada = Math.Round(totalContrActual, 2, MidpointRounding.AwayFromZero),
            IndiceProduccion = InformeCalculosUtils.CalcularIp(totalContrActual, totalObjAnual / 12, mes),
            VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(totalContrAnterior, totalContrActual),
            VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(totalCartAnterior, totalCartActual)
        };
    }
}
