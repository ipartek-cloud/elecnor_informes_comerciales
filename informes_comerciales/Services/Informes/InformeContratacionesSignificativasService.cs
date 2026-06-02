using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.DTOs.Informes.ContratacionesSignificativas;
using Elecnor_Informes_Comerciales.Models.Informes.ContratacionesSignificativas;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

public class InformeContratacionesSignificativasService
{
    private readonly InformeRepository _repository;

    public InformeContratacionesSignificativasService(InformeRepository repository)
        => _repository = repository;

    public async Task GenerarDatosSignificativosAsync(int anio, int mes)
    {
        await _repository.EjecutarSPObrasRPTAsync(anio, mes);
    }

    public async Task<ContratacionesSignificativasResponseDto> ObtenerInformeAsync(int anio, int mes, string mercado, string codSubDirGeneral, decimal limiteImporte = 1000)
    {
        // ═══════════════════════════════════════════════════════
        // 1. Definir umbral (Logica de Negocio centralizada en el Servicio)
        // ═══════════════════════════════════════════════════════
        // Usamos el límite dinámico pasado como parámetro.

        // ═══════════════════════════════════════════════════════
        // 2. Lanzar TODAS las queries EN PARALELO (Task.WhenAll)
        //    Patron B en Repository permite conexiones independientes
        // ═══════════════════════════════════════════════════════
        var tareaPrincipal  = _repository.ObtenerContratacionesSignificativasAsync(anio, mes, mercado, codSubDirGeneral);
        var tareaMes        = _repository.ObtenerContratacionesSignificativasMesAsync(anio, mes, mercado, codSubDirGeneral, limiteImporte);
        var tareaAnteriores = _repository.ObtenerContratacionesSignificativasMesesAnterioresAsync(anio, mes, mercado, codSubDirGeneral, limiteImporte);

        await Task.WhenAll(tareaPrincipal, tareaMes, tareaAnteriores);

        var datosPlanos           = await tareaPrincipal;
        var datosMesPlanos        = await tareaMes;
        var datosAnterioresPlanos = await tareaAnteriores;

        // ═══════════════════════════════════════════════════════
        // 2. Procesar datos principales (sin cambios)
        // ═══════════════════════════════════════════════════════
        if (datosPlanos == null || !datosPlanos.Any())
        {
            return new ContratacionesSignificativasResponseDto
            {
                Meta                 = _crearMeta(anio, mes, mercado, codSubDirGeneral, limiteImporte),
                Datos                = new(),
                TotalGeneral         = 0m,
                DatosMes             = new(), // Explicito: sin subinforme si no hay datos base
                DatosMesesAnteriores = new()
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
        // 3. Procesar subinformes: mapear y ordenar por ImporteContratado DESC
        //    Orden DESC: los contratos mas grandes primero para el directivo
        //    Se hace tanto para el mes actual como para los anteriores.
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

        var datosMesesAnterioresDto = (datosAnterioresPlanos ?? Enumerable.Empty<ContratacionesSignificativasMesPoco>())
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
        // 4. Construir respuesta unificada
        // ═══════════════════════════════════════════════════════
        return new ContratacionesSignificativasResponseDto
        {
            Meta                 = _crearMeta(anio, mes, mercado, codSubDirGeneral, limiteImporte),
            Datos                = datosDto,
            TotalGeneral         = totalGeneral,
            DatosMes             = datosMesDto,
            DatosMesesAnteriores = datosMesesAnterioresDto
        };
    }

    private static MetaContSigDto _crearMeta( int anio, 
                                              int mes, 
                                              string mercado, 
                                              string codSubDirGeneral,
                                              decimal limiteImporte) => new() {
                                                                                    Titulo          = $"Contrataciones Significativas Mercado {mercado}",
                                                                                    FechaGeneracion = DateTime.Now,
                                                                                    Filtros = new ContSigFiltrosDto
                                                                                    {
                                                                                        Anio             = anio,
                                                                                        Mes              = mes,
                                                                                        Mercado          = mercado,
                                                                                        CodSubDirGeneral = codSubDirGeneral,
                                                                                        LimiteImporte    = limiteImporte
                                                                                    }
                                                                                };
}
