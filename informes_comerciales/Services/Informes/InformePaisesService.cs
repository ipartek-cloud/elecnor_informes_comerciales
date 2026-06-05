using Elecnor_Informes_Comerciales.DTOs.Informes.Response;
using Elecnor_Informes_Comerciales.Models.Informes.Paises;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe de Países (Mercado Internacional y Países ALL).
/// Refactorizado siguiendo el patrón estándar de Servicios Elecnor.
/// </summary>
public class InformePaisesService
{
    private readonly InformeRepository _repository;

    public InformePaisesService(InformeRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Obtiene el informe de Países (Mercado Internacional).
    /// </summary>
    public async Task<PaisesResponseDto> ObtenerInformePaisesAsync(int anio, int mes, int? nroPagina, int umbral = 0, int numeroPaises = 0)
    {
        // 1. Obtener datos del repositorio (Patrón Estándar)
        var datosPlanos = await _repository.ObtenerPaisesAsync(anio, mes);

        // 2. Preparar respuesta
        var tituloBase = "Mercado internacional por países";
        var response = new PaisesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = tituloBase,
                Descripcion = "CONSEJO ELECNOR - Informe de Contratación",
                Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina, Umbral = umbral, NumeroPaises = numeroPaises },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema",
                NroPagina = nroPagina
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // 3. Procesar y Filtrar Detalle (sin sobrescritura de España)
        _ProcesarDetalleYTotales(response, datosPlanos, umbral, numeroPaises, null);

        return response;
    }

    /// <summary>
    /// Obtiene el informe de Países ALL (Nacional + Internacional).
    /// </summary>
    /// <param name="contratacionAnioAnteriorEspana">
    /// Valor (en euros) que se asigna forzosamente al país "España" en la columna
    /// de contratación del año anterior. Esto fuerza también un ajuste del total
    /// global del año anterior y un recálculo del % S/Total de todos los países
    /// para mantener la coherencia matemática (Opción C).
    /// </param>
    public async Task<PaisesResponseDto> ObtenerInformePaisesAllAsync(int anio, int mes, int? nroPagina, decimal contratacionAnioAnteriorEspana = 1950280m)
    {
        // 1. Obtener datos del repositorio (Nacional + Internacional)
        var datosPlanos = await _repository.ObtenerPaisesAllAsync(anio, mes);

        // 2. Preparar respuesta
        var response = new PaisesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = "Mercado por Países",
                Descripcion = "CONSEJO ELECNOR - Informe de Contratación",
                Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina, Umbral = 100000, ContratacionAnioAnteriorEspana = contratacionAnioAnteriorEspana },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema",
                NroPagina = nroPagina
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // 3. Procesar y Filtrar Detalle (Umbral fijo 100.000 para ALL) con sobrescritura de España
        _ProcesarDetalleYTotales(response, datosPlanos, 100000, 0, contratacionAnioAnteriorEspana);

