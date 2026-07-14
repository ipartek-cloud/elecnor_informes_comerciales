using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.GerenciasTotalesCruces;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

public class InformeGerenciasTotalesCrucesService
{
    private readonly InformeRepository _repository;

    public InformeGerenciasTotalesCrucesService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task<GerenciasTotalesCrucesResponseDto> ObtenerInformeAsync(
        int anio, int mes, int? nroPagina, string loginUsuario, string? codSubDirGeneral = "221")
    {
        if (string.IsNullOrEmpty(codSubDirGeneral))
            codSubDirGeneral = "221";

        var datosPlanos = await _repository
            .ObtenerGerenciasTotalesCrucesAsync(anio, mes, loginUsuario, codSubDirGeneral);

        var response = new GerenciasTotalesCrucesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Gerencias (Detalle) x DN x Delegaciones",
                Descripcion = "Contratación, Objetivos y Cartera por Gerencia × DN × Centro",
                Filtros = new { Anio = anio, Mes = mes, CodSubDirGeneral = codSubDirGeneral },
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

        var datosOrdenados = datosPlanos
            .OrderBy(d => d.Orden ?? string.Empty)
            .ThenBy(d => d.NombreGerente ?? "")
            .ThenBy(d => d.OrdenCodDDirNegocio ?? 0)
            .ThenByDescending(d => d.Objetivos)
            .ThenBy(d => d.NombreCentro ?? "")
            .ToList();

        var gruposOrden = datosOrdenados
            .GroupBy(d => d.Orden ?? "")
            .Select(gOrden => new GrupoOrdenDto
            {
                Orden = gOrden.Key,
                Gerencias = gOrden
                    .GroupBy(d => d.NombreGerente ?? "")
                    .Select(gGer => new GrupoGerenciaDto
                    {
                        NombreGerente = gGer.Key,
                        Mercado = gGer.FirstOrDefault()?.Mercado ?? "Nacional",
                        BloquesDN = gGer
                            .GroupBy(d => new { d.CodDDirNegocio, d.NombreDirNegocio, d.OrdenCodDDirNegocio })
                            .Select(gDN => new BloqueDireccionNegocioDto
                            {
                                CodDDirNegocio = gDN.Key.CodDDirNegocio ?? "",
                                NombreDirNegocio = (gDN.Key.NombreDirNegocio ?? "").Replace("DIR.", "").Trim(),
                                OrdenCodDDirNegocio = gDN.Key.OrdenCodDDirNegocio,
                                MostrarNotaDN800 = gDN.Key.CodDDirNegocio == "800",
                                Centros = gDN.Select(c => CrearCentroItem(c, mes)).ToList(),
                                TotalDN = CalcularTotales(gDN.ToList(), mes)
                            }).ToList(),
                        TotalGerencia = CalcularTotales(gGer.ToList(), mes)
                    }).ToList()
            }).ToList();

        response.GruposOrden = gruposOrden;
        response.TotalGeneral = CalcularTotales(datosOrdenados, mes);

        return response;
    }

    private CentroItemDto CrearCentroItem(GerenciasTotalesCrucesPoco p, int mesActual)
    {
        var item = new CentroItemDto
        {
            CodCentro = (p.CodCentro ?? "").PadLeft(3, '0'),
            NombreCentro = p.NombreCentro ?? "",

            ObjetivoMensual = Math.Round(p.Objetivos / 12m, 2, MidpointRounding.AwayFromZero),
            ContratacionMensual = Math.Round(p.ImporteContratado / 1000m, 2, MidpointRounding.AwayFromZero),

            ObjetivoAnual = Math.Round(p.Objetivos, 2, MidpointRounding.AwayFromZero),
            ContratacionAcumulada = Math.Round(p.ImporteContratadoAcumulado / 1000m, 2, MidpointRounding.AwayFromZero),
            AnoAnterior = Math.Round(p.ImporteContratadoAcumuladoAñoAnterior / 1000m, 2, MidpointRounding.AwayFromZero),

            CarteraPdteAñoActual = Math.Round(p.CarteraPdteAñoActual / 1000m, 2, MidpointRounding.AwayFromZero),
            CarteraPdteAñoAnterior = Math.Round(p.CarteraPdteAñoAnterior / 1000m, 2, MidpointRounding.AwayFromZero)
        };

        item.IndiceProduccion = InformeCalculosUtils.CalcularIp(
            item.ContratacionAcumulada, item.ObjetivoAnual / 12m, mesActual);

        item.VariacionContratacion = InformeCalculosUtils.CalcularVariacionContratacion(
            item.AnoAnterior, item.ContratacionAcumulada);

        item.VariacionCartera = InformeCalculosUtils.CalcularVariacionCartera(
            item.CarteraPdteAñoAnterior, item.CarteraPdteAñoActual);

        return item;
    }

    private TotalesEstandarDto CalcularTotales(List<GerenciasTotalesCrucesPoco> pocos, int mesActual)
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
