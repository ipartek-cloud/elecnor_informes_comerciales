IF OBJECT_ID('[dbo].[sp_SDG_Contratacion_por_Actividades_WEB]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_SDG_Contratacion_por_Actividades_WEB];
GO

CREATE PROCEDURE [dbo].[sp_SDG_Contratacion_por_Actividades_WEB]
	@pAnio int = 2024,
	@pMes int = 5,
	@pCodSubDirGeneral varchar(3) = '221',
	@pLoginUsuario nvarchar(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20)

	SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad
	FROM dbo.WEB_Usuarios WITH (NOLOCK)
	WHERE Usuario = @pLoginUsuario

	SELECT S.* INTO #SumarigramaHistorico
	FROM dbo.SumarigramaHistorico S WITH (NOLOCK)
	WHERE S.Año IN (@pAnio, @pAnio - 1)
	  AND (S.CodSubDirGeneral = @pCodSubDirGeneral OR @pCodSubDirGeneral IS NULL)
	  AND (
		  @vPuesto = 'DG' OR @vPuesto IS NULL OR @pLoginUsuario IS NULL
		  OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)
		  OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)
		  OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)
		  OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)
		  OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)
	  );

	WITH
	CTE_Contratacion_Base AS (
		SELECT
			CT AS CodCentro,
			MERCADO AS Mercado,
			ACT1 AS Act1,
			ACT2 AS Act2,
			AÑOAD AS Anio,
			MESAD AS Mes,
			IMPAD AS Importe
		FROM SIC.S44DD901.ICOMERF.OFERREGU
		WHERE AÑOAD IN (@pAnio, @pAnio - 1)
		  AND ADJUDICADA = 'S'

		UNION ALL

		SELECT
			CodCentro,
			CASE WHEN ISNUMERIC(CodProv) = 1 THEN 'Nacional' ELSE 'Internacional' END AS Mercado,
			CodAct1 AS Act1,
			CodAct2 AS Act2,
			AñoAdjudicacion AS Anio,
			MONTH(FAdjudicacion) AS Mes,
			ImporteContratado AS Importe
		FROM OfertasSQL
		WHERE AñoAdjudicacion IN (@pAnio, @pAnio - 1)
	),

	CTE_Datos_Base AS (
		SELECT
			ASQL.Orden,
			S.CodDDirNegocio,
			S.NombreDirNegocio,
			ASQL.Agrupacion,
			CG.Act1,
			LEFT(CG.Mercado, 1) AS Pais,
			0.0 AS Objetivos,
			CG.Importe AS Contratacion,
			CG.Mes,
			CG.Anio AS Año
		FROM #SumarigramaHistorico S
		INNER JOIN CTE_Contratacion_Base CG ON S.CodCentro = CG.CodCentro AND S.Año = CG.Anio
		INNER JOIN ActividadesSQL ASQL ON CG.Act2 = ASQL.CDAC2 AND CG.Act1 = ASQL.CDAC1

		UNION ALL

		SELECT
			Ac.Orden,
			Obj.CodDDirNegocio,
			Obj.NombreDirNegocio,
			Ac.Agrupacion,
			Obj.CDAC1 AS Act1,
			Obj.Mercado AS Pais,
			Obj.Importe AS Objetivos,
			0.0 AS Contratacion,
			0 AS Mes,
			Obj.Año
		FROM (
			SELECT DISTINCT Orden, Agrupacion, CDAC1,
					CASE WHEN CDAC1 IN ('04', '06', '09')
					THEN CDAC1+CDAC2
					ELSE CASE WHEN CDAC1='07'
							THEN '08'
							ELSE CASE WHEN CDAC1+CDAC2='0229' THEN '01' ELSE CDAC1 END
							END +'00'
					END CDAC
			FROM ActividadesSQL
			GROUP BY Agrupacion, Orden,
						CASE WHEN CDAC1 IN ('04', '06', '09')
						THEN CDAC1+CDAC2
						ELSE CASE WHEN CDAC1='07'
								THEN '08'
								ELSE CASE WHEN CDAC1+CDAC2='0229' THEN '01' ELSE CDAC1 END
								END +'00'
						END, ActividadesSQL.CDAC1, CDAC2
		) Ac
		INNER JOIN (
			SELECT OASQL.Año, S.CodDDirNegocio, S.NombreDirNegocio, CDAC1,
					CASE WHEN CDAC1 IN ('04', '06', '09')
					THEN CDAC1+CDAC2
					ELSE CASE WHEN CDAC1='07'
						THEN '08'
						ELSE CASE WHEN CDAC1+CDAC2='0229' THEN '01' ELSE CDAC1 END
						END +'00'
					END CDAC,
					SUM(OASQL.Importe) AS Importe, OASQL.Mercado
			FROM ObjetivosActividadSQL OASQL
			INNER JOIN #SumarigramaHistorico S ON OASQL.CodCentro = S.CodCentro AND OASQL.Año = S.Año
			WHERE OASQL.Año IN (@pAnio, @pAnio - 1)
			GROUP BY OASQL.Año, S.CodDDirNegocio, S.NombreDirNegocio, OASQL.Mercado,
					CASE WHEN CDAC1 IN ('04', '06', '09')
					THEN CDAC1+CDAC2
					ELSE CASE WHEN CDAC1='07'
						THEN '08'
						ELSE CASE WHEN CDAC1+CDAC2='0229' THEN '01' ELSE CDAC1 END
						END +'00'
					END, CDAC1
		) Obj ON Ac.CDAC = Obj.CDAC AND Ac.CDAC1 = Obj.CDAC1
		WHERE ISNULL(Obj.Mercado, N'') <> ''
	),

	CTE_Anio_Actual AS (
		SELECT
			Orden,
			CodDDirNegocio,
			NombreDirNegocio,
			Agrupacion,
			Act1,
			Pais,
			Mes,
			SUM(Objetivos) AS Objetivos,
			SUM(Contratacion) AS Contratacion
		FROM CTE_Datos_Base
		WHERE Año = @pAnio AND Mes <= @pMes
		GROUP BY Orden, CodDDirNegocio, NombreDirNegocio, Agrupacion, Act1, Pais, Mes
	),

	CTE_Anio_Anterior AS (
		SELECT
			CodDDirNegocio,
			Agrupacion,
			Act1,
			Pais,
			Mes,
			SUM(Contratacion) AS Contratacion
		FROM CTE_Datos_Base
		WHERE Año = @pAnio - 1 AND Mes <= @pMes
		GROUP BY CodDDirNegocio, Agrupacion, Act1, Pais, Mes
	)

	SELECT
		t.Orden,
		t.CodDDirNegocio AS CodDirNegocio,
		CAST(t.NombreDirNegocio AS NVARCHAR(100)) AS NombreDirNegocio,
		CAST(t.Agrupacion AS NVARCHAR(100)) AS Agrupacion,
		t.Act1 AS ACT1,
		CAST(t.Pais AS NVARCHAR(10)) AS Mercado,
		SUM(ISNULL(t.Objetivos, 0)) AS Objetivos,
		SUM(ISNULL(t.Contratacion, 0)) AS Contrat,
		SUM(ISNULL(t_1.Contratacion, 0)) AS Contrat_1,
		@pAnio AS Año,
		@pLoginUsuario AS LoginUsuario
	FROM CTE_Anio_Actual t
	LEFT JOIN CTE_Anio_Anterior t_1 ON t.CodDDirNegocio = t_1.CodDDirNegocio
									AND t.Agrupacion = t_1.Agrupacion
									AND t.Act1 = t_1.Act1
									AND t.Mes = t_1.Mes
									AND t.Pais = t_1.Pais
	GROUP BY t.Orden, t.CodDDirNegocio, t.NombreDirNegocio, t.Agrupacion, t.Act1, t.Pais
	ORDER BY t.Agrupacion, t.Act1, t.Pais DESC;

	DROP TABLE #SumarigramaHistorico;
END
