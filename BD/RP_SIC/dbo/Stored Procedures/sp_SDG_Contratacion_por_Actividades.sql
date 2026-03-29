CREATE PROCEDURE [dbo].[sp_SDG_Contratacion_por_Actividades]
	@pAño int = 2023,
	@pMes as int = 2
AS
BEGIN

	DECLARE @pAño_1 int=@pAño-1

	DECLARE @t as TABLE (Orden int, CodDirNegocio varchar(3), NombreDirNegocio varchar(100), Agrupacion varchar(100), ACT1 varchar(2), Pais varchar(1), Objetivos float, Contratacion float, Mes int, Año int)
	DECLARE @t_1 as TABLE (Orden int, CodDirNegocio varchar(3), NombreDirNegocio varchar(100), Agrupacion varchar(100), ACT1 varchar(2), Pais varchar(1), Objetivos float, Contratacion float, Mes int, Año int)

	INSERT INTO @t
	exec [sp_SDG_Contratacion_Actividades_DN] @pAño 

	INSERT INTO @t_1
	exec [sp_SDG_Contratacion_Actividades_DN] @pAño_1

	--SELECT * FROM @t where CodDirNegocio='934'
	--SELECT *  FROM @t_1 where ACT1 IN ('07','08')--where Agrupacion='Electricidad' and CodDirNegocio='500'

	--SELECT t.Orden, t.Agrupacion, t.Pais Mercado, t.Objetivos, t.Contratacion Contrat, t_1. Contratacion Contrat_1, t.Año
	--FROM @t t LEFT JOIN @t_1 t_1 ON t.CodDirNegocio=t_1.CodDirNegocio AND t.Agrupacion=t_1.Agrupacion AND t.Mes=t_1.Mes AND t.Pais=t_1.Pais

	SELECT t.Orden, t.CodDirNegocio, t.NombreDirNegocio, t.Agrupacion, t.ACT1, t.Pais Mercado, SUM(ISNULL(t.Objetivos,0)) Objetivos, SUM(ISNULL(t.Contratacion,0)) Contrat, SUM(ISNULL(t_1. Contratacion,0)) Contrat_1, t.Año
	FROM @t t LEFT JOIN @t_1 t_1 ON t.CodDirNegocio=t_1.CodDirNegocio AND t.Agrupacion=t_1.Agrupacion AND t.ACT1=t_1.ACT1 AND t.Mes=t_1.Mes AND t.Pais=t_1.Pais
	WHERE t.Mes <= @pMes --t.Agrupacion='Electricidad' and t.CodDirNegocio='500'
	GROUP BY t.Orden, t.CodDirNegocio, t.NombreDirNegocio, t.Agrupacion, t. ACT1, t.Pais, t.Año--, t.CodDirNegocio, t.NombreDirNegocio

END