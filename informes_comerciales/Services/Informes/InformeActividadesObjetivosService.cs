using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.ActividadesObjetivos;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe de Actividades_Objetivos (Consejo Administración).
/// Incluye contratación acumulada, objetivos anuales, IP y % de cumplimiento.
/// </summary>
public class InformeActividadesObjetivosService
{
    private readonly InformeRepository _repository;

    public InformeActividadesObjetivosService(InformeRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Obtiene el informe completo de Actividades_Objetivos.
    /// </summary>
    public async Task<ActividadesObjetivosResponseDto> ObtenerInformeAsync(int anio, int mes, int? nroPagina, string loginUsuario)
    {
        var datosPlanos = await _repository.ObtenerActividadesObjetivosAsync(anio, mes, loginUsuario);

        var response = new ActividadesObjetivosResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Actividades Objetivos",
                Descripcion = "Consejo Administración - Informe de Contratación con Objetivos",
                Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema",
                NroPagina = nroPagina
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // Bloque Elecnor (consolidado: Nacional + Internacional)
        var datosAgrupadosElecnor = datosPlanos
            .GroupBy(x => x.Actividad)
            .Select(g => new ActividadObjetivoPoco
            {
                Actividad = g.Key,
                ImporteContratadoAcumulado = g.Sum(x => x.ImporteContratadoAcumulado),
                ImporteContratadoAcumuladoAñoAnterior = g.Sum(x => x.ImporteContratadoAcumuladoAñoAnterior),
                ImporteContratadoAcumuladoLastYear = g.Sum(x => x.ImporteContratadoAcumuladoLastYear),
                ImporteObjetivos = g.Sum(x => x.ImporteObjetivos),
                Orden = g.Min(x => x.Orden)
            })
            .Where(x => x.ImporteContratadoAcumulado != 0 || x.ImporteContratadoAcumuladoAñoAnterior != 0)
            .ToList();

        var bloqueElecnor = ProcesarBloque(datosAgrupadosElecnor, "Elecnor", mes);
        response.Paises.Add(bloqueElecnor);

        // Bloques por País
        var nombresPaises = datosPlanos
            .Select(x => x.Pais)
            .Distinct()
            .OrderByDescending(p => p == "Nacional")
            .ThenBy(p => p);

        foreach (var nombrePais in nombresPaises)
        {
            var filasPais = datosPlanos.Where(x => x.Pais == nombrePais).ToList();
            var bloque = ProcesarBloque(filasPais, nombrePais, mes);
            response.Paises.Add(bloque);
        }

        return response;
    }

    private PaisActividadesObjetivosDto ProcesarBloque(
        List<ActividadObjetivoPoco> filas,
        string nombrePais,
        int mes)
    {
        decimal totalActual = filas.Sum(x => x.ImporteContratadoAcumulado);
        decimal totalAnterior = filas.Sum(x => x.ImporteContratadoAcumuladoAñoAnterior);
        decimal totalLastYear = filas.Sum(x => x.ImporteContratadoAcumuladoLastYear);
        decimal totalObjetivos = filas.Sum(x => x.ImporteObjetivos);

        var bloque = new PaisActividadesObjetivosDto
        {
            NombrePais = nombrePais,
            Totales = new TotalesActividadObjetivoDto
            {
                ImporteActual = Math.Round(totalActual, 0, MidpointRounding.AwayFromZero),
                ImporteAnterior = Math.Round(totalAnterior, 0, MidpointRounding.AwayFromZero),
                ImporteObjetivos = Math.Round(totalObjetivos, 0, MidpointRounding.AwayFromZero),
                Ip = totalObjetivos > 0
                    ? Math.Round((totalActual / 1000m) / ((totalObjetivos / 12m) * mes), 2, MidpointRounding.AwayFromZero)
                    : 0,
                VariacionPorcentaje = InformeCalculosUtils.CalcularVariacionContratacion(totalLastYear, totalActual),
                PorcentajeTotal = 100,
                PorcentajeCumplimiento = totalObjetivos > 0
                    ? Math.Round(((totalActual / 1000m) / totalObjetivos) * 100m, 0, MidpointRounding.AwayFromZero)
                    : 0
            }
        };

        var detalleOrdenado = filas.OrderByDescending(x => x.ImporteContratadoAcumulado);

        foreach (var fila in detalleOrdenado)
        {
            bloque.Detalle.Add(new ActividadObjetivoDetalleDto
            {
                Actividad = fila.Actividad,
                ImporteActual = Math.Round(fila.ImporteContratadoAcumulado, 0, MidpointRounding.AwayFromZero),
                ImporteAnterior = Math.Round(fila.ImporteContratadoAcumuladoAñoAnterior, 0, MidpointRounding.AwayFromZero),
                ImporteObjetivos = Math.Round(fila.ImporteObjetivos, 0, MidpointRounding.AwayFromZero),
                Ip = fila.ImporteObjetivos > 0
                    ? Math.Round((fila.ImporteContratadoAcumulado / 1000m) / ((fila.ImporteObjetivos / 12m) * mes), 2, MidpointRounding.AwayFromZero)
                    : 0,
                VariacionPorcentaje = InformeCalculosUtils.CalcularVariacionContratacion(
                    fila.ImporteContratadoAcumuladoLastYear,
                    fila.ImporteContratadoAcumulado),
                PorcentajeActualMercado = totalActual > 0
                    ? Math.Round((fila.ImporteContratadoAcumulado / totalActual) * 100, 0, MidpointRounding.AwayFromZero)
                    : 0,
                PorcentajeAnteriorMercado = totalAnterior > 0
                    ? Math.Round((fila.ImporteContratadoAcumuladoAñoAnterior / totalAnterior) * 100, 0, MidpointRounding.AwayFromZero)
                    : 0,
                PorcentajeCumplimiento = fila.ImporteObjetivos > 0
                    ? Math.Round(((fila.ImporteContratadoAcumulado / 1000m) / fila.ImporteObjetivos) * 100m, 0, MidpointRounding.AwayFromZero)
                    : 0,
                Orden = fila.Orden
            });
        }

        return bloque;
    }
}
