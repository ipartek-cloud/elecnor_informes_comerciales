using Elecnor_Informes_Comerciales.Models.Informes.Gerencias_Totales_Cruces;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe Gerencias Totales Cruces.
/// Orquesta la agrupación jerárquica y los cálculos de negocio.
/// </summary>
public class InformeGerenciasTotalesCrucesService
{
    private readonly InformeRepository _repository;

    public InformeGerenciasTotalesCrucesService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task<GerenciasTotalesCrucesDto> ObtenerInformeAsync(int anio, int mes)
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
                    Filtros = new { Anio = anio, Mes = mes },
                    FechaGeneracion = DateTime.Now,
                    Usuario = "Sistema"
                },
                Gerentes = new List<GerenteSeccionDto>(),
                PieTotal = new TotalesSeccionDto()
            };
        }

        var response = new GerenciasTotalesCrucesDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Gerencias Totales Cruces",
                Descripcion = "Informe de Contratación por Gerencias",
                Filtros = new { Anio = anio, Mes = mes },
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
                                Ip = CalcularIp(c.ImporteContratadoAcumuladoS / 1000, c.Objetivos / 12, mes),
                                VariacionContratacion = fnContratacion(c.ImporteContratadoAcumuladoAñoAnteriorS / 1000, c.ImporteContratadoAcumuladoS / 1000),
                                VariacionCartera = fnCartera(c.CarteraPdteAñoAnteriorS, c.CarteraPdteAñoActualS)
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

    private TotalesSeccionDto CalcularTotales(IEnumerable<GerenciasTotalesCrucesPoco> datos, int mes)
    {
        var lista = datos.ToList();
        
        if (!lista.Any())
        {
            return new TotalesSeccionDto();
        }
        
        var totalObjAnual = lista.Sum(x => x.Objetivos);
        var totalContrActual = lista.Sum(x => x.ImporteContratadoAcumuladoS) / 1000;
        var totalContrAnterior = lista.Sum(x => x.ImporteContratadoAcumuladoAñoAnteriorS) / 1000;
        
        var totalCartActual = lista.Sum(x => x.CarteraPdteAñoActualS);
        var totalCartAnterior = lista.Sum(x => x.CarteraPdteAñoAnteriorS);

        return new TotalesSeccionDto
        {
            TotalObjetivoMensual = Math.Round(totalObjAnual / 12, 2, MidpointRounding.AwayFromZero),
            TotalContratacionMensual = Math.Round(lista.Sum(x => x.ImporteContratadoS) / 1000, 2, MidpointRounding.AwayFromZero),
            TotalObjetivoAcumulado = Math.Round(totalObjAnual, 2, MidpointRounding.AwayFromZero),
            TotalContratacionAcumulada = Math.Round(totalContrActual, 2, MidpointRounding.AwayFromZero),
            IpMedia = CalcularIp(totalContrActual, totalObjAnual / 12, mes),
            VariacionContratacion = fnContratacion(totalContrAnterior, totalContrActual),
            VariacionCartera = fnCartera(totalCartAnterior, totalCartActual)
        };
    }

    private decimal CalcularIp(decimal contrAcum, decimal objetivoMensualCalculado, int mes)
    {
        if (objetivoMensualCalculado == 0 || mes == 0) return 0;
        decimal resultado = contrAcum / (objetivoMensualCalculado * mes);
        return Math.Round(resultado, 2, MidpointRounding.AwayFromZero);
    }

    private string fnContratacion(decimal acumuladoAnterior, decimal acumuladoActual)
    {
        if (acumuladoAnterior == 0) return "-";
        decimal vContr = (acumuladoActual - acumuladoAnterior) / acumuladoAnterior;
        if (vContr > 10 || acumuladoAnterior < 0) return ">1000%";
        if (vContr < -10) return "<-1000%";
        return $"{(vContr * 100):N0}%";
    }

    private string fnCartera(decimal acumuladoAnterior, decimal acumuladoActual)
    {
        if (acumuladoAnterior == 0) return "-";
        decimal vCart = (acumuladoActual - acumuladoAnterior) / acumuladoAnterior;
        if (vCart > 10 || acumuladoAnterior < 0) return "-*%";
        if (vCart < -10) return "<-100%";
        return $"{(vCart * 100):N0}%";
    }
}
