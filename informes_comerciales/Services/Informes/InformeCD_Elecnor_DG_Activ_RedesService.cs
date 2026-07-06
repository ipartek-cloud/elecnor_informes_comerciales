using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.CD_Elecnor_DG_Activ_Redes;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>Servicio del informe "Actividades x DN". Sin Objetivos ni IP. Filtrado por CodDirNegocio.</summary>
public class InformeCD_Elecnor_DG_Activ_RedesService
{
    private static readonly HashSet<string> SubActividadLabels = new(StringComparer.OrdinalIgnoreCase)
    {
        "Telecomunicaciones", "Sistemas"
    };

    private static readonly Dictionary<string, string> ActividadLabelMap = new(StringComparer.OrdinalIgnoreCase)
    {
        { "Telecomunic y Sistemas", "Telecomunicaciones y Sistemas" }
    };

    private static readonly Dictionary<string, string> EncodingFixMap = new(StringComparer.Ordinal)
    {
        { "Generaci\uFFFDn de Energ\uFFFDa", "Generación de Energía" },
        { "Parques E\uFFFDlicos", "Parques Eólicos" },
        { "Construcci\uFFFDn y Agua", "Construcción y Agua" },
        { "Medio Ambiente y Carreteras", "Medio Ambiente y Carreteras" }
    };

    private readonly InformeRepository _repository;

    public InformeCD_Elecnor_DG_Activ_RedesService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task<CD_Elecnor_DG_Activ_RedesResponseDto> ObtenerInformeAsync(
        int anio, int mes, string loginUsuario, string? subdireccion = null, string? codDirNegocio = null)
    {
        string subdir = string.IsNullOrWhiteSpace(subdireccion) ? "221" : subdireccion;

        var datosPlanos = await _repository.ObtenerSdgActividadesDNAsync(anio, mes, loginUsuario, subdir, codDirNegocio);

        var response = new CD_Elecnor_DG_Activ_RedesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Actividades x DN",
                Descripcion = "Contratacion SDG desglosada por Actividad y Sub-actividad, filtrada por Direccion de Negocio.",
                Filtros = new { anio, mes, subdireccion = subdir, codDirNegocio },
                FechaGeneracion = DateTime.Now,
                Usuario = loginUsuario,
                MostrarNumeroPagina = true,
                MostrarTitulo = false
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // Obtener descripción del CodDirNegocio de la primera fila
        string nombreDirNegocio = datosPlanos.First().NombreDirNegocio ?? string.Empty;

        // Sección principal (DG) siempre visible
        response.Secciones.Add(ConstruirSeccion(string.Empty, nombreDirNegocio, datosPlanos, mes));

        // Subinformes solo si tienen datos
        var filasNacional = datosPlanos.Where(d => string.Equals(d.Mercado, "N", StringComparison.OrdinalIgnoreCase)).ToList();
        if (filasNacional.Any())
        {
            response.Secciones.Add(ConstruirSeccion("N", "Nacional", filasNacional, mes));
        }

        var filasInternacional = datosPlanos.Where(d => string.Equals(d.Mercado, "I", StringComparison.OrdinalIgnoreCase)).ToList();
        if (filasInternacional.Any())
        {
            response.Secciones.Add(ConstruirSeccion("I", "Internacional", filasInternacional, mes));
        }

        return response;
    }

    private static SeccionMercadoDNDto ConstruirSeccion(string mercadoCodigo, string badge,
        List<SdgActividadesDNPoco> filas, int mes)
    {
        var seccion = new SeccionMercadoDNDto
        {
            Mercado = mercadoCodigo,
            MercadoBadge = badge
        };

        if (filas.Count == 0)
        {
            seccion.VariacionContratacion = "-";
            return seccion;
        }

        var filasOrdenadas = filas
            .OrderBy(d => d.Orden ?? 99)
            .ThenBy(d => MapearAgrupacion(d.Agrupacion) ?? string.Empty)
            .ThenBy(d => ResolverSubActividadLabel(d.ACT1))
            .ToList();

        foreach (var grupo in filasOrdenadas.GroupBy(d => (d.Agrupacion ?? string.Empty).Trim()))
        {
            seccion.Actividades.Add(ConstruirActividad(grupo.Key, grupo.ToList(), mes));
        }

        decimal totalContrat = filas.Sum(f => f.Contrat) / 1000m;
        decimal totalContratAnt = filas.Sum(f => f.Contrat_1) / 1000m;

        seccion.TotalContrat          = Math.Round(totalContrat, 0, MidpointRounding.AwayFromZero);
        seccion.TotalContratAnterior  = Math.Round(totalContratAnt, 0, MidpointRounding.AwayFromZero);
        seccion.VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(totalContratAnt, totalContrat);

        return seccion;
    }

    private static ActividadBloqueDNDto ConstruirActividad(string agrupacionRaw, List<SdgActividadesDNPoco> filas, int mes)
    {
        string agrupacion = MapearAgrupacion(agrupacionRaw);

        var bloque = new ActividadBloqueDNDto
        {
            Orden     = filas.Min(f => f.Orden) ?? 99,
            Actividad = agrupacion
        };

        decimal totalContrat = filas.Sum(f => f.Contrat) / 1000m;
        decimal totalContratAnt = filas.Sum(f => f.Contrat_1) / 1000m;

        bloque.TotalContrat          = Math.Round(totalContrat, 0, MidpointRounding.AwayFromZero);
        bloque.TotalContratAnterior  = Math.Round(totalContratAnt, 0, MidpointRounding.AwayFromZero);
        bloque.VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(totalContratAnt, totalContrat);

        var subActividades = filas
            .Where(f => !string.IsNullOrWhiteSpace(f.ACT1))
            .Select(f => f.ACT1.Trim())
            .Distinct()
            .OrderBy(c => c)
            .Select(ResolverSubActividadLabel)
            .Where(s => !string.IsNullOrWhiteSpace(s) && SubActividadLabels.Contains(s))
            .ToList();

        foreach (var sub in subActividades)
        {
            var filasSub = filas
                .Where(f => string.Equals(ResolverSubActividadLabel(f.ACT1), sub, StringComparison.OrdinalIgnoreCase))
                .ToList();

            decimal subContrat = filasSub.Sum(f => f.Contrat) / 1000m;
            decimal subContratAnt = filasSub.Sum(f => f.Contrat_1) / 1000m;

            bloque.SubActividades.Add(new SubActividadBloqueDNDto
            {
                SubActividad           = sub,
                TotalContrat           = Math.Round(subContrat, 0, MidpointRounding.AwayFromZero),
                TotalContratAnterior   = Math.Round(subContratAnt, 0, MidpointRounding.AwayFromZero),
                VariacionContratacion  = InformeCalculosUtils.CalcularVariacionContratacion(subContratAnt, subContrat)
            });
        }

        return bloque;
    }

    private static string MapearAgrupacion(string? agrupacion)
    {
        if (string.IsNullOrWhiteSpace(agrupacion)) return string.Empty;
        var key = agrupacion.Trim();
        if (EncodingFixMap.TryGetValue(key, out var fixedEnc)) return fixedEnc;
        return ActividadLabelMap.TryGetValue(key, out var mapped) ? mapped : key;
    }

    private static string ResolverSubActividadLabel(string? act1)
    {
        if (string.IsNullOrWhiteSpace(act1)) return string.Empty;
        var key = act1.Trim();
        return key switch
        {
            "07" => "Telecomunicaciones",
            "08" => "Sistemas",
            _ => key
        };
    }
}
