using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.MercadosSGDelegaciones;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

public class InformeMercadosSGDelegacionesService
{
    private readonly InformeRepository _repository;
    private const string CodSdgOrdenDel = "090";

    public InformeMercadosSGDelegacionesService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task<MercadosSGDelegacionesResponseDto> ObtenerInformeAsync(int anio, int mes, string codSubDirGeneral = "221")
    {
        var datosPlanos = await _repository.ObtenerMercadosSGDelegacionesAsync(
            anio, mes, codSubDirGeneral, CodSdgOrdenDel);

        var response = new MercadosSGDelegacionesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "S.G. Delegaciones x Mercados",
                Descripcion = "Direccion General - Informe de Contratacion por Delegaciones",
                Filtros = new { Anio = anio, Mes = mes },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema"
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        var datosOrdenados = datosPlanos
            .OrderBy(x => x.OrdenSubDirGeneral)
            .ThenBy(x => x.Orden_CodDDirNegocio.GetValueOrDefault(999))
            .ThenByDescending(x => x.Objetivos)
            .ThenBy(x => x.NombreDelegacion)
            .ToList();

        var sdgs = datosOrdenados
            .GroupBy(x => new { x.NombreSubDirGeneral, x.OrdenSubDirGeneral })
            .Select(g => new
            {
                g.Key.NombreSubDirGeneral,
                g.Key.OrdenSubDirGeneral,
                DireccionesNegocio = g
                    .GroupBy(x => new { x.NomDirNegocio, x.Orden_CodDDirNegocio })
                    .Select(dng => new
                    {
                        dng.Key.NomDirNegocio,
                        dng.Key.Orden_CodDDirNegocio,
                        Areas = dng
                            .GroupBy(x => x.Area)
                            .Select(a => new { Area = a.Key, Delegaciones = a.ToList() })
                            .ToList()
                    })
                    .ToList()
            })
            .ToList();

        foreach (var sdg in sdgs)
        {
            var sdgDto = new SubDirGeneralDto
            {
                NombreSubDirGeneral = sdg.NombreSubDirGeneral,
                OrdenSubDirGeneral = sdg.OrdenSubDirGeneral
            };

            foreach (var dn in sdg.DireccionesNegocio)
            {
                var dnDto = new DirNegocioDto
                {
                    NombreDirNegocio = dn.NomDirNegocio,
                    Orden_CodDDirNegocio = dn.Orden_CodDDirNegocio
                };

                var pocosDelDN = datosOrdenados.Where(p => p.NomDirNegocio == dn.NomDirNegocio).ToList();

                foreach (var area in dn.Areas)
                {
                    var areaDto = new AreaDto { Area = area.Area };

                    foreach (var delegacion in area.Delegaciones)
                    {
                        if (delegacion.ImporteContratadoAcumulado == 0
                            && delegacion.ImporteContratadoAcumuladoAñoAnterior == 0
                            && delegacion.Objetivos == 0)
                            continue;

                        areaDto.Delegaciones.Add(ConstruirDelegacionDto(delegacion, mes));
                    }

                    if (areaDto.Delegaciones.Count > 0)
                        dnDto.Areas.Add(areaDto);
                }

                dnDto.Totales = CalcularTotalesDN(dnDto, pocosDelDN, mes);
                sdgDto.DireccionesNegocio.Add(dnDto);
            }

            sdgDto.Totales = CalcularTotalesSDG(sdgDto, mes);
            response.SubDireccionesGenerales.Add(sdgDto);
        }

        return response;
    }

    private DelegacionDto ConstruirDelegacionDto(MercadoSGDelegacionPoco poco, int mes)
    {
        var objetivosMensual = poco.Objetivos / 12m;
        var ip = InformeCalculosUtils.CalcularIp(poco.ImporteContratadoAcumulado / 1000m, objetivosMensual, mes);

        return new DelegacionDto
        {
            NombreDelegacion = poco.NombreDelegacion,
            CodDelegacion = poco.CodDelegacion,
            Mensual = new MetricasMensualesDto
            {
                Objetivos = Math.Round(objetivosMensual, 0, MidpointRounding.AwayFromZero),
                Contratacion = Math.Round(poco.ImporteContratado / 1000m, 0, MidpointRounding.AwayFromZero)
            },
            Acumulado = new MetricasAcumuladasDto
            {
                Objetivos = Math.Round(poco.Objetivos, 0, MidpointRounding.AwayFromZero),
                Contratacion = Math.Round(poco.ImporteContratadoAcumulado, 0, MidpointRounding.AwayFromZero),
                IP = Math.Round(ip, 2, MidpointRounding.AwayFromZero)
            },
            Variaciones = new VariacionesDto
            {
                Contratacion = InformeCalculosUtils.CalcularVariacionContratacion(
                    poco.ImporteContratadoAcumuladoAñoAnterior, poco.ImporteContratadoAcumulado),
                Cartera = InformeCalculosUtils.CalcularVariacionCartera(
                    poco.CarteraPdteAñoAnterior, poco.CarteraPdteAñoActual)
            }
        };
    }

