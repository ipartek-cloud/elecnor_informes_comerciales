using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.DTOs.Informes.ContratacionesSignificativas;
using Elecnor_Informes_Comerciales.Models.Informes.ContratacionesSignificativas;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

public class InformeContratacionesSignificativasRiService
{
    private readonly InformeRepository _repository;

    public InformeContratacionesSignificativasRiService(InformeRepository repository)
        => _repository = repository;

    public async Task GenerarDatosSignificativosAsync(int anio, int mes)
    {
        await _repository.EjecutarSPObrasRPTAsync(anio, mes);
    }

    public async Task<ContratacionesSignificativasRiResponseDto> ObtenerInformeAsync(int anio, int mes, string mercado, string codSubDirGeneral, int? nroPagina = null)
    {
        // ═══════════════════════════════════════════════════════
        // 1. Definir umbral (2M para RI)
        // ═══════════════════════════════════════════════════════
        const decimal importeRi = 2000; // >= 2M ke o <= -2M ke

        // ═══════════════════════════════════════════════════════
        // 2. Lanzar queries EN PARALELO
        // ═══════════════════════════════════════════════════════
        var tareaPrincipal = _repository.ObtenerContratacionesSignificativasRiAsync(anio, mes, mercado, codSubDirGeneral);
        var tareaMes       = _repository.ObtenerContratacionesSignificativasMesRiAsync(anio, mes, mercado, codSubDirGeneral, importeRi);

        await Task.WhenAll(tareaPrincipal, tareaMes);

        var datosPlanos    = await tareaPrincipal;
        var datosMesPlanos = await tareaMes;

        // ═══════════════════════════════════════════════════════
        // 3. Procesar datos principales
        // ═══════════════════════════════════════════════════════
        if (datosPlanos == null || !datosPlanos.Any())
        {
            return new ContratacionesSignificativasRiResponseDto
            {
                Meta         = _crearMeta(anio, mes, mercado, codSubDirGeneral, nroPagina),
                Datos        = new(),
                TotalGeneral = 0m,
                DatosMes     = new()
            };
        }

        var datosDto = datosPlanos.Select(x => new ContSigDireccionDto
        {
            Orden             = x.Orden,
            NombreDirNegocio  = x.NombreDirNegocio,
            ImporteContratado = Math.Round(x.ImporteContratado, 2, MidpointRounding.AwayFromZero)
        }).ToList();

        var totalGeneral = Math.Round(datosDto.Sum(x => x.ImporteContratado), 2, MidpointRounding.AwayFromZero);

        // ═══════════════════════════════════════════════════════
        // 4. Procesar detalle mensual
        // ═══════════════════════════════════════════════════════
        var datosMesDto = (datosMesPlanos ?? Enumerable.Empty<ContratacionesSignificativasMesPoco>())
            .Select(x => new ContSigMesDto
            {
                Orden                 = x.Orden,
                NombreDirNegocio      = x.NombreDirNegocio,
                NombreCliente_OK      = x.NombreCliente_OK,
                DescripcionOferta_OK  = x.DescripcionOferta_OK,
                ImporteContratado     = Math.Round(x.ImporteContratado, 2, MidpointRounding.AwayFromZero)
            })
            .OrderByDescending(x => x.ImporteContratado)
            .ToList();

        // ═══════════════════════════════════════════════════════
        // 5. Construir respuesta unificada
        // ═══════════════════════════════════════════════════════
        return new ContratacionesSignificativasRiResponseDto
        {
            Meta         = _crearMeta(anio, mes, mercado, codSubDirGeneral, nroPagina),
            Datos        = datosDto,
            TotalGeneral = totalGeneral,
            DatosMes     = datosMesDto
        };
    }

    private static MetaContSigRiDto _crearMeta(int anio, int mes, string mercado, string codSubDirGeneral, int? nroPagina) => new()
    {
        Titulo          = $"Contrataciones Significativas Mercado {mercado}",
        UmbralTexto     = "Contratación > 2 M", // Enviamos el literal dinámico
        FechaGeneracion = DateTime.Now,
        NroPagina       = nroPagina,
        Filtros         = new ContSigFiltrosDto
        {
            Anio             = anio,
            Mes              = mes,
            Mercado          = mercado,
            CodSubDirGeneral = codSubDirGeneral,
            NroPagina        = nroPagina
        }
    };
}
