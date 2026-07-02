CREATE procedure [dbo].[sp_SDG_Contratacion_Actividades_DN]
	@pAño as int=2022
AS

BEGIN

	DECLARE @sql as nvarchar(max)
	DECLARE @sqlContratacionGrupo as nvarchar(max)
	DECLARE @sqlObjetivos as nvarchar(max)
	DECLARE @Sumarigrama as varchar(50)
	DECLARE @ContratacionGrupo as varchar(50)


	IF @pAño=YEAR(GETDATE())
		SET @Sumarigrama = 'Sumarigrama'
	ELSE
		SET @Sumarigrama = 'Sumarigrama' + CAST(@pAño as varchar(4))
	
	SET @ContratacionGrupo = '@ContratacionGrupo' + CAST(@pAño as varchar(4))

	-- #t sustituye a ContratacionGrupo = ContratacionELN + ContratacionSQL
	--CREATE TABLE #t (CodCentro varchar(3), Mercado varchar(20), Act1 varchar(2), Act2 varchar(2), Año int, Mes int, Importe float)


	-- Contratacion Elecnor UNION Contratacion SQL
	SET @sqlContratacionGrupo = '
				SELECT CT CodCentro, MERCADO Mercado, ACT1 Act1, ACT2 Act2, ' + CAST(@pAño as varchar(4)) + ' Año, MESAD Mes, IMPAD Importe
				FROM OPENQUERY(SIC, ''SELECT CT,MERCADO, ACT1,ACT2, MESAD, IMPAD 
										FROM S44DD901.ICOMERF.OFERREGU 
										WHERE AÑOAD = ' + CAST(@pAño as varchar(4)) + ' AND ADJUDICADA = ''''S'''''') 
										 AS ContratacionELN
				
				UNION ALL
				SELECT CodCentro, CASE WHEN ISNUMERIC(CodProv)=1 THEN ''Nacional'' ELSE ''Internacional'' END MERCADO, CodAct1 AS ACT1, CodAct2, ' + CAST(@pAño as varchar(4)) + ' Año, MONTH(FAdjudicacion) AS MESAD, ImporteContratado AS IMPAD
				FROM OfertasSQL OSQL --INNER JOIN Provincias P ON OSQL.CodProv = P.CDPRO
				WHERE OSQL.AñoAdjudicacion = ' + CAST(@pAño as varchar(4)) + '
				'


	SET @sqlObjetivos = '
				SELECT  Ac.Orden, Obj.CodDDirNegocio, Obj.NombreDirNegocio, Ac.Agrupacion, Obj.CDAC1, Obj.Mercado,
						SUM(ISNULL(Obj.Importe, 0)) AS Objetivos,
						0 Contratacion,
						0 Mes, Obj.Año
				FROM (
						SELECT DISTINCT Orden, Agrupacion, CDAC1,
								CASE WHEN CDAC1 IN (''04'', ''06'', ''09'')
								THEN CDAC1+CDAC2
								ELSE CASE WHEN CDAC1=''07'' 
										THEN ''08'' 
										ELSE CASE WHEN CDAC1+CDAC2=''0229'' THEN ''01'' ELSE CDAC1 END 
										END +''00''
								END CDAC
						FROM ActividadesSQL
						GROUP BY Agrupacion, Orden,
									CASE WHEN CDAC1 IN (''04'', ''06'', ''09'')
									THEN CDAC1+CDAC2
									ELSE CASE WHEN CDAC1=''07'' 
											THEN ''08'' 
											ELSE CASE WHEN CDAC1+CDAC2=''0229'' THEN ''01'' ELSE CDAC1 END 
											END +''00''
									END, ActividadesSQL.CDAC1, CDAC2
					) Ac
						LEFT OUTER JOIN (
											SELECT OASQL.Año, S.CodDDirNegocio, S.NombreDirNegocio, CDAC1,
													CASE WHEN CDAC1 IN (''04'', ''06'', ''09'')
													THEN CDAC1+CDAC2
													ELSE CASE WHEN CDAC1=''07'' 
														THEN ''08'' 
														ELSE CASE WHEN CDAC1+CDAC2=''0229'' THEN ''01'' ELSE CDAC1 END 
														END +''00''
													END CDAC,
													SUM(OASQL.Importe) AS Importe, OASQL.Mercado
											FROM ObjetivosActividadSQL OASQL 
													INNER JOIN ' + @Sumarigrama + ' S ON OASQL.CodCentro = S.CodCentro AND OASQL.Año = S.Año
											WHERE S.CodSubDirGeneral = 221
											GROUP BY OASQL.Año, S.CodDDirNegocio, S.NombreDirNegocio, OASQL.Mercado, 
													CASE WHEN CDAC1 IN (''04'', ''06'', ''09'')
													THEN CDAC1+CDAC2
													ELSE CASE WHEN CDAC1=''07'' 
														THEN ''08'' 
														ELSE CASE WHEN CDAC1+CDAC2=''0229'' THEN ''01'' ELSE CDAC1 END 
														END +''00''
													END, CDAC1					 
											) Obj ON Ac.CDAC = Obj.CDAC AND Ac.CDAC1 = Obj.CDAC1
				WHERE ISNULL(Obj.Mercado, N'''') <> ''''
				GROUP BY Ac.Orden, Ac.Agrupacion, Obj.CodDDirNegocio, Obj.NombreDirNegocio,  
						Obj.Año, Obj.Mercado, Obj.CDAC1
						
				'

	SET @sql = N'

				SELECT ASQL.Orden, S.CodDDirNegocio, S.NombreDirNegocio, ASQL.Agrupacion, CG.Act1,
						LEFT(CG.Mercado, 1) AS Pais, 
						0 Objetivos,
						SUM(CG.Importe) AS Contratacion, 
						CG.Mes, Cg.Año
				FROM ' + @Sumarigrama + ' S
						INNER JOIN (' + @sqlContratacionGrupo + ') CG ON S.CodCentro = CG.CodCentro 
						INNER JOIN ActividadesSQL ASQL ON CG.Act2 = ASQL.CDAC2 AND CG.Act1 = ASQL.CDAC1
				WHERE S.CodSubDirGeneral = 221
				GROUP BY ASQL.Orden, ASQL.Agrupacion, LEFT(CG.Mercado, 1), CG.Mes, CG.Año, 
						S.CodDDirNegocio, S.NombreDirNegocio, CG.Act1
				
				UNION ' + @sqlObjetivos + '
				
				
				
				--ORDER BY S.CodDDirNegocio, ASQL.Orden, LEFT(CG.Mercado, 1), CG.Mes

				'
	PRINT (@sql)
	EXEC (@sql)

END