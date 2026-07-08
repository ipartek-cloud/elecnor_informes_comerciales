using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.DGCentros;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

public class CD_Elecnor_DG_Centros_DGRI_NuevoService
{
    private readonly InformeRepository _repository;

    public CD_Elecnor_DG_Centros_DGRI_NuevoService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task<DGCentrosResponseDto> ObtenerInformeAsync(int anio, int mes, int? nroPagina, string loginUsuario, string? codSubDirGeneral = null)
    {
        var datosPlanos = await _repository.ObtenerDGCentrosDGRINuevoAsync(anio, mes, loginUsuario, codSubDirGeneral);

        var response = new DGCentrosResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "DG - Unidades Negocio - Delegaciones - Centros",
                Descripcion = "Direccion General - Informe de Contratacion por Centros",
                Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina },
                FechaGeneracion = DateTime.Now,
                Usuario = loginUsuario,
                NroPagina = nroPagina
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // Ordenamos los datos planos antes de agrupar para preservar el orden lógico
        var datosOrdenados = datosPlanos
            .OrderBy(x => x.OrdenSubDirGeneral)
            .ThenBy(x => x.Orden_CodDDirNegocio.GetValueOrDefault(999))
            .ThenBy(x => x.NombreDelegacion)
            .ToList();

        // Agrupación en memoria usando LINQ
        var sdgs = datosOrdenados
            .GroupBy(x => new { x.NombreSubDirGeneral, x.CodSubDirGeneral, x.OrdenSubDirGeneral })
            .OrderBy(g => g.Key.OrdenSubDirGeneral)
            .Select(g => new
            {
                g.Key.NombreSubDirGeneral,
                g.Key.CodSubDirGeneral,
                g.Key.OrdenSubDirGeneral,
                DireccionesNegocio = g
                    .GroupBy(x => new { x.NomDirNegocio, x.Orden_CodDDirNegocio })
                    .OrderBy(dng => dng.Key.Orden_CodDDirNegocio.GetValueOrDefault(999))
                    .ThenBy(dng => dng.Key.NomDirNegocio)
                    .Select(dng => new
                    {
                        dng.Key.NomDirNegocio,
                        dng.Key.Orden_CodDDirNegocio,
                        Delegaciones = dng
                            .GroupBy(x => new { x.CodDelegacion, x.NombreDelegacion })
                            .OrderBy(delg => delg.Key.NombreDelegacion)
                            .Select(delg => new
                            {
                                delg.Key.CodDelegacion,
                                delg.Key.NombreDelegacion,
                                Pocos = delg.ToList()
                            })
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
                CodSubDirGeneral = sdg.CodSubDirGeneral,
                OrdenSubDirGeneral = sdg.OrdenSubDirGeneral
            };

            foreach (var dn in sdg.DireccionesNegocio)
            {
                var dnDto = new DirNegocioDto
                {
                    NombreDirNegocio = dn.NomDirNegocio,
                    Orden_CodDDirNegocio = dn.Orden_CodDDirNegocio
                };

                var pocosDelDN = datosPlanos.Where(p => p.NomDirNegocio == dn.NomDirNegocio).ToList();

                foreach (var del in dn.Delegaciones)
                {
                    // Aplicar fgSustituye([NombreDelegacion]; "DELEG."; "") de Access (insensible a mayúsculas y soportando "Deleg" y "Deleg.")
                    var nombreDelegacionLimpio = del.NombreDelegacion ?? string.Empty;
                    nombreDelegacionLimpio = System.Text.RegularExpressions.Regex.Replace(
                        nombreDelegacionLimpio, 
                        @"(?i)deleg\.?", 
                        ""
                    ).Trim();

                    var delDto = new DelegacionDto
                    {
                        NombreDelegacion = nombreDelegacionLimpio,
                        CodDelegacion = del.CodDelegacion
                    };

                    // Agrupamos los pocos de la delegación por Centro (para consolidar Nacional e Internacional en un único CentroDto)
                    var centrosAgrupados = del.Pocos
                        .GroupBy(x => new { x.CodCentro, x.NombreCentro })
                        .Select(cg => new
                        {
                            cg.Key.CodCentro,
                            cg.Key.NombreCentro,
                            ImporteContratado = cg.Sum(x => x.ImporteContratado),
                            ImporteContratadoAcumulado = cg.Sum(x => x.ImporteContratadoAcumulado),
                            ImporteContratadoAcumuladoAñoAnterior = cg.Sum(x => x.ImporteContratadoAcumuladoAñoAnterior),
                            Objetivos = cg.Sum(x => x.Objetivos),
                            CarteraPdteAñoActual = cg.Sum(x => x.CarteraPdteAñoActual),
                            CarteraPdteAñoAnterior = cg.Sum(x => x.CarteraPdteAñoAnterior)
                        })
                        .OrderByDescending(x => x.Objetivos) // Ordenar por Objetivos de mayor a menor (detalle del informe)
                        .ToList();

                    foreach (var ct in centrosAgrupados)
                    {
                        // Filtramos centros sin actividad relevante
                        if (ct.ImporteContratado == 0 
                            && ct.ImporteContratadoAcumulado == 0 
                            && ct.ImporteContratadoAcumuladoAñoAnterior == 0 
                            && ct.Objetivos == 0)
                            continue;

                        var objMensual = ct.Objetivos / 12m;
                        var ip = InformeCalculosUtils.CalcularIp(ct.ImporteContratadoAcumulado / 1000m, objMensual, mes);

                        var ctDto = new CentroDto
                        {
                            NombreCentro = ct.NombreCentro,
                            CodCentro = ct.CodCentro,
                            Mensual = new MetricasMensualesDto
                            {
                                Objetivos = Math.Round(objMensual, 0, MidpointRounding.AwayFromZero),
                                Contratacion = Math.Round(ct.ImporteContratado / 1000m, 0, MidpointRounding.AwayFromZero)
                            },
                            Acumulado = new MetricasAcumuladasDto
                            {
                                Objetivos = Math.Round(ct.Objetivos, 0, MidpointRounding.AwayFromZero),
                                Contratacion = Math.Round(ct.ImporteContratadoAcumulado / 1000m, 0, MidpointRounding.AwayFromZero),
                                IP = Math.Round(ip, 2, MidpointRounding.AwayFromZero)
                            },
                            Variaciones = new VariacionesDto
                            {
                                Contratacion = InformeCalculosUtils.CalcularVariacionContratacion(
                                    ct.ImporteContratadoAcumuladoAñoAnterior, ct.ImporteContratadoAcumulado),
                                Cartera = InformeCalculosUtils.CalcularVariacionCartera(
                                    ct.CarteraPdteAñoAnterior, ct.CarteraPdteAñoActual)
                            }
                        };

                        delDto.Centros.Add(ctDto);
                    }

                    // Si la delegación tiene centros activos, calculamos sus subtotales y los agregamos
                    if (delDto.Centros.Count > 0)
                    {
                        delDto.Totales = CalcularTotalesDelegacion(delDto, del.Pocos, mes, anio);
                        dnDto.Delegaciones.Add(delDto);
                    }
                }

                if (dnDto.Delegaciones.Count > 0)
                {
                    dnDto.Totales = CalcularTotalesDN(dnDto, pocosDelDN, mes);
                    sdgDto.DireccionesNegocio.Add(dnDto);
                }
            }

            if (sdgDto.DireccionesNegocio.Count > 0)
            {
                sdgDto.Totales = CalcularTotalesSDG(sdgDto, mes);
                response.SubDireccionesGenerales.Add(sdgDto);
            }
        }

        return response;
    }

    private TotalesDelegacionDto CalcularTotalesDelegacion(DelegacionDto del, List<DGCentrosPoco> pocos, int mes, int anio)
    {
        var objAcum = del.Centros.Sum(c => c.Acumulado.Objetivos);
        var contrAcum = del.Centros.Sum(c => c.Acumulado.Contratacion);
        var ip = CalcularIpDesdeTotales(contrAcum, objAcum, mes);

        // Sumas de variaciones
        var contrAntSuma = pocos.Sum(p => p.ImporteContratadoAcumuladoAñoAnterior);
        var contrActSuma = pocos.Sum(p => p.ImporteContratadoAcumulado);
        var cartAntSuma = pocos.Sum(p => p.CarteraPdteAñoAnterior);
        var cartActSuma = pocos.Sum(p => p.CarteraPdteAñoActual);

        // Resumen Nacional/Internacional
        var pocosNacional = pocos.Where(p => p.Pais == "Nacional").ToList();
        var pocosInternacional = pocos.Where(p => p.Pais == "Internacional").ToList();

        var objAcumNac = pocosNacional.Sum(p => p.Objetivos);
        var contrAcumNac = pocosNacional.Sum(p => p.ImporteContratadoAcumulado) / 1000m;
        var ipNac = CalcularIpDesdeTotales(contrAcumNac, objAcumNac, mes);

        var objAcumInt = pocosInternacional.Sum(p => p.Objetivos);
        var contrAcumInt = pocosInternacional.Sum(p => p.ImporteContratadoAcumulado) / 1000m;
        var ipInt = CalcularIpDesdeTotales(contrAcumInt, objAcumInt, mes);

        return new TotalesDelegacionDto
        {
            ObjetivosMensual = Math.Round(del.Centros.Sum(c => c.Mensual.Objetivos), 0, MidpointRounding.AwayFromZero),
            ContratacionMensual = Math.Round(del.Centros.Sum(c => c.Mensual.Contratacion), 0, MidpointRounding.AwayFromZero),
            ObjetivosAcumulado = Math.Round(objAcum, 0, MidpointRounding.AwayFromZero),
            ContratacionAcumulado = Math.Round(contrAcum, 0, MidpointRounding.AwayFromZero),
            IP = Math.Round(ip, 2, MidpointRounding.AwayFromZero),
            VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(contrAntSuma, contrActSuma),
            VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(cartAntSuma, cartActSuma),
            Resumen = new ResumenNacionalInternacionalDto
            {
                ObjetivosMensualNacional = Math.Round(pocosNacional.Sum(p => p.Objetivos) / 12m, 0, MidpointRounding.AwayFromZero),
                ContratacionMensualNacional = Math.Round(pocosNacional.Sum(p => p.ImporteContratado) / 1000m, 0, MidpointRounding.AwayFromZero),
                ObjetivosAcumuladoNacional = Math.Round(objAcumNac, 0, MidpointRounding.AwayFromZero),
                ContratacionAcumuladoNacional = Math.Round(contrAcumNac, 0, MidpointRounding.AwayFromZero),
                IpNacional = Math.Round(ipNac, 2, MidpointRounding.AwayFromZero),

                ObjetivosMensualInternacional = Math.Round(pocosInternacional.Sum(p => p.Objetivos) / 12m, 0, MidpointRounding.AwayFromZero),
                ContratacionMensualInternacional = Math.Round(pocosInternacional.Sum(p => p.ImporteContratado) / 1000m, 0, MidpointRounding.AwayFromZero),
                ObjetivosAcumuladoInternacional = Math.Round(objAcumInt, 0, MidpointRounding.AwayFromZero),
                ContratacionAcumuladoInternacional = Math.Round(contrAcumInt, 0, MidpointRounding.AwayFromZero),
                IpInternacional = Math.Round(ipInt, 2, MidpointRounding.AwayFromZero)
            }
        };
    }

    private TotalesDNDto CalcularTotalesDN(DirNegocioDto dn, List<DGCentrosPoco> pocos, int mes)
    {
        var todosLosCentros = dn.Delegaciones.SelectMany(d => d.Centros).ToList();

        var objAcum = todosLosCentros.Sum(c => c.Acumulado.Objetivos);
        var contrAcum = todosLosCentros.Sum(c => c.Acumulado.Contratacion);
        var ip = CalcularIpDesdeTotales(contrAcum, objAcum, mes);

        var contrAntSuma = pocos.Sum(p => p.ImporteContratadoAcumuladoAñoAnterior);
        var contrActSuma = pocos.Sum(p => p.ImporteContratadoAcumulado);
        var cartAntSuma = pocos.Sum(p => p.CarteraPdteAñoAnterior);
        var cartActSuma = pocos.Sum(p => p.CarteraPdteAñoActual);

        // Resumen Nacional/Internacional a nivel DN
        var pocosNacional = pocos.Where(p => p.Pais == "Nacional").ToList();
        var pocosInternacional = pocos.Where(p => p.Pais == "Internacional").ToList();

        var objAcumNac = pocosNacional.Sum(p => p.Objetivos);
        var contrAcumNac = pocosNacional.Sum(p => p.ImporteContratadoAcumulado) / 1000m;
        var ipNac = CalcularIpDesdeTotales(contrAcumNac, objAcumNac, mes);

        var objAcumInt = pocosInternacional.Sum(p => p.Objetivos);
        var contrAcumInt = pocosInternacional.Sum(p => p.ImporteContratadoAcumulado) / 1000m;
        var ipInt = CalcularIpDesdeTotales(contrAcumInt, objAcumInt, mes);

        return new TotalesDNDto
        {
            ObjetivosMensual = Math.Round(todosLosCentros.Sum(c => c.Mensual.Objetivos), 0, MidpointRounding.AwayFromZero),
            ContratacionMensual = Math.Round(todosLosCentros.Sum(c => c.Mensual.Contratacion), 0, MidpointRounding.AwayFromZero),
            ObjetivosAcumulado = Math.Round(objAcum, 0, MidpointRounding.AwayFromZero),
            ContratacionAcumulado = Math.Round(contrAcum, 0, MidpointRounding.AwayFromZero),
            IP = Math.Round(ip, 2, MidpointRounding.AwayFromZero),
            VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(contrAntSuma, contrActSuma),
            VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(cartAntSuma, cartActSuma),
            Resumen = new ResumenNacionalInternacionalDto
            {
                ObjetivosMensualNacional = Math.Round(pocosNacional.Sum(p => p.Objetivos) / 12m, 0, MidpointRounding.AwayFromZero),
                ContratacionMensualNacional = Math.Round(pocosNacional.Sum(p => p.ImporteContratado) / 1000m, 0, MidpointRounding.AwayFromZero),
                ObjetivosAcumuladoNacional = Math.Round(objAcumNac, 0, MidpointRounding.AwayFromZero),
                ContratacionAcumuladoNacional = Math.Round(contrAcumNac, 0, MidpointRounding.AwayFromZero),
                IpNacional = Math.Round(ipNac, 2, MidpointRounding.AwayFromZero),

                ObjetivosMensualInternacional = Math.Round(pocosInternacional.Sum(p => p.Objetivos) / 12m, 0, MidpointRounding.AwayFromZero),
                ContratacionMensualInternacional = Math.Round(pocosInternacional.Sum(p => p.ImporteContratado) / 1000m, 0, MidpointRounding.AwayFromZero),
                ObjetivosAcumuladoInternacional = Math.Round(objAcumInt, 0, MidpointRounding.AwayFromZero),
                ContratacionAcumuladoInternacional = Math.Round(contrAcumInt, 0, MidpointRounding.AwayFromZero),
                IpInternacional = Math.Round(ipInt, 2, MidpointRounding.AwayFromZero)
            }
        };
    }

    private TotalesSDGDto CalcularTotalesSDG(SubDirGeneralDto sdg, int mes)
    {
        var todasLasDns = sdg.DireccionesNegocio.Select(d => d.Totales).ToList();

        var objAcum = todasLasDns.Sum(d => d.ObjetivosAcumulado);
        var contrAcum = todasLasDns.Sum(d => d.ContratacionAcumulado);
        var ip = CalcularIpDesdeTotales(contrAcum, objAcum, mes);

        return new TotalesSDGDto
        {
            ObjetivosMensual = Math.Round(todasLasDns.Sum(d => d.ObjetivosMensual), 0, MidpointRounding.AwayFromZero),
            ContratacionMensual = Math.Round(todasLasDns.Sum(d => d.ContratacionMensual), 0, MidpointRounding.AwayFromZero),
            ObjetivosAcumulado = Math.Round(objAcum, 0, MidpointRounding.AwayFromZero),
            ContratacionAcumulado = Math.Round(contrAcum, 0, MidpointRounding.AwayFromZero),
            IP = Math.Round(ip, 2, MidpointRounding.AwayFromZero),
            VariacionContratacion = "-",
            VariacionCartera = "-"
        };
    }

    private static decimal CalcularIpDesdeTotales(decimal contrAcumMiles, decimal objetivosAnualesUnidades, int mes)
    {
        if (objetivosAnualesUnidades == 0 || mes == 0) return 0;
        // contrAcumMiles ya está dividido por 1000 en la sumatoria, objetivosAnualesUnidades ya está en unidades (debe dividirse por 12 y multiplicarse por el mes)
        return contrAcumMiles / ((objetivosAnualesUnidades / 12m) * mes);
    }
}
