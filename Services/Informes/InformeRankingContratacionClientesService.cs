using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.DTOs.Informes.RankingContratacionClientes;
using Elecnor_Informes_Comerciales.Models.Informes.RankingContratacionClientes;
using Elecnor_Informes_Comerciales.Repositories.Informes;

namespace Elecnor_Informes_Comerciales.Services.Informes;

/// <summary>
/// Servicio para el informe de Ranking de Contratación por Clientes.
/// </summary>
public class InformeRankingContratacionClientesService
{
    private readonly InformeRepository _repository;

    public InformeRankingContratacionClientesService(InformeRepository repository)
    {
        _repository = repository;
    }

    /// <summary>
    /// Genera los datos del informe y retorna el DTO estructurado para la vista.
    /// </summary>
    public async Task<RankingContratacionClientesResponseDto> ObtenerRankingAsync(string mercado, int anio, int mes)
    {
        // 1. Ejecutar el SP que limpia y llena la tabla rptContratacion_Clientes
        await _repository.EjecutarSPObrasRankingClientesAsync(mercado, anio, mes);

        // 2. Obtener la suma total de TODO el mercado (independientemente del top 30)
        // Esto equivale a fnSumaContratacionActual_Clientes() en Access
        decimal totalMercadoReal = await _repository.ObtenerSumaTotalMercadoClientesAsync();

        // 3. Obtener el Ranking (Top 30) filtrando por importe mínimo (0.5 k€ -> 500 €)
        const decimal importeMinimo = 0.5m; // En k€ (corregido por paridad Access)
        var datosPoco = await _repository.ObtenerRankingContratacionClientesAsync(anio, mes, importeMinimo);

        // 4. Mapear y calcular porcentajes
        var datosDto = datosPoco.Select(x => new RankingContratacionClientesDetalleDto
        {
            Row = x.Row,
            Cliente = x.Cliente,
            Importe = x.ImporteContratadoAcumulado, // Ya viene en k€ desde el repo (refactorizado por paridad Access)
            ImporteAnterior = x.VerAñoAnterior == 1 ? x.ImporteContratadoAcumulado_AñoAnterior : null,
            AI = x.AI,
            // Porcentaje sobre el TOTAL NACIONAL (no sobre el top 30)
            PorcentajeSobreTotal = totalMercadoReal > 0
                ? Math.Round((x.ImporteContratadoAcumulado / totalMercadoReal) * 100, 1, MidpointRounding.AwayFromZero)
                : 0
        })
        .OrderBy(x => x.Row) // EL ORDEN SE APLICA EN EL SERVICIO
        .ToList();

        var response = new RankingContratacionClientesResponseDto
        {
            TotalMercado = totalMercadoReal,
            Datos = datosDto,
            Meta = new { 
                Filtros = new { anio = anio, mes = mes, mercado = mercado }
            }
        };

        return response;
    }
}
