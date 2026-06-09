using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.Actividades;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe de Actividades (Consejo Administración).
/// </summary>
public class InformeActividadesService
{
    private readonly InformeRepository _repository;

    public InformeActividadesService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task<ActividadesResponseDto> ObtenerInformeAsync(int anio, int mes, string loginUsuario)
    {
        // 1. Obtener datos planos del repositorio (vienen convertidos a Miles)
        var datosPlanos = await _repository.ObtenerActividadesAsync(anio, mes, loginUsuario);

        var response = new ActividadesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Actividades",
                Descripcion = "Consejo Administración - Informe de Contratación",
                Filtros = new { Anio = anio, Mes = mes },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema"
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // 2. Bloque "Elecnor" (Agrupado por Actividad para consolidar Nacional e Internacional)
        var datosAgrupadosElecnor = datosPlanos
            .GroupBy(x => x.Actividad)
            .Select(g => new ActividadPoco
            {
                Actividad = g.Key,
                ImporteContratadoAcumulados = g.Sum(x => x.ImporteContratadoAcumulados),
                ImporteContratadoAcumuladosAñoAnterior = g.Sum(x => x.ImporteContratadoAcumuladosAñoAnterior),
                ImporteContratadoAcumuladosLY = g.Sum(x => x.ImporteContratadoAcumuladosLY),
                Orden = g.Min(x => x.Orden)
            })
            .Where(x => x.ImporteContratadoAcumulados != 0 || x.ImporteContratadoAcumuladosAñoAnterior != 0)
            .ToList();

        var bloqueElecnor = ProcesarBloque(datosAgrupadosElecnor, "Elecnor");
        response.Paises.Add(bloqueElecnor);

        // 3. Bloques por País (Agrupado por el campo Pais del resultset)
        // Orden sugerido: Nacional primero, luego el resto (Internacional, etc.)
        var nombresPaises = datosPlanos.Select(x => x.Pais)
                                     .Distinct()
                                     .OrderByDescending(p => p == "Nacional")
                                     .ThenBy(p => p);

        foreach (var nombrePais in nombresPaises)
        {
            var filasPais = datosPlanos.Where(x => x.Pais == nombrePais).ToList();
            var bloque = ProcesarBloque(filasPais, nombrePais);
            response.Paises.Add(bloque);
        }

        return response;
    }

    /// <summary>
    /// Procesa un conjunto de filas para generar un bloque de País con su detalle y totales.
    /// </summary>
    private PaisActividadesDto ProcesarBloque(List<ActividadPoco> filas, string nombrePais)
    {
        decimal totalActual = filas.Sum(x => x.ImporteContratadoAcumulados);
        decimal totalAnterior = filas.Sum(x => x.ImporteContratadoAcumuladosAñoAnterior) * 1000;
        decimal totalLastYear = filas.Sum(x => x.ImporteContratadoAcumuladosLY);

        var bloque = new PaisActividadesDto
        {
            NombrePais = nombrePais,
            Totales = new TotalesActividadDto
            {
                ImporteActual = Math.Round(totalActual, 0, MidpointRounding.AwayFromZero),
                ImporteAnterior = Math.Round(totalAnterior, 0, MidpointRounding.AwayFromZero),
                VariacionPorcentaje = InformeCalculosUtils.CalcularVariacionContratacion(totalLastYear, totalActual),
                PorcentajeTotal = 100
            }
        };

        // Detalle de actividades ordenado por Importe Actual DESC (según nuevo requisito)
        var detalleOrdenado = filas.OrderByDescending(x => x.ImporteContratadoAcumulados);

        foreach (var fila in detalleOrdenado)
        {
            bloque.Detalle.Add(new ActividadDetalleDto
            {
                Actividad = fila.Actividad,
                ImporteActual = Math.Round(fila.ImporteContratadoAcumulados, 0, MidpointRounding.AwayFromZero),
                ImporteAnterior = Math.Round(fila.ImporteContratadoAcumuladosAñoAnterior * 1000, 0, MidpointRounding.AwayFromZero),
                
                // % s/Mercado: Peso de la actividad sobre el total del bloque
                PorcentajeActualMercado = totalActual > 0
                    ? Math.Round((fila.ImporteContratadoAcumulados / totalActual) * 100, 0, MidpointRounding.AwayFromZero)
                    : 0,

                PorcentajeAnteriorMercado = totalAnterior > 0
                    ? Math.Round(((fila.ImporteContratadoAcumuladosAñoAnterior * 1000) / totalAnterior) * 100, 0, MidpointRounding.AwayFromZero)
                    : 0,

                // Variación %: (Actual - LY) / LY
                VariacionPorcentaje = InformeCalculosUtils.CalcularVariacionContratacion(fila.ImporteContratadoAcumuladosLY, fila.ImporteContratadoAcumulados),
                Orden = fila.Orden
            });
        }

        return bloque;
    }
}
