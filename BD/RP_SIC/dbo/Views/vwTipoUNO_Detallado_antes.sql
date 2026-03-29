
CREATE VIEW [dbo].[vwTipoUNO_Detallado_antes]
AS
SELECT        CTRO, CDOFT, LEFT(OBRA, 3) AS OBRA, RIGHT(OBRA, 2) AS OBRAL, AAMMA AS FechaApertura, AAMMC AS FechaCierre
FROM            dbo.Enlaces
WHERE        (CDOFT <> 1)

