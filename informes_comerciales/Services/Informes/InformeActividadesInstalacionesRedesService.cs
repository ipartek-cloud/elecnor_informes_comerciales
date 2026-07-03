using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.ActividadesInstalacionesRedes;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>Servicio del informe "Actividades SDG". 3 secciones (DG, Nacional, Internacional) con sub-actividades reales.</summary>
public class InformeActividadesInstalacionesRedesService
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

    public InformeActividadesInstalacionesRedesService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task<ActividadesInstalacionesRedesResponseDto> ObtenerInformeAsync(
        int anio, int mes, string loginUsuario, string? subdireccion = null)
    {
        string subdir = string.IsNullOrWhiteSpace(subdireccion) ? "221" : subdireccion;

        var datosPlanos = await _repository.ObtenerSdgActividadesAsync(anio, mes, loginUsuario, subdir);

        var response = new ActividadesInstalacionesRedesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Actividades SDG",
                Descripcion = "Contratacion SDG desglosada por Actividad y Sub-actividad (DG / Nacional / Internacional).",
                Filtros = new { anio, mes, subdireccion = subdir },
                FechaGeneracion = DateTime.Now,
                Usuario = loginUsuario,
                MostrarNumeroPagina = true,
                MostrarTitulo = false
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        string dgBadge = string.Equals(subdir, "286") ? "D.G. Elecnor Proyectos" : "D.G. Elecnor Servicios";
        response.Secciones.Add(ConstruirSeccion(string.Empty, dgBadge, datosPlanos, mes));
        response.Secciones.Add(ConstruirSeccion("N", "Nacional",
            datosPlanos.Where(d => string.Equals(d.Mercado, "N", StringComparison.OrdinalIgnoreCase)).ToList(), mes));
        response.Secciones.Add(ConstruirSeccion("I", "Internacional",
            datosPlanos.Where(d => string.Equals(d.Mercado, "I", StringComparison.OrdinalIgnoreCase)).ToList(), mes));

        return response;
    }

    private static SeccionMercadoDto ConstruirSeccion(string mercadoCodigo, string badge,
        List<SdgActividadesPoco> filas, int mes)
    {
        var seccion = new SeccionMercadoDto
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
        decimal totalObjetivos = filas.Sum(f => f.Objetivos);

        seccion.TotalContrat          = Math.Round(totalContrat, 0, MidpointRounding.AwayFromZero);
        seccion.TotalContratAnterior  = Math.Round(totalContratAnt, 0, MidpointRounding.AwayFromZero);
        seccion.TotalObjetivos        = Math.Round(totalObjetivos, 0, MidpointRounding.AwayFromZero);
        seccion.Ip                    = InformeCalculosUtils.CalcularIp(totalContrat, totalObjetivos / 12m, mes);
        seccion.VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(totalContratAnt, totalContrat);

        return seccion;
    }

    private static ActividadBloqueDto ConstruirActividad(string agrupacionRaw, List<SdgActividadesPoco> filas, int mes)
    {
        string agrupacion = MapearAgrupacion(agrupacionRaw);

        var bloque = new ActividadBloqueDto
        {
            Orden     = filas.Min(f => f.Orden) ?? 99,
            Actividad = agrupacion
        };

        decimal totalContrat = filas.Sum(f => f.Contrat) / 1000m;
        decimal totalContratAnt = filas.Sum(f => f.Contrat_1) / 1000m;
        decimal totalObjetivos = filas.Sum(f => f.Objetivos);

        bloque.TotalContrat          = Math.Round(totalContrat, 0, MidpointRounding.AwayFromZero);
        bloque.TotalContratAnterior  = Math.Round(totalContratAnt, 0, MidpointRounding.AwayFromZero);
        bloque.TotalObjetivos        = Math.Round(totalObjetivos, 0, MidpointRounding.AwayFromZero);
        bloque.Ip                    = InformeCalculosUtils.CalcularIp(totalContrat, totalObjetivos / 12m, mes);
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
            decimal subObjetivos = filasSub.Sum(f => f.Objetivos);

            bloque.SubActividades.Add(new SubActividadBloqueDto
            {
                SubActividad           = sub,
                TotalContrat           = Math.Round(subContrat, 0, MidpointRounding.AwayFromZero),
                TotalContratAnterior   = Math.Round(subContratAnt, 0, MidpointRounding.AwayFromZero),
                TotalObjetivos         = Math.Round(subObjetivos, 0, MidpointRounding.AwayFromZero),
                Ip                     = InformeCalculosUtils.CalcularIp(subContrat, subObjetivos / 12m, mes),
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
