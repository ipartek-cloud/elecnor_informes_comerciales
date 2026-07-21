using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.GerenciasActividad;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio del informe "Gerencias Actividad" (Gerente × Mercado × DN × Centro).
/// Benchmarks:
///   - InformeGerenciasTotalesCrucesService.cs (mismo SP, mismo POCO base).
///   - InformeGerenciasNacionalInternacionalService.cs (cálculo de IP/Variaciones).
/// Reutiliza: InformeCalculosUtils, TotalesEstandarDto.
/// Diferencia clave: nivel intermedio GrupoMercado (Nacional | Internacional) con TotalMercado.
/// </summary>
public class InformeGerenciasActividadService
{
    private readonly InformeRepository _repository;

    public InformeGerenciasActividadService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task<GerenciasActividadResponseDto> ObtenerInformeAsync(
        int anio, int mes, int? nroPagina, string loginUsuario, string nombreGerente)
    {
        if (string.IsNullOrWhiteSpace(nombreGerente))
            throw new ArgumentException("El parámetro nombreGerente es obligatorio.", nameof(nombreGerente));

        var datosPlanos = await _repository
            .ObtenerGerenciasActividadAsync(anio, mes, loginUsuario, nombreGerente);

        var response = new GerenciasActividadResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = $"Gerencias - {nombreGerente}",
                Descripcion = "Contratación, Objetivos y Cartera por Gerencia × Mercado × DN × Centro",
                Filtros = new { Anio = anio, Mes = mes, NombreGerente = nombreGerente },
                FechaGeneracion = DateTime.Now,
                Usuario = loginUsuario,
                NroPagina = nroPagina,
                MostrarNumeroPagina = nroPagina.HasValue,
                MostrarTitulo = false
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
        {
            response.TotalGeneral = new TotalesEstandarDto();
            return response;
        }

        // Excluir filas con todos los importes en 0 (benchmark: InformeGerenciasNacionalInternacionalService:30-34)
        var datosValidos = datosPlanos
            .Where(r => r.ImporteContratado != 0
                     || r.ImporteContratadoAcumulado != 0
                     || r.ImporteContratadoAcumuladoAñoAnterior != 0
                     || r.Objetivos != 0
                     || r.CarteraPdteAñoActual != 0
                     || r.CarteraPdteAñoAnterior != 0)
            .ToList();

        // Orden jerárquico:
        //   1) NombreGerente (ASC) - normalmente solo 1
        //   2) Mercado (Nacional antes que Internacional, lógica custom)
        //   3) OrdenCodDDirNegocio (ASC) - jerarquía visual
        //   4) Objetivos (DESC) - centros más importantes primero
        //   5) NombreCentro (ASC)
        var datosOrdenados = datosValidos
            .OrderBy(d => d.NombreGerente ?? string.Empty)
            .ThenBy(d => d.Mercado == "Nacional" ? 0 : 1)
            .ThenBy(d => d.OrdenCodDDirNegocio ?? 0)
            .ThenByDescending(d => d.Objetivos)
            .ThenBy(d => d.NombreCentro ?? string.Empty)
            .ToList();

        // Agrupar: NombreGerente → Mercado → DN → Centro
        var gruposGerente = datosOrdenados
            .GroupBy(d => d.NombreGerente ?? string.Empty)
            .Select(gGer => new GrupoGerenteDto
            {
                NombreGerente = gGer.Key,
                GruposMercado = gGer
                    .GroupBy(d => d.Mercado ?? "Nacional")
                    .Select(gMer => new GrupoMercadoDto
                    {
                        Mercado = gMer.Key,
                        DireccionesNegocio = gMer
                            .GroupBy(d => new { d.CodDDirNegocio, d.NombreDirNegocio, d.OrdenCodDDirNegocio })
                            .Select(gDN => new BloqueDireccionNegocioDto
                            {
                                CodDDirNegocio = gDN.Key.CodDDirNegocio ?? string.Empty,
                                NombreDirNegocio = (gDN.Key.NombreDirNegocio ?? string.Empty)
                                    .Replace("DIR.", string.Empty)
                                    .Trim(),
                                OrdenCodDDirNegocio = gDN.Key.OrdenCodDDirNegocio,
                                MostrarNotaDN800 = gDN.Key.CodDDirNegocio == "800",
                                Centros = gDN.Select(c => CrearCentroItem(c, mes)).ToList(),
                                TotalDN = CalcularTotales(gDN.ToList(), mes)
                            }).ToList(),
                        TotalMercado = CalcularTotales(gMer.ToList(), mes)
                    }).ToList(),
                TotalGerente = CalcularTotales(gGer.ToList(), mes)
            }).ToList();

        response.GruposGerente = gruposGerente;
        response.TotalGeneral = CalcularTotales(datosOrdenados, mes);

        return response;
    }

