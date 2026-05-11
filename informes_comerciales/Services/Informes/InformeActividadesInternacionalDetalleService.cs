using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.ActividadesInternacionalDetalle;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

namespace Elecnor_Informes_Comerciales.Services.Informes;

public class InformeActividadesInternacionalDetalleService
{
    private readonly InformeRepository _repository;

    public InformeActividadesInternacionalDetalleService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task<ActividadesInternacionalDetalleResponseDto> ObtenerInformeAsync(int anio, int mes)
    {
        var datosPlanos = await _repository.ObtenerActividadesInternacionalDetalleAsync(anio, mes);

        if (datosPlanos == null || !datosPlanos.Any())
        {
            return new ActividadesInternacionalDetalleResponseDto
            {
                Meta = new MetaInformeDto
                {
                    Titulo = "Detalle Actividades Internacional",
                    Descripcion = "Contratación por actividad y subactividad (Internacional)",
                    Filtros = new { Anio = anio, Mes = mes, Pais = "Internacional" },
                    FechaGeneracion = DateTime.Now,
                    Usuario = "Sistema"
                },
                Actividades = new List<ActividadPrincipalDto>(),
                Totales = new TotalesDto(),
                SubinformesAnexos = new List<SubinformeDto>()
            };
        }

        var datosOrdenados = datosPlanos
            .OrderBy(x => x.Pais)
            .ThenBy(x => x.Orden)
            .ThenBy(x => x.EsSubActividad)
            .ToList();

        var totalInternacionalActual = datosOrdenados
            .Where(d => d.EsSubActividad == 0)
            .Sum(d => d.ImporteContratadoAcumulado);

        var totalInternacionalAnterior = datosOrdenados
            .Where(d => d.EsSubActividad == 0)
            .Sum(d => d.ImporteContratadoAcumuladoAñoAnterior);

        var actividadesPrincipales = datosOrdenados
            .Where(d => d.EsSubActividad == 0)
            .Select(padre => new ActividadPrincipalDto
            {
                Nombre = padre.ActividadPrincipal ?? string.Empty,
                Orden = padre.Orden,
                ImporteContratadoAcumulado = padre.ImporteContratadoAcumulado,
                ImporteContratadoAcumuladoAñoAnterior = padre.ImporteContratadoAcumuladoAñoAnterior,
                ImporteObjetivos = padre.ImporteObjetivos,
                PorcentajeSobreMercado = CalcularPorcentajeMercado(
                    padre.ImporteContratadoAcumulado, totalInternacionalActual),
                PorcentajeSobreMercadoAnterior = CalcularPorcentajeMercado(
                    padre.ImporteContratadoAcumuladoAñoAnterior, totalInternacionalAnterior),
                IndiceProduccion = InformeCalculosUtils.CalcularIp(
                    padre.ImporteContratadoAcumulado / 1000m, padre.ImporteObjetivos / 12, mes),
                VariacionPorcentaje = InformeCalculosUtils.CalcularVariacionContratacion(
                    padre.ImporteContratadoAcumuladoAñoAnterior, padre.ImporteContratadoAcumulado),
                SubActividades = datosOrdenados
                    .Where(h => h.EsSubActividad == 1 
                             && h.ActividadPrincipal == padre.ActividadPrincipal)
                    .Select(hijo => new SubActividadDto
                    {
                        Nombre = hijo.ActividadDetalle ?? string.Empty,
                        Orden = hijo.Orden,
                        ImporteContratadoAcumulado = hijo.ImporteContratadoAcumulado,
                        ImporteContratadoAcumuladoAñoAnterior = hijo.ImporteContratadoAcumuladoAñoAnterior,
                        PorcentajeSobreMercado = CalcularPorcentajeMercado(
                            hijo.ImporteContratadoAcumulado, totalInternacionalActual),
                        PorcentajeSobreMercadoAnterior = CalcularPorcentajeMercado(
                            hijo.ImporteContratadoAcumuladoAñoAnterior, totalInternacionalAnterior)
                    })
                    .ToList()
            })
            .ToList();

        var totalActual = actividadesPrincipales.Sum(a => a.ImporteContratadoAcumulado);
        var totalAnterior = actividadesPrincipales.Sum(a => a.ImporteContratadoAcumuladoAñoAnterior);
        var totalObjetivos = actividadesPrincipales.Sum(a => a.ImporteObjetivos);

        var totales = new TotalesDto
        {
            ImporteContratadoAcumulado = totalActual,
            // TODO: Validar con negocio. Ajuste +2 heredado de Access (Etiqueta177: "Ajuste Manual en total año anterior").
            // Replicado por paridad numérica durante la migración. Eliminar si negocio confirma que no aplica.
            ImporteContratadoAcumuladoAñoAnterior = totalAnterior + 2,
            ImporteObjetivos = totalObjetivos,
            PorcentajeSobreMercado = CalcularPorcentajeMercado(totalActual, totalInternacionalActual),
            PorcentajeSobreMercadoAnterior = CalcularPorcentajeMercado(totalAnterior, totalInternacionalAnterior),
            IndiceProduccion = InformeCalculosUtils.CalcularIp(totalActual / 1000m, totalObjetivos / 12, mes),
            VariacionPorcentaje = InformeCalculosUtils.CalcularVariacionContratacion(totalAnterior, totalActual)
        };

        return new ActividadesInternacionalDetalleResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Detalle Actividades Internacional",
                Descripcion = "Contratación por actividad y subactividad (Internacional)",
                Filtros = new { Anio = anio, Mes = mes, Pais = "Internacional" },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema"
            },
            Actividades = actividadesPrincipales,
            Totales = totales,
            SubinformesAnexos = new List<SubinformeDto>()
        };
    }

    private static decimal CalcularPorcentajeMercado(decimal importe, decimal totalMercado)
    {
        if (totalMercado == 0) return 0;
        return Math.Round((importe / totalMercado) * 100, 0, MidpointRounding.AwayFromZero);
    }
}
