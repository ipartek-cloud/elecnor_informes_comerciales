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

    public async Task<PaisesResponseDto> ObtenerInformeAsync(int anio, int mes, int? nroPagina, int umbral = 0)
    {
        // 1. Obtener datos del repositorio
        var datosPlanos = await _repository.ObtenerPaisesAsync(anio, mes);

        // 2. Preparar respuesta
        var response = new PaisesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = umbral > 0 
                    ? "Países Relevantes (Mercado Internacional)" 
                    : "Países (Mercado Internacional)",
                Descripcion = "Consejo Administración - Informe de Contratación",
                Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina, Umbral = umbral },
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

        // 4. Mapear Detalle y filtrar por umbral
        // - umbral = 0: Muestra todos los países con importe > 0 (equivale a != 0 cuando valores >= 0)
        // - umbral = 100000: Muestra solo países con importe >= 100000 (Relevantes)
        // Nota: Para umbral > 0, usamos >= para incluir el valor exacto del umbral
        int posRelativa = 1;
        foreach (var p in datosPlanos.OrderByDescending(x => x.ImporteContratadoAcumulado))
        {
            // El registro 'OTROS' no se muestra en el detalle, pero ya ha sido sumado al global total
            if (p.Pais == "OTROS") continue;

            // Filtrado por umbral: > 0 si umbral=0, >= umbral si umbral>0
            bool cumpleUmbral = umbral == 0
                ? p.ImporteContratadoAcumulado > 0        // Modo "Todos": > 0 ≡ != 0
                : p.ImporteContratadoAcumulado >= umbral; // Modo "Relevantes": >= 100000

            if (cumpleUmbral)
            {
                var detalle = new PaisDetalleDto
                {
                    Pais = p.Pais,
                    EsNuevo = p.SinContratacionAñoAnterior == "*",

                    // Mantenemos EUROS REALES según mandato GEMINI.md
                    ImporteActual = p.ImporteContratadoAcumulado,
                    PosicionActual = posRelativa++,

                    // Porcentaje relativo al Total Global (no a la suma de lo visible)
                    PorcentajeSobreInternacionalActual = totalGlobalActual > 0
                        ? (decimal)Math.Round((double)((p.ImporteContratadoAcumulado / totalGlobalActual) * 100), 0, MidpointRounding.AwayFromZero)
                        : 0,

                    ImporteAnterior = p.ImporteContratadoAcumuladoAñoAnterior,
                    PosicionAnterior = p.OrdenAñoAnterior,

                    PorcentajeSobreInternacionalAnterior = totalGlobalAnterior > 0
                        ? (decimal)Math.Round((double)((p.ImporteContratadoAcumuladoAñoAnterior / totalGlobalAnterior) * 100), 0, MidpointRounding.AwayFromZero)
                        : 0
                };
                response.Paises.Add(detalle);
            }
        }

        // 5. Calcular subtotales de la Fila 1 (solo países filtrados y mostrados en detalle)
        decimal subtotalImporteActual   = response.Paises.Sum(x => x.ImporteActual);
        decimal subtotalImporteAnterior = response.Paises.Sum(x => x.ImporteAnterior);
        
        decimal subtotalPorcentajeActual   = response.Paises.Sum(x => x.PorcentajeSobreInternacionalActual);
        decimal subtotalPorcentajeAnterior = response.Paises.Sum(x => x.PorcentajeSobreInternacionalAnterior);

        response.Totales = new TotalesPaisesDto
        {
            // Fila 1: suma de lo visible en pantalla (Euros Reales)
            SubtotalImporteActual      = subtotalImporteActual,
            SubtotalImporteAnterior    = subtotalImporteAnterior,
            SubtotalPorcentajeActual   = subtotalPorcentajeActual,
            SubtotalPorcentajeAnterior = subtotalPorcentajeAnterior,

            // Fila 2: total global real (Euros Reales)
            TotalInternacionalActual       = totalGlobalActual,
            TotalInternacionalAnterior     = totalGlobalAnterior,
            TotalInternacionalDGInfrActual = totalDGInfr,
        };

        return response;
    }

    /// <summary>
    /// Obtiene el informe de Países (Nacional + Internacional) - Todos los países relevantes.
    /// Usa spContratacion_NacIntTODO con parámetro '' para obtener Nacional + Internacional.
    /// Título: "Países Relevantes" (sin "Mercado Internacional").
    /// Umbral fijo: 100000 (relevantes).
    /// </summary>
    public async Task<PaisesResponseDto> ObtenerInformeAllAsync(int anio, int mes, int? nroPagina)
    {
        // 1. Obtener datos del repositorio (Nacional + Internacional)
        var datosPlanos = await _repository.ObtenerPaisesAllAsync(anio, mes);

        // 2. Preparar respuesta con título específico para paises_all
        var response = new PaisesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Países Relevantes",
                Descripcion = "Consejo Administración - Informe de Contratación",
                Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina, Umbral = 100000 },
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

        // 4. Mapear Detalle y filtrar por umbral = 100000 (Relevantes)
        int umbral = 100000;
        int posRelativa = 1;
        foreach (var p in datosPlanos.OrderByDescending(x => x.ImporteContratadoAcumulado))
        {
            if (p.Pais == "OTROS") continue;

            bool cumpleUmbral = p.ImporteContratadoAcumulado >= umbral;

            if (cumpleUmbral)
            {
                var detalle = new PaisDetalleDto
                {
                    Pais = p.Pais,
                    EsNuevo = p.SinContratacionAñoAnterior == "*",
                    ImporteActual = p.ImporteContratadoAcumulado,
                    PosicionActual = posRelativa++,
                    PorcentajeSobreInternacionalActual = totalGlobalActual > 0
                        ? (decimal)Math.Round((double)((p.ImporteContratadoAcumulado / totalGlobalActual) * 100), 0, MidpointRounding.AwayFromZero)
                        : 0,
                    ImporteAnterior = p.ImporteContratadoAcumuladoAñoAnterior,
                    PosicionAnterior = p.OrdenAñoAnterior,
                    PorcentajeSobreInternacionalAnterior = totalGlobalAnterior > 0
                        ? (decimal)Math.Round((double)((p.ImporteContratadoAcumuladoAñoAnterior / totalGlobalAnterior) * 100), 0, MidpointRounding.AwayFromZero)
                        : 0
                };
                response.Paises.Add(detalle);
            }
        }

        // 5. Calcular subtotales de la Fila 1
        decimal subtotalImporteActual = response.Paises.Sum(x => x.ImporteActual);
        decimal subtotalImporteAnterior = response.Paises.Sum(x => x.ImporteAnterior);
        decimal subtotalPorcentajeActual = response.Paises.Sum(x => x.PorcentajeSobreInternacionalActual);
        decimal subtotalPorcentajeAnterior = response.Paises.Sum(x => x.PorcentajeSobreInternacionalAnterior);

        response.Totales = new TotalesPaisesDto
        {
            SubtotalImporteActual = subtotalImporteActual,
            SubtotalImporteAnterior = subtotalImporteAnterior,
            SubtotalPorcentajeActual = subtotalPorcentajeActual,
            SubtotalPorcentajeAnterior = subtotalPorcentajeAnterior,
            TotalInternacionalActual = totalGlobalActual,
            TotalInternacionalAnterior = totalGlobalAnterior,
            TotalInternacionalDGInfrActual = totalDGInfr,
        };

        return response;
    }
}
