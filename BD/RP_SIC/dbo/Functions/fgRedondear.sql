CREATE FUNCTION dbo.fgRedondear
(
    @pNum  FLOAT,
    @pDec  INT
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @lngPotencia BIGINT
    DECLARE @varNum      FLOAT
    DECLARE @lngEnt      BIGINT
    DECLARE @varDec      FLOAT

    IF @pNum IS NULL RETURN 0

    SET @lngPotencia = POWER(10.0, @pDec)
    SET @varNum      = @pNum * @lngPotencia

    -- INT en VBA == FLOOR: trunca hacia menos infinito
    SET @lngEnt = FLOOR(@varNum)
    SET @varDec = @varNum - @lngEnt

    -- Forzar 0.5 hacia arriba (evitar redondeo bancario)
    IF @varDec = 0.5
        SET @varDec = 0.6

    SET @varNum = @lngEnt + @varDec

    -- CLng equivale a ROUND(..., 0) sobre el valor ya ajustado
    RETURN ROUND(@varNum, 0) / @lngPotencia
END