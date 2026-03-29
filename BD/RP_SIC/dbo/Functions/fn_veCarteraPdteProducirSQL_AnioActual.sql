
CREATE FUNCTION [dbo].[fn_veCarteraPdteProducirSQL_AnioActual] (
    @Anio INT,
    @Mes  INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        [CodCentro], 
        SUM([Importe]) AS [CarteraPdteAñoActual]
    FROM [dbo].[CarteraPdteProducirSQL]
    WHERE 
        [Año] = @Anio 
        AND [Mes] = (@Mes - 1)
    GROUP BY [CodCentro]
);
