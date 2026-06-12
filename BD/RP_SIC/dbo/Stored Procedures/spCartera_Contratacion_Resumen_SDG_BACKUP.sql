CREATE PROCEDURE [dbo].[spCartera_Contratacion_Resumen_SDG_BACKUP](
    @Año AS INT = 2026,
    @Mes AS INT = 12,
    @TodoInt as INT = 0 -- =1 Todo / <>1 Internacional
)
AS
BEGIN
    --select * from SumarigramaHistorico where Año=2026
--
-- SELECT DISTINCT Año,
--                 CodDirGeneral,
--                 NombreDirGeneral,
--                 CodSubDirGeneral,
--                 NombreSubDirGeneral,
--                 CodDDirNegocio,
--                 NombreDirNegocio
-- FROM SumarigramaHistorico
--

print '11'
    SELECT @Año                 AS       Año,
           @Mes                 as       Mes,
--       Base.Año,
--       Base.CodDirGeneral,
--       Base.NombreDirGeneral,
           Base.CodSubDirGeneral,
           Base.NombreSubDirGeneral,
           Base.CodDDirNegocio,
           'D. ' + Base.NombreDirNegocio DN,
           SUM(ISNULL(DatosA_1.TotAño, 0)) AS       TotAñoAnterior,
           SUM(ISNULL(DatosA.TotAño, 0))   AS       TotAño
    FROM (
             -- Base: todas las SubDirGenerales distintas (independiente de que haya datos en 2026)
             SELECT DISTINCT Año,
                             CodDirGeneral,
                             NombreDirGeneral,
                             CodSubDirGeneral,
                             NombreSubDirGeneral,
                             CodDDirNegocio,
                             NombreDirNegocio
             FROM SumarigramaHistorico
             WHERE Año IN (@Año, @Año - 1)) Base

             LEFT JOIN (
        -- Año actual (2026) - puede estar vacío
        SELECT a.AnioInforme,
               S.CodDirGeneral,
               S.CodSubDirGeneral,
               S.CodDDirNegocio,
               SUM(ISNULL(a.ImporteEUR, 0)) AS TotAño
        FROM CarterasContratacionSQL AS a
                 INNER JOIN SumarigramaHistorico S
                            ON a.CentroChar = S.CodCentro
                                AND a.AnioInforme = S.Año
        WHERE a.AnioInforme = @Año
          AND a.MesInforme = @Mes
          AND a.Pais <> CASE WHEN @TodoInt <> 1 THEN 'Nacional' ELSE '' END
        GROUP BY a.AnioInforme, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio) DatosA
                       ON Base.Año = DatosA.AnioInforme AND Base.CodDirGeneral = DatosA.CodDirGeneral AND
                          Base.CodSubDirGeneral = DatosA.CodSubDirGeneral AND
                          Base.CodDDirNegocio = DatosA.CodDDirNegocio

             LEFT JOIN (
        -- Año anterior (2025)
        SELECT a.AnioInforme,
               S.CodDirGeneral,
               S.CodSubDirGeneral,
               S.CodDDirNegocio,
               SUM(ISNULL(a.ImporteEUR, 0)) AS TotAño
        FROM CarterasContratacionSQL AS a
                 INNER JOIN SumarigramaHistorico S
                            ON a.CentroChar = S.CodCentro
                                AND a.AnioInforme = S.Año
        WHERE a.AnioInforme = @Año - 1
          AND a.MesInforme = @Mes
          AND a.Pais <> CASE WHEN @TodoInt <> 1 THEN 'Nacional' ELSE '' END
        GROUP BY a.AnioInforme, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio) DatosA_1
                       ON Base.Año = DatosA_1.AnioInforme AND Base.CodDirGeneral = DatosA_1.CodDirGeneral AND
                          Base.CodSubDirGeneral = DatosA_1.CodSubDirGeneral AND
                          Base.CodDDirNegocio = DatosA_1.CodDDirNegocio

    GROUP BY --Base.Año,
             --Base.CodDirGeneral,
             --Base.NombreDirGeneral,
             Base.CodSubDirGeneral,
             Base.NombreSubDirGeneral,
             Base.CodDDirNegocio,
             Base.NombreDirNegocio

    ORDER BY --Base.Año,
--         Base.CodDirGeneral,
             --Base.NombreDirGeneral,
             Base.CodSubDirGeneral,
             Base.NombreSubDirGeneral,
             Base.CodDDirNegocio,
             Base.NombreDirNegocio
end
