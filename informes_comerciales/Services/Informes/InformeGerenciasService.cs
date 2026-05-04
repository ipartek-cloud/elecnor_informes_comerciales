using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.Models.Informes.Gerencias;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio de negocio para el informe de Gerencias.
/// Responsable de transformar datos planos en DTOs estructurados con cálculos de IP y variación.
/// </summary>
public class InformeGerenciasService
{
    private readonly InformeRepository _informeRepository;

    public InformeGerenciasService(InformeRepository informeRepository)
    {
        _informeRepository = informeRepository;
    }

    /// <summary>
    /// Obtiene el informe completo de Gerencias con todos los cálculos aplicados.
    /// </summary>
    public async Task<GerenciasResponseDto> ObtenerInformeGerenciasAsync(int anio, int mes, int? nroPagina)
    {
        var datosPlanos = await _informeRepository.ObtenerGerenciasAsync(anio, mes);

        var response = new GerenciasResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Gerencias",
                Descripcion = "Informe de Contratación, Objetivos y Cartera por Gerencia",
                Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema",
                NroPagina = nroPagina
            }
        };

        // Validación temprana: sin datos
        if (datosPlanos == null || !datosPlanos.Any())
        {
            response.TotalGeneral = new TotalesEstandarDto();
            return response;
        }

        // ORDENACIÓN: Por campo 'Orden' ascendente (CentrosGerentesSQL)
        var datosOrdenados = datosPlanos.OrderBy(d => d.Orden).ToList();

        // Transformar cada POCO → GerenciaItemDto
        var gerencias = datosOrdenados
            .Select(d => CrearGerenciaItem(d, mes))
            .ToList();

        response.Gerencias = gerencias;

        // Total General
        response.TotalGeneral = CalcularTotalesGenerales(gerencias, mes);

        return response;
    }

    /// <summary>
    /// Crea un GerenciaItemDto con todos los cálculos aplicados.
    /// </summary>
    private GerenciaItemDto CrearGerenciaItem(GerenciasPoco poco, int mesActual)
    {
        var item = new GerenciaItemDto
        {
            Actividad = poco.Actividad,
            Orden = poco.Orden,
            SumarizaGerentes = poco.SumarizaGerentes,

            // Mensual (contratación en k€, objetivos en euros reales)
            ObjetivoMensual = Math.Round(poco.Objetivos / 12m, 2, MidpointRounding.AwayFromZero),
            ContratacionMensual = Math.Round(poco.ImporteContratado / 1000m, 2, MidpointRounding.AwayFromZero),

            // Acumulado (contratación en k€, objetivos en euros reales)
            ObjetivoAnual = Math.Round(poco.Objetivos, 2, MidpointRounding.AwayFromZero),
            ContratacionAcumulada = Math.Round(poco.ImporteContratadoAcumulado / 1000m, 2, MidpointRounding.AwayFromZero),

            // Año anterior (en k€, para cálculo de variación)
            AnoAnterior = Math.Round(poco.ImporteContratadoAcumuladoAñoAnterior / 1000m, 2, MidpointRounding.AwayFromZero),

            // Cartera (valores en k€)
            CarteraPdteAñoActual = Math.Round(poco.CarteraPdteAñoActual / 1000m, 2, MidpointRounding.AwayFromZero),
            CarteraPdteAñoAnterior = Math.Round(poco.CarteraPdteAñoAnterior / 1000m, 2, MidpointRounding.AwayFromZero)
        };

        // IP: Acumulado / (ObjetivoMensual * Mes)
        // El objetivo mensual para IP = ObjetivoAnual / 12 (en euros reales, sin dividir por 1000)
        item.IndiceProduccion = InformeCalculosUtils.CalcularIp(
            item.ContratacionAcumulada,
            item.ObjetivoAnual / 12m,
            mesActual
        );

        // Variación Contratación
        item.VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(
            item.AnoAnterior,
            item.ContratacionAcumulada
        );

        // Variación Cartera
        item.VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(
            item.CarteraPdteAñoAnterior,
            item.CarteraPdteAñoActual
        );

        return item;
    }

    /// <summary>
    /// Calcula los totales generales usando TotalesEstandarDto.
    /// </summary>
    private TotalesEstandarDto CalcularTotalesGenerales(List<GerenciaItemDto> gerencias, int mesActual)
    {
        if (!gerencias.Any())
            return new TotalesEstandarDto();

        var totalObjMensual = gerencias.Sum(g => g.ObjetivoMensual);
        var totalContrMensual = gerencias.Sum(g => g.ContratacionMensual);
        var totalObjAnual = gerencias.Sum(g => g.ObjetivoAnual);
        var totalContrAcum = gerencias.Sum(g => g.ContratacionAcumulada);
        var totalAnoAnt = gerencias.Sum(g => g.AnoAnterior);
        var totalCartAct = gerencias.Sum(g => g.CarteraPdteAñoActual);
        var totalCartAnt = gerencias.Sum(g => g.CarteraPdteAñoAnterior);

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
