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

    public async Task<ContratacionesSignificativasRiResponseDto> ObtenerInformeAsync(int anio, int mes, string mercado, string codSubDirGeneral, int? nroPagina = null, decimal limiteImporte = 2000m)
    {
        // ═══════════════════════════════════════════════════════
        // 1. Definir umbral dinámico (por defecto 2M k€ para RI)
        // ═══════════════════════════════════════════════════════
        // Se interpreta como >= N k€ o <= -N k€ (positivo y negativo)
        var importeRi = limiteImporte;

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
                Meta         = _crearMeta(anio, mes, mercado, codSubDirGeneral, nroPagina, importeRi),
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
            Meta         = _crearMeta(anio, mes, mercado, codSubDirGeneral, nroPagina, importeRi),
            Datos        = datosDto,
            TotalGeneral = totalGeneral,
            DatosMes     = datosMesDto
        };
    }

    private static MetaContSigRiDto _crearMeta(int anio, int mes, string mercado, string codSubDirGeneral, int? nroPagina, decimal limiteImporte) => new()
    {
        Titulo          = $"Contrataciones Significativas Mercado {mercado}",
        UmbralTexto     = $"Contratación > {FormatearUmbral(limiteImporte)}",
        FechaGeneracion = DateTime.Now,
        NroPagina       = nroPagina,
        Filtros         = new ContSigFiltrosDto
        {
            Anio             = anio,
            Mes              = mes,
            Mercado          = mercado,
            CodSubDirGeneral = codSubDirGeneral,
            NroPagina        = nroPagina,
            LimiteImporte    = limiteImporte
        }
    };

    /// <summary>
    /// Convierte un importe en miles de euros a su notación corta (M / X.YM).
    /// Ejemplos: 2000 -> "2M", 2500 -> "2.5M", 1500 -> "1.5M", 1000 -> "1M".
    /// </summary>
    private static string FormatearUmbral(decimal limiteImporte)
    {
        var valorM = limiteImporte / 1000m;
        return (valorM % 1m == 0m) ? $"{valorM:0}M" : $"{valorM:0.#}M";
    }
}