    /// <summary>
    /// Crea un CentroItemDto a partir de un GerenciasActividadPoco.
    /// Aplica las conversiones del benchmark de Cruces (líneas 91-119):
    ///   - CodCentro con PadLeft(3, '0')
    ///   - Importes / 1000 (miles de euros)
    ///   - Objetivos / 12 para mensual
    ///   - IP, Var.Contratacion, Var.Cartera via InformeCalculosUtils
    /// </summary>
    private CentroItemDto CrearCentroItem(GerenciasActividadPoco p, int mesActual)
    {
        var item = new CentroItemDto
        {
            CodCentro = (p.CodCentro ?? string.Empty).PadLeft(3, '0'),
            NombreCentro = p.NombreCentro ?? string.Empty,

            ObjetivoMensual = Math.Round(p.Objetivos / 12m, 2, MidpointRounding.AwayFromZero),
            ContratacionMensual = Math.Round(p.ImporteContratado / 1000m, 2, MidpointRounding.AwayFromZero),

            ObjetivoAnual = Math.Round(p.Objetivos, 2, MidpointRounding.AwayFromZero),
            ContratacionAcumulada = Math.Round(p.ImporteContratadoAcumulado / 1000m, 2, MidpointRounding.AwayFromZero),
            AnoAnterior = Math.Round(p.ImporteContratadoAcumuladoAñoAnterior / 1000m, 2, MidpointRounding.AwayFromZero),

            CarteraPdteAñoActual = Math.Round(p.CarteraPdteAñoActual / 1000m, 2, MidpointRounding.AwayFromZero),
            CarteraPdteAñoAnterior = Math.Round(p.CarteraPdteAñoAnterior / 1000m, 2, MidpointRounding.AwayFromZero)
        };

        item.IndiceProduccion = InformeCalculosUtils.CalcularIp(
            item.ContratacionAcumulada,
            item.ObjetivoAnual / 12m,
            mesActual);

        item.VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(
            item.AnoAnterior,
            item.ContratacionAcumulada);

        item.VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(
            item.CarteraPdteAñoAnterior,
            item.CarteraPdteAñoActual);

        return item;
    }

    /// <summary>
    /// Calcula los totales para una lista de POCOs (puede ser un grupo DN, un grupo Mercado,
    /// un grupo Gerente, o el dataset completo).
    /// Idéntico al benchmark de Cruces (líneas 121-143).
    /// </summary>
    private TotalesEstandarDto CalcularTotales(List<GerenciasActividadPoco> pocos, int mesActual)
    {
        if (!pocos.Any()) return new TotalesEstandarDto();

        var totalObjMensual = pocos.Sum(p => p.Objetivos) / 12m;
        var totalContrMensual = pocos.Sum(p => p.ImporteContratado) / 1000m;
        var totalObjAnual = pocos.Sum(p => p.Objetivos);
        var totalContrAcum = pocos.Sum(p => p.ImporteContratadoAcumulado) / 1000m;
        var totalAnoAnt = pocos.Sum(p => p.ImporteContratadoAcumuladoAñoAnterior) / 1000m;
        var totalCartAct = pocos.Sum(p => p.CarteraPdteAñoActual) / 1000m;
        var totalCartAnt = pocos.Sum(p => p.CarteraPdteAñoAnterior) / 1000m;

        return new TotalesEstandarDto
        {
            ObjetivoMensual = Math.Round(totalObjMensual, 2, MidpointRounding.AwayFromZero),
            ContratacionMensual = Math.Round(totalContrMensual, 2, MidpointRounding.AwayFromZero),
            ObjetivoAnual = Math.Round(totalObjAnual, 2, MidpointRounding.AwayFromZero),
            ContratacionAcumulada = Math.Round(totalContrAcum, 2, MidpointRounding.AwayFromZero),
            IndiceProduccion = InformeCalculosUtils.CalcularIp(totalContrAcum, totalObjAnual / 12m, mesActual),
            VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(totalAnoAnt, totalContrAcum),
            VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(totalCartAnt, totalCartAct)
        };
    }
}
