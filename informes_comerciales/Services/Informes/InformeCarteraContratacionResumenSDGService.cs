using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.CarteraContratacionResumenSDG;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe Cartera de Contratación (Resumen SDG).
/// </summary>
public class InformeCarteraContratacionResumenSDGService
{
    private readonly InformeRepository _repository;

    public InformeCarteraContratacionResumenSDGService(InformeRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Obtiene el informe de Cartera de Contratación (Resumen SDG).
    /// </summary>
    public async Task<CarteraContratacionResumenSDGResponseDto> ObtenerInformeAsync(
        int anio, int mes, int todoInt, string loginUsuario)
    {
        var datosPlanos = await _repository.ObtenerCarteraContratacionResumenSDGAsync(anio, mes, todoInt, loginUsuario);

        var response = new CarteraContratacionResumenSDGResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = todoInt == 0
                    ? "Cartera de Contratación Internacional (Resumen)"
                    : "Cartera de Contratación (Resumen)",
                SubTitulo = $"Cierre de {_getNombreMes(mes)} {anio}",
                Descripcion = "CONSEJO ELECNOR - Informe de Contratación",
                Filtros = new { Anio = anio, Mes = mes, Mercado = todoInt == 0 ? "Internacional" : "Todo" },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema"
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // ═══════════════════════════════════════════════════════════════════════
        // AGRUPACIÓN Y ORDENAMIENTO: EXCLUSIVAMENTE EN SERVICE (NUNCA EN SQL).
        // SDGs por NombreSubDirGeneral ASC.
        // DN internas por DN ASC (como en Access).
        // ═══════════════════════════════════════════════════════════════════════
        var agrupados = datosPlanos
            .GroupBy(d => new { d.CodSubDirGeneral, d.NombreSubDirGeneral })
            .Select(g => new CarteraContratacionResumenSDGItemDto
            {
                CodSubDirGeneral = g.Key.CodSubDirGeneral,
                NombreSubDirGeneral = g.Key.NombreSubDirGeneral,
                TotalAño = Math.Round(g.Sum(x => x.TotAño ?? 0), 2, MidpointRounding.AwayFromZero),
                TotalAñoAnterior = Math.Round(g.Sum(x => x.TotAñoAnterior ?? 0), 2, MidpointRounding.AwayFromZero),
                DetalleDN = g
                    .OrderBy(x => x.DN)
                    .Select(x => new CarteraContratacionResumenSDGDetalleDto
                    {
                        Año = x.Año,
                        Mes = x.Mes,
                        CodSubDirGeneral = x.CodSubDirGeneral,
                        CodDDirNegocio = x.CodDDirNegocio,
                        NombreSubDirGeneral = x.NombreSubDirGeneral,
                        DN = x.DN,
                        TotAño = x.TotAño.HasValue
                            ? Math.Round(x.TotAño.Value, 2, MidpointRounding.AwayFromZero)
                            : (decimal?)null,
                        TotAñoAnterior = x.TotAñoAnterior.HasValue
                            ? Math.Round(x.TotAñoAnterior.Value, 2, MidpointRounding.AwayFromZero)
                            : (decimal?)null
                    })
                    .ToList()
            })
            .OrderBy(a => a.NombreSubDirGeneral)
            .ToList();

        response.Datos = agrupados;

        // Totales globales
        response.Totales = new CarteraContratacionResumenSDGTotalesDto
        {
            TotalGeneralAño = Math.Round(agrupados.Sum(a => a.TotalAño), 2, MidpointRounding.AwayFromZero),
            TotalGeneralAñoAnterior = Math.Round(agrupados.Sum(a => a.TotalAñoAnterior), 2, MidpointRounding.AwayFromZero)
        };

        return response;
    }

    private static string _getNombreMes(int mes)
    {
        return mes switch
        {
            1 => "Enero",
            2 => "Febrero",
            3 => "Marzo",
            4 => "Abril",
            5 => "Mayo",
            6 => "Junio",
            7 => "Julio",
            8 => "Agosto",
            9 => "Septiembre",
            10 => "Octubre",
            11 => "Noviembre",
            12 => "Diciembre",
            _ => mes.ToString()
        };
    }
}
