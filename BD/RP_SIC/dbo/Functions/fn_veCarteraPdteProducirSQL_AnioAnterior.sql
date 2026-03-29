
CREATE FUNCTION [dbo].[fn_veCarteraPdteProducirSQL_AnioAnterior] (
    @Anio INT,
    @Mes  INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        [CodCentro], 
        SUM([Importe]) AS [CarteraPdteAñoAnterior]
    FROM [dbo].[CarteraPdteProducirSQL]
    WHERE 
        [Año] = (@Anio - 1)
        AND [Mes] = (@Mes - 1)
    GROUP BY [CodCentro]
);
