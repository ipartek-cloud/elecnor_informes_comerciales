using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.GerenciasNacionalInternacional;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

public class InformeGerenciasNacionalInternacionalService
{
    private readonly InformeRepository _informeRepository;

    public InformeGerenciasNacionalInternacionalService(InformeRepository informeRepository)
    {
        _informeRepository = informeRepository;
    }

    public async Task<GerenciasNacionalInternacionalResponseDto> ObtenerInformeAsync(
        int anio, int mes, int? nroPagina, string loginUsuario)
    {
        _mesActual = mes;

        var datos = await _informeRepository
            .ObtenerGerenciasNacionalInternacionalAsync(anio, mes, loginUsuario);

        var datosValidos = datos
            .Where(r => r.ImporteContratado != 0
                     || r.ImporteContratadoAcumulado != 0
                     || r.ImporteContratadoAcumuladoAñoAnterior != 0
                     || r.Objetivos != 0)
            .ToList();

        var nacional = datosValidos.Where(r => r.Mercado == "N").ToList();
        var internacional = datosValidos.Where(r => r.Mercado == "I").ToList();
        var total = datosValidos
            .Where(r => r.Mercado == "N" || r.Mercado == "I")
            .GroupBy(r => new { r.Año, r.SumarizaGerentes, r.Actividad, r.Orden })
            .Select(g => new GerenciasNacionalInternacionalPoco
            {
                Año = g.Key.Año,
                SumarizaGerentes = g.Key.SumarizaGerentes,
                Actividad = g.Key.Actividad,
                Orden = g.Key.Orden,
                Mercado = "T",
                ImporteContratado = g.Sum(r => r.ImporteContratado),
                ImporteContratadoAcumulado = g.Sum(r => r.ImporteContratadoAcumulado),
                ImporteContratadoAcumuladoAñoAnterior = g.Sum(r => r.ImporteContratadoAcumuladoAñoAnterior),
                Objetivos = g.Sum(r => r.Objetivos),
                CarteraPdteAñoActual = g.Sum(r => r.CarteraPdteAñoActual),
                CarteraPdteAñoAnterior = g.Sum(r => r.CarteraPdteAñoAnterior)
            })
            .ToList();

        var response = new GerenciasNacionalInternacionalResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Informe de Contratación",
                Descripcion = "Contratación, objetivos y cartera por gerencia con desglose nacional/internacional",
                Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina },
                FechaGeneracion = DateTime.Now,
                Usuario = loginUsuario,
                NroPagina = nroPagina,
                MostrarNumeroPagina = true,
                MostrarTitulo = true
            }
        };

        response.Total = ConstruirBloque(
            total,
            "S.G. Instalaciones y Redes",
            "Gerencias",
            "Gerencia");

        response.Nacional = ConstruirBloque(
            nacional,
            "Elecnor Infraestructuras",
            "Gerencia Nacional",
            "Gerencia Nacional");

        response.Internacional = ConstruirBloque(
            internacional,
            "Elecnor Infraestructuras",
            "Gerencia Internacional",
            "Gerencia Internacional");

        return response;
    }

    private BloqueGerenciasDto ConstruirBloque(
        List<GerenciasNacionalInternacionalPoco> datos,
        string linea1,
        string linea2,
        string tituloBadge)
    {
        var bloque = new BloqueGerenciasDto
        {
            TituloBloque = tituloBadge,
            SubtituloBloque = $"{linea1} / {linea2}",
            Linea1 = linea1,
            Linea2 = linea2
        };

        if (datos == null || !datos.Any())
            return bloque;

        // Las filas ya vienen sumadas por (SumarizaGerentes, NombreGerente) desde SQL.
        // Se ordenan por Orden (del grupo) y luego por la actividad.
        var filasOrdenadas = datos
            .OrderBy(d => d.SumarizaGerentes)
            .ThenBy(d => d.Orden)
            .ThenBy(d => d.Actividad)
            .ToList();

        var grupos = filasOrdenadas
            .GroupBy(d => d.SumarizaGerentes)
            .Select(g =>
            {
                var gerencias = g.Select(CrearGerenciaItem).ToList();
                return new GrupoGerenciasDto
                {
                    NombreGrupo = g.Key,
                    Gerencias = gerencias,
                    Subtotal = CalcularTotales(gerencias)
                };
            })
            .ToList();

        bloque.Grupos = grupos;
        bloque.TotalBloque = CalcularTotales(grupos.SelectMany(g => g.Gerencias).ToList());

        return bloque;
    }

    private GerenciaItemDto CrearGerenciaItem(GerenciasNacionalInternacionalPoco poco)
    {
        var item = new GerenciaItemDto
        {
            Actividad = poco.Actividad,
            Orden = int.TryParse(poco.Orden?.Trim(), out var orden) ? orden : 0,
            SumarizaGerentes = poco.SumarizaGerentes,

            ObjetivoMensual = Math.Truncate(poco.Objetivos / 12m),
            ContratacionMensual = Math.Round(poco.ImporteContratado / 1000m, 2, MidpointRounding.AwayFromZero),
            ObjetivoAnual = Math.Round(poco.Objetivos, 2, MidpointRounding.AwayFromZero),
            ContratacionAcumulada = Math.Round(poco.ImporteContratadoAcumulado / 1000m, 2, MidpointRounding.AwayFromZero),
            AnoAnterior = Math.Round(poco.ImporteContratadoAcumuladoAñoAnterior / 1000m, 2, MidpointRounding.AwayFromZero),
            CarteraPdteAñoActual = Math.Round(poco.CarteraPdteAñoActual / 1000m, 2, MidpointRounding.AwayFromZero),
            CarteraPdteAñoAnterior = Math.Round(poco.CarteraPdteAñoAnterior / 1000m, 2, MidpointRounding.AwayFromZero)
        };

        item.IndiceProduccion = InformeCalculosUtils.CalcularIp(
            item.ContratacionAcumulada,
            item.ObjetivoAnual / 12m,
            _mesActual);

        item.VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(
            item.AnoAnterior,
            item.ContratacionAcumulada);

        item.VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(
            item.CarteraPdteAñoAnterior,
            item.CarteraPdteAñoActual);

        return item;
    }

    private int _mesActual;

    private TotalesEstandarDto CalcularTotales(List<GerenciaItemDto> items)
    {
        if (!items.Any())
            return new TotalesEstandarDto();

        var totalObjMensual = items.Sum(g => g.ObjetivoMensual);
        var totalContrMensual = items.Sum(g => g.ContratacionMensual);
        var totalObjAnual = items.Sum(g => g.ObjetivoAnual);
        var totalContrAcum = items.Sum(g => g.ContratacionAcumulada);
        var totalAnoAnt = items.Sum(g => g.AnoAnterior);
        var totalCartAct = items.Sum(g => g.CarteraPdteAñoActual);
        var totalCartAnt = items.Sum(g => g.CarteraPdteAñoAnterior);

        return new TotalesEstandarDto
        {
            ObjetivoMensual = Math.Round(totalObjMensual, 2, MidpointRounding.AwayFromZero),
            ContratacionMensual = Math.Round(totalContrMensual, 2, MidpointRounding.AwayFromZero),
            ObjetivoAnual = Math.Round(totalObjAnual, 2, MidpointRounding.AwayFromZero),
            ContratacionAcumulada = Math.Round(totalContrAcum, 2, MidpointRounding.AwayFromZero),
            IndiceProduccion = InformeCalculosUtils.CalcularIp(totalContrAcum, totalObjAnual / 12m, _mesActual),
            VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(totalAnoAnt, totalContrAcum),
            VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(totalCartAnt, totalCartAct)
        };
    }
}
