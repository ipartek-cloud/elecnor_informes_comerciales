namespace Elecnor_Informes_Comerciales.Services.Informes.Utils;

/// <summary>
/// Servicio estático con métodos de cálculo compartidos por todos los informes.
/// Implementación única → mantenimiento único. Evita duplicación de lógica de negocio.
/// </summary>
public static class InformeCalculosUtils
{
    /// <summary>
    /// Calcula el Índice de Producción (IP) = Acumulado / (ObjetivoMensual * Mes).
    /// </summary>
    /// <param name="contrAcum">Contratación acumulada</param>
    /// <param name="objetivoMensual">Objetivo mensual calculado (anual/12)</param>
    /// <param name="mes">Mes actual (1-12)</param>
    /// <returns>IP redondeado a 2 decimales, o 0 si hay división inválida</returns>
    public static decimal CalcularIp(decimal contrAcum, decimal objetivoMensual, int mes)
    {
        if (objetivoMensual == 0 || mes == 0) return 0;
        
        decimal resultado = contrAcum / (objetivoMensual * mes);
        return Math.Round(resultado, 2, MidpointRounding.AwayFromZero);
    }

    /// <summary>
    /// Formatea la variación de contratación entre dos periodos.
    /// </summary>
    /// <param name="anterior">Valor del periodo anterior</param>
    /// <param name="actual">Valor del periodo actual</param>
    /// <returns>
    /// String formateado: "-"" (si anterior=0), ">1000%" (si >10), "<-1000%" (si <-10), 
    /// o el porcentaje con formato "N0" (ej: "12%", "-5%")
    /// </returns>
    public static string CalcularVariacionContratacion(decimal anterior, decimal actual)
    {
        if (anterior == 0) return "-";
        
        decimal v = (actual - anterior) / anterior;
        
        if (v > 10 || anterior < 0) return ">1000%";
        if (v < -10) return "<-1000%";
        
        return $"{(v * 100):N0}%";
    }

    /// <summary>
    /// Formatea la variación de cartera entre dos periodos.
    /// Difiere de CalcularVariacionContratacion en los límites extremos.
    /// </summary>
    /// <param name="anterior">Valor del periodo anterior</param>
    /// <param name="actual">Valor del periodo actual</param>
    /// <returns>
    /// String formateado: "-"" (si anterior=0), "-*%" (si >10), "<-100%" (si <-10),
    /// o el porcentaje con formato "N0" (ej: "12%", "-5%")
    /// </returns>
    public static string CalcularVariacionCartera(decimal anterior, decimal actual)
    {
        if (anterior == 0) return "-";
        
        decimal v = (actual - anterior) / anterior;
        
        if (v > 10 || anterior < 0) return "-*%";
        if (v < -10) return "<-100%";
        
        return $"{(v * 100):N0}%";
    }

    /// <summary>
    /// Formatea la variación entre dos periodos SIN aplicar ningún límite de cap.
    /// Usar cuando variaciones extremas son valores reales y válidos (ej: subinforme AI).
    /// </summary>
    /// <param name="anterior">Valor del periodo anterior</param>
    /// <param name="actual">Valor del periodo actual</param>
    /// <returns>
    /// String formateado: "-" (si anterior=0), o el porcentaje con formato "N0" (ej: "7569%", "-63%")
    /// </returns>
    public static string CalcularVariacionLibre(decimal anterior, decimal actual)
    {
        if (anterior == 0) return "-";

        decimal v = (actual - anterior) / anterior;

        return $"{(v * 100):N0}%";
    }

    /// <summary>
    /// Obtiene el nombre del mes en español.
    /// </summary>
    public static string GetNombreMes(int mes)
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
            _ => string.Empty
        };
    }
}