    private TotalesDNDto CalcularTotalesDN(DirNegocioDto dn, List<MercadoSGDelegacionPoco> pocosOriginales, int mes)
    {
        var todos = dn.Areas.SelectMany(a => a.Delegaciones).ToList();
        if (!todos.Any())
            return new TotalesDNDto();

        var objAcum = todos.Sum(d => d.Acumulado.Objetivos);
        var contrAcum = todos.Sum(d => d.Acumulado.Contratacion);
        var ip = CalcularIpDesdeTotales(contrAcum, objAcum, mes);

        return new TotalesDNDto
        {
            ObjetivosMensual = Math.Round(todos.Sum(d => d.Mensual.Objetivos), 0, MidpointRounding.AwayFromZero),
            ContratacionMensual = Math.Round(todos.Sum(d => d.Mensual.Contratacion), 0, MidpointRounding.AwayFromZero),
            ObjetivosAcumulado = Math.Round(objAcum, 0, MidpointRounding.AwayFromZero),
            ContratacionAcumulado = Math.Round(contrAcum, 0, MidpointRounding.AwayFromZero),
            IP = Math.Round(ip, 2, MidpointRounding.AwayFromZero),
            VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(
                pocosOriginales.Sum(p => p.ImporteContratadoAcumuladoAñoAnterior), contrAcum),
            VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(
                pocosOriginales.Sum(p => p.CarteraPdteAñoAnterior), pocosOriginales.Sum(p => p.CarteraPdteAñoActual)),
            Resumen = new ResumenNacionalInternacionalDto
            {
                ObjetivosMensualNacional = Math.Round(pocosOriginales.Sum(p => p.ObjetivosNacional) / 12m, 0, MidpointRounding.AwayFromZero),
                ContratacionMensualNacional = Math.Round(pocosOriginales.Sum(p => p.ImporteContratadoNacional) / 1000m, 0, MidpointRounding.AwayFromZero),
                ObjetivosAcumuladoNacional = Math.Round(pocosOriginales.Sum(p => p.ObjetivosNacional), 0, MidpointRounding.AwayFromZero),
                ContratacionAcumuladoNacional = Math.Round(pocosOriginales.Sum(p => p.ImporteContratadoAcumuladoNacional), 0, MidpointRounding.AwayFromZero),
                IpNacional = Math.Round(CalcularIpDesdeTotales(pocosOriginales.Sum(p => p.ImporteContratadoAcumuladoNacional), pocosOriginales.Sum(p => p.ObjetivosNacional), mes), 2, MidpointRounding.AwayFromZero),

                ObjetivosMensualInternacional = Math.Round(pocosOriginales.Sum(p => p.ObjetivosInternacional) / 12m, 0, MidpointRounding.AwayFromZero),
                ContratacionMensualInternacional = Math.Round(pocosOriginales.Sum(p => p.ImporteContratadoInternacional) / 1000m, 0, MidpointRounding.AwayFromZero),
                ObjetivosAcumuladoInternacional = Math.Round(pocosOriginales.Sum(p => p.ObjetivosInternacional), 0, MidpointRounding.AwayFromZero),
                ContratacionAcumuladoInternacional = Math.Round(pocosOriginales.Sum(p => p.ImporteContratadoAcumuladoInternacional), 0, MidpointRounding.AwayFromZero),
                IpInternacional = Math.Round(CalcularIpDesdeTotales(pocosOriginales.Sum(p => p.ImporteContratadoAcumuladoInternacional), pocosOriginales.Sum(p => p.ObjetivosInternacional), mes), 2, MidpointRounding.AwayFromZero)
            }
        };
    }

    private TotalesSDGDto CalcularTotalesSDG(SubDirGeneralDto sdg, int mes)
    {
        var todas = sdg.DireccionesNegocio.SelectMany(d => d.Areas).SelectMany(a => a.Delegaciones).ToList();
        if (!todas.Any())
            return new TotalesSDGDto();

        var objAcum = todas.Sum(d => d.Acumulado.Objetivos);
        var contrAcum = todas.Sum(d => d.Acumulado.Contratacion);

        return new TotalesSDGDto
        {
            ObjetivosMensual = Math.Round(todas.Sum(d => d.Mensual.Objetivos), 0, MidpointRounding.AwayFromZero),
            ContratacionMensual = Math.Round(todas.Sum(d => d.Mensual.Contratacion), 0, MidpointRounding.AwayFromZero),
            ObjetivosAcumulado = Math.Round(objAcum, 0, MidpointRounding.AwayFromZero),
            ContratacionAcumulado = Math.Round(contrAcum, 0, MidpointRounding.AwayFromZero),
            IP = Math.Round(CalcularIpDesdeTotales(contrAcum, objAcum, mes), 2, MidpointRounding.AwayFromZero),
            VariacionContratacion = "-",
            VariacionCartera = "-"
        };
    }

    private static decimal CalcularIpDesdeTotales(decimal acumulador, decimal objetivosAnuales, int mes)
    {
        if (objetivosAnuales == 0 || mes == 0) return 0;
        return (acumulador / 1000m) / ((objetivosAnuales / 12m) * mes);
    }
}
