using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Elecnor_Informes_Comerciales.DTOs.Informes.RankingContratacionClientes;
using Elecnor_Informes_Comerciales.Models.Informes.RankingContratacionClientes;
using Elecnor_Informes_Comerciales.Repositories.Informes;
using Elecnor_Informes_Comerciales.Services.Informes.Utils;

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
        // 1. Ejecutar los generadores en paralelo (usando conexiones independientes administradas en Repo)
        await Task.WhenAll(
            _repository.EjecutarSPObrasRankingClientesAsync(mercado, anio, mes),
            _repository.EjecutarSPObrasRankingClientesDesgloseAsync(mercado, anio, mes)
        );

        // 2. Obtener datos de ambas tablas (Ranking y Desglose) + Total Mercado filtrando por contexto
        var taskRanking = _repository.ObtenerRankingContratacionClientesAsync(mercado, anio, mes, 0.5m);
        var taskDesglose = _repository.ObtenerRankingContratacionClientesDesgloseAsync(mercado, anio, mes);
        var taskTotalMercado = _repository.ObtenerSumaTotalMercadoClientesAsync(mercado, anio);

        await Task.WhenAll(taskRanking, taskDesglose, taskTotalMercado);

        var datosPoco = await taskRanking;
        var desglosePoco = await taskDesglose;
        var totalMercadoReal = await taskTotalMercado;

        // 3. Mapear y Agrupar Desglose (Paso previo para anidamiento)
        // Nota: CalcularVariacionLibre ya maneja anterior=0 (retorna "-") y actual=0 (retorna "-100%")
        var desgloseAgrupado = desglosePoco.Select(x => new RankingContratacionClientesDesgloseDto
        {
            Anio = anio,
            Mercado = mercado,
            Pais = x.Pais,
            AI = x.AI,
            Cliente = x.Cliente,
            ClienteDesglose = x.ClienteDesglose,
            ImporteContratadoAcumulado = x.ImporteContratadoAcumulado,
            ImporteContratadoAnterior = x.ImporteContratadoAcumuladoAñoAnterior,
            PorcentajeSobreTotal = totalMercadoReal > 0
                ? Math.Round((x.ImporteContratadoAcumulado / totalMercadoReal) * 100, 1, MidpointRounding.AwayFromZero)
                : 0,
            // Calcular variación: "-" si anterior=0, "+XX%" o "-XX%" en otro caso
            Variacion = InformeCalculosUtils.CalcularVariacionLibre(x.ImporteContratadoAcumuladoAñoAnterior, x.ImporteContratadoAcumulado)
        })
        .GroupBy(x => x.Cliente)
        .ToDictionary(g => g.Key, g => g.ToList());

        // 4. Mapear Ranking (Top 30) con sus desgloses anidados
        var datosDto = datosPoco.Select(x => new RankingContratacionClientesDetalleDto
        {
            Row = x.Row,
            Cliente = x.Cliente,
            Importe = x.ImporteContratadoAcumulado, 
            ImporteAnterior = x.VerAñoAnterior == 1 ? x.ImporteContratadoAcumulado_AñoAnterior : null,
            AI = x.AI,
            PorcentajeSobreTotal = totalMercadoReal > 0
                ? Math.Round((x.ImporteContratadoAcumulado / totalMercadoReal) * 100, 1, MidpointRounding.AwayFromZero)
                : 0,
            // Asignar desglose si existe para este cliente
            Desglose = desgloseAgrupado.TryGetValue(x.Cliente, out var lista) ? lista : new()
        })
        .OrderBy(x => x.Row)
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
