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
    public async Task<PaisesResponseDto> ObtenerInformePaisesAsync(int anio, int mes, int? nroPagina, int umbral = 0)
    {
        // 1. Obtener datos del repositorio (Patrón Estándar)
        var datosPlanos = await _repository.ObtenerPaisesAsync(anio, mes);

        // 2. Preparar respuesta
        var tituloBase = umbral > 0 ? "Países Relevantes" : "Países";
        var response = new PaisesResponseDto
        {
            Meta = new MetaInformeDto
            {
                Titulo = $"{tituloBase} (Mercado Internacional)",
                Descripcion = "Consejo Administración - Informe de Contratación",
                Filtros = new { Anio = anio, Mes = mes, NroPagina = nroPagina, Umbral = umbral },
                FechaGeneracion = DateTime.Now,
                Usuario = "Sistema"
            }
        };

        if (datosPlanos == null || !datosPlanos.Any())
            return response;

        // 3. Procesar y Filtrar Detalle
        _ProcesarDetalleYTotales(response, datosPlanos, umbral);

        return response;
    }

    /// <summary>
    /// Obtiene el informe de Países ALL (Nacional + Internacional).
    /// </summary>
    public async Task<PaisesResponseDto> ObtenerInformePaisesAllAsync(int anio, int mes, int? nroPagina)
    {
        // 1. Obtener datos del repositorio (Nacional + Internacional)
        var datosPlanos = await _repository.ObtenerPaisesAllAsync(anio, mes);

        // 2. Preparar respuesta
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

        // 3. Procesar y Filtrar Detalle (Umbral fijo 100.000 para ALL)
        _ProcesarDetalleYTotales(response, datosPlanos, 100000);

        return response;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MÉTODOS PRIVADOS DE APOYO (ENCAPSULACIÓN DE LÓGICA)
    // ═══════════════════════════════════════════════════════════════════════════

    /// <summary>
    /// Procesa la lista plana de países, aplica el umbral y calcula los subtotales/totales.
    /// </summary>
    private void _ProcesarDetalleYTotales(PaisesResponseDto response, List<PaisesPoco> datosPlanos, int umbral)
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

        // Asignación de Totales
        response.Totales = new TotalesPaisesDto
        {
            // Fila 1: Subtotal de los países visibles (filtrados)
            SubtotalImporteActual = response.Paises.Sum(x => x.ImporteActual),
            SubtotalImporteAnterior = response.Paises.Sum(x => x.ImporteAnterior),
            SubtotalPorcentajeActual = response.Paises.Sum(x => x.PorcentajeSobreInternacionalActual),
            SubtotalPorcentajeAnterior = response.Paises.Sum(x => x.PorcentajeSobreInternacionalAnterior),

            // Fila 2: Total Global del Mercado (Euros Reales)
            TotalInternacionalActual = totalGlobalActual,
            TotalInternacionalAnterior = totalGlobalAnterior,
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
