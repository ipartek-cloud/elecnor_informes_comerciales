using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.Paises;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe de Países (Mercado Internacional por países).
/// </summary>
public class InformePaisesService
{
    private readonly InformeRepository _repository;

    public InformePaisesService(InformeRepository repository)
    {
        _repository = repository;
    }

    public async Task<PaisesResponseDto> ObtenerInformeAsync(int anio, int mes, int? nroPagina)
    {
        // 1. Obtener datos del repositorio
        var datosPlanos = await _repository.ObtenerPaisesAsync(anio, mes);

        // 2. Preparar respuesta
        var response = new PaisesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Mercado internacional por países",
                Descripcion = "Consejo Administración - Informe de Contratación",
                Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema"
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // 3. Calcular el "100% Real" (Todas las filas del repo, incluso las que se filtrarán)
        decimal totalGlobalActual = datosPlanos.Sum(x => x.ImporteContratadoAcumulado);
        decimal totalGlobalAnterior = datosPlanos.Sum(x => x.ImporteContratadoAcumuladoAñoAnterior);
        decimal totalDGInfr = datosPlanos.Where(x => x.Ajuste == 0).Sum(x => x.ImporteContratadoAcumulado);

        // 4. Mapear Detalle y filtrar por importancia (Ocultamos 'OTROS' del listado)
        int posRelativa = 1;
        foreach (var p in datosPlanos.OrderByDescending(x => x.ImporteContratadoAcumulado))
        {
            // El registro 'OTROS' no se muestra en el detalle, pero ya ha sido sumado al global total
            if (p.Pais == "OTROS") continue;

            // Solo incluimos en el listado si tiene algún dato relevante (> 100.000€ en cualquiera de los dos años)
            if (p.ImporteContratadoAcumulado >= 100000 || p.ImporteContratadoAcumuladoAñoAnterior >= 100000)
            {
                var detalle = new PaisDetalleDto
                {
                    Pais = p.Pais,
                    EsNuevo = p.SinContratacionAñoAnterior == "*",
                    
                    ImporteActual = Math.Round(p.ImporteContratadoAcumulado, 0, MidpointRounding.AwayFromZero),
                    PosicionActual = p.ImporteContratadoAcumulado >= 100000 ? posRelativa++ : 0,

                    // Porcentaje relativo al Total Global (no a la suma de lo visible)
                    PorcentajeSobreInternacionalActual = totalGlobalActual > 0 
                        ? (int)Math.Round((p.ImporteContratadoAcumulado / totalGlobalActual) * 100, 0, MidpointRounding.AwayFromZero) 
                        : 0,

                    ImporteAnterior = Math.Round(p.ImporteContratadoAcumuladoAñoAnterior, 0, MidpointRounding.AwayFromZero),
                    PosicionAnterior = p.OrdenAñoAnterior,

                    PorcentajeSobreInternacionalAnterior = totalGlobalAnterior > 0 
                        ? (int)Math.Round((p.ImporteContratadoAcumuladoAñoAnterior / totalGlobalAnterior) * 100, 0, MidpointRounding.AwayFromZero) 
                        : 0
                };
                response.Paises.Add(detalle);
            }
        }

        // 5. Los porcentajes de la fila de totales reflejan el peso de los países listados sobre el total global
        decimal sumaPorcentajeMostradoActual = response.Paises.Sum(x => x.PorcentajeSobreInternacionalActual);
        decimal sumaPorcentajeMostradoAnterior = response.Paises.Sum(x => x.PorcentajeSobreInternacionalAnterior);

        response.Totales = new TotalesPaisesDto
        {
            TotalInternacionalActual = Math.Round(totalGlobalActual, 0, MidpointRounding.AwayFromZero),
            TotalInternacionalAnterior = Math.Round(totalGlobalAnterior, 0, MidpointRounding.AwayFromZero),
            TotalInternacionalDGInfrActual = Math.Round(totalDGInfr, 0, MidpointRounding.AwayFromZero),
            PorcentajeTotalActual = (int)sumaPorcentajeMostradoActual, // Esto será el 92% si no se muestran todos
            PorcentajeTotalAnterior = (int)sumaPorcentajeMostradoAnterior
        };

        return response;
    }
}
