
CREATE FUNCTION [dbo].[fnCartera] (
    @pCarteraPdteAnioAnterior FLOAT,
    @pCarteraPdteAnioActual   FLOAT
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @vAnioAnterior FLOAT = ISNULL(@pCarteraPdteAnioAnterior, 0);
    DECLARE @vAnioActual   FLOAT = ISNULL(@pCarteraPdteAnioActual, 0);
    DECLARE @vCartera      FLOAT;
    DECLARE @Resultado     NVARCHAR(50);

    -- Caso 1: Anterior es 0 (Evitar división por cero y lógica Access)
    IF (@vAnioAnterior = 0)
    BEGIN
        SET @Resultado = '-';
    END
    ELSE
    BEGIN
        -- Cálculo de la variación
        SET @vCartera = ((@vAnioActual - @vAnioAnterior) / @vAnioAnterior);

        -- Caso 2: Variación mayor a 1000% o base negativa
        IF (@vCartera > 10 OR @vAnioAnterior < 0)
        BEGIN
            SET @Resultado = '-*%';
        END
        -- Caso 3: Variación menor a -1000%
        ELSE IF (@vCartera < -10)
        BEGIN
            SET @Resultado = '<-100%';
        END
        -- Caso 4: Cálculo estándar redondeado
        ELSE
        BEGIN
            SET @Resultado = CAST(CAST(ROUND(@vCartera * 100, 0) AS INT) AS NVARCHAR(10)) + '%';
        END
    END

    RETURN @Resultado;
END