        return response;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MÉTODOS PRIVADOS DE APOYO (ENCAPSULACIÓN DE LÓGICA)
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Procesa la lista plana de países, aplica el umbral y calcula los subtotales/totales.
    /// </summary>
    /// <param name="contratacionAnioAnteriorEspana">
    /// Si es distinto de null, sobrescribe el ImporteAnterior de "España" con este valor (en euros)
    /// y ajusta el total global + recalcula los % S/Total de todos los países para mantener
    /// la coherencia matemática (Opción C).
    /// </param>
    private void _ProcesarDetalleYTotales(PaisesResponseDto response, List<PaisesPoco> datosPlanos, int umbral, int numeroPaises, decimal? contratacionAnioAnteriorEspana)
    {
        // Cálculos Globales (El 100% real del mercado)
        decimal totalGlobalActual = datosPlanos.Sum(x => x.ImporteContratadoAcumulado);
        decimal totalGlobalAnterior = datosPlanos.Sum(x => x.ImporteContratadoAcumuladoAñoAnterior);
        decimal totalDGInfrActual = datosPlanos.Where(x => x.Ajuste == 0).Sum(x => x.ImporteContratadoAcumulado);

        int posRelativa = 1;
        var paisesOrdenados = datosPlanos.OrderByDescending(x => x.ImporteContratadoAcumulado);

        foreach (var p in paisesOrdenados)
        {
            // El registro 'OTROS' es una fila técnica de consolidación, no se muestra en el detalle
            if (p.Pais == "OTROS") continue;

            // Lógica de filtrado por umbral
            bool cumpleUmbral = umbral == 0
                ? p.ImporteContratadoAcumulado > 0
                : p.ImporteContratadoAcumulado >= umbral;

            if (cumpleUmbral)
            {
                if (numeroPaises > 0 && response.Paises.Count >= numeroPaises)
                    break;

                response.Paises.Add(new PaisDetalleDto
                {
                    Pais = p.Pais,
                    EsNuevo = p.SinContratacionAñoAnterior == "*",

                    // Año Actual
                    ImporteActual = p.ImporteContratadoAcumulado,
                    PosicionActual = posRelativa++,
                    PorcentajeSobreInternacionalActual = _CalcularPorcentaje(p.ImporteContratadoAcumulado, totalGlobalActual),

                    // Año Anterior
                    ImporteAnterior = p.ImporteContratadoAcumuladoAñoAnterior,
                    PosicionAnterior = p.OrdenAñoAnterior,
                    PorcentajeSobreInternacionalAnterior = _CalcularPorcentaje(p.ImporteContratadoAcumuladoAñoAnterior, totalGlobalAnterior)
                });
            }
        }

        // ═══════════════════════════════════════════════════════════════════════
        // SOBRESCRITURA DE ESPAÑA (Opción C: ajuste coherente del total global)
        // Solo se aplica para el informe de Países ALL (cuando se recibe el valor).
        // ═══════════════════════════════════════════════════════════════════════
        decimal totalGlobalAnteriorAjustado = totalGlobalAnterior;

        if (contratacionAnioAnteriorEspana.HasValue)
        {
            var filaEspana = response.Paises.FirstOrDefault(p =>
                string.Equals(p.Pais, "España", StringComparison.OrdinalIgnoreCase));

            if (filaEspana != null)
            {
                // 1) Sobrescribir el ImporteAnterior de España con el valor del popover
                filaEspana.ImporteAnterior = contratacionAnioAnteriorEspana.Value;

                // 2) Ajustar el total global del año anterior:
                //    restar el dato original de España y sumar el valor sobrescrito
                decimal importeEspanaAnteriorOriginal = datosPlanos
                    .Where(x => string.Equals(x.Pais, "España", StringComparison.OrdinalIgnoreCase))
                    .Sum(x => x.ImporteContratadoAcumuladoAñoAnterior);

                totalGlobalAnteriorAjustado = totalGlobalAnterior
                    - importeEspanaAnteriorOriginal
                    + contratacionAnioAnteriorEspana.Value;

                // 3) Recalcular el % S/Total de TODOS los países con el nuevo denominador
                //    para mantener la coherencia matemática de la tabla
                foreach (var p in response.Paises)
                {
                    p.PorcentajeSobreInternacionalAnterior =
                        _CalcularPorcentaje(p.ImporteAnterior, totalGlobalAnteriorAjustado);
                }
            }
        }

        // Asignación de Totales
        response.Totales = new TotalesPaisesDto
        {
            // Fila 1: Subtotal de los países visibles (suma de lo mostrado en el detalle)
            SubtotalImporteActual = response.Paises.Sum(x => x.ImporteActual),
            SubtotalImporteAnterior = response.Paises.Sum(x => x.ImporteAnterior),
            SubtotalPorcentajeActual = response.Paises.Sum(x => x.PorcentajeSobreInternacionalActual),
            SubtotalPorcentajeAnterior = response.Paises.Sum(x => x.PorcentajeSobreInternacionalAnterior),

            // Fila 2: Total Global del Mercado (Euros Reales)
            TotalInternacionalActual = totalGlobalActual,
            TotalInternacionalAnterior = totalGlobalAnteriorAjustado,
            TotalInternacionalDGInfrActual = totalDGInfrActual
        };
    }

    /// <summary>
    /// Calcula el porcentaje relativo redondeado a 0 decimales (estándar Consejo).
    /// </summary>
    private decimal _CalcularPorcentaje(decimal parcial, decimal total)
    {
        if (total <= 0) return 0;
        return (decimal)Math.Round((double)((parcial / total) * 100), 0, MidpointRounding.AwayFromZero);
    }
}
