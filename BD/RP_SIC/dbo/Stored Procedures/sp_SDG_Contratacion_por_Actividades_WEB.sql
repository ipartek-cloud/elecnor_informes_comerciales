IF OBJECT_ID('[dbo].[sp_SDG_Contratacion_por_Actividades_WEB]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_SDG_Contratacion_por_Actividades_WEB];
GO

CREATE PROCEDURE [dbo].[sp_SDG_Contratacion_por_Actividades_WEB]
	@pAño int = 2024,
	@pMes int = 5,
	@pCodSubDirGeneral varchar(3) = '221',
	@pLoginUsuario nvarchar(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	-- ---------------------------------------------------------------
	-- BLOQUE RLS: Filtrado de #SumarigramaHistorico por permisos de usuario
	-- ---------------------------------------------------------------
	DECLARE @vPuesto nvarchar(10), @vCodEntidad nvarchar(20)

	SELECT @vPuesto = Puesto, @vCodEntidad = CodEntidad 
	FROM dbo.WEB_Usuarios WITH (NOLOCK) 
	WHERE Usuario = @pLoginUsuario

	SELECT S.* INTO #SumarigramaHistorico 
	FROM dbo.SumarigramaHistorico S WITH (NOLOCK)
	WHERE S.Año IN (@pAño, @pAño - 1)
	  AND (S.CodSubDirGeneral = @pCodSubDirGeneral OR @pCodSubDirGeneral IS NULL)
	  AND (
		  @vPuesto = 'DG' OR @vPuesto IS NULL OR @pLoginUsuario IS NULL
		  OR (@vPuesto = 'SDG'  AND S.CodSubDirGeneral = @vCodEntidad)
		  OR (@vPuesto = 'DN'   AND S.CodDDirNegocio = @vCodEntidad)
		  OR (@vPuesto = 'AREA' AND S.CodSubDirNegocioArea = @vCodEntidad)
		  OR (@vPuesto = 'DEL'  AND S.CodDelegacion = @vCodEntidad)
		  OR (@vPuesto = 'CT'   AND S.CodCentro = @vCodEntidad)
	  );
	-- ---------------------------------------------------------------

	WITH 
	-- 1. Obtener la Contratacion Base consolidada para el anio actual y anterior
	CTE_Contratacion_Base AS (
		-- Contratacion historica de AS400 (SIC)
		SELECT 
			CT AS CodCentro, 
			MERCADO AS Mercado, 
			ACT1 AS Act1, 
			ACT2 AS Act2, 
			AÑOAD AS Anio, 
			MESAD AS Mes, 
			IMPAD AS Importe
		FROM SIC.S44DD901.ICOMERF.OFERREGU 
		WHERE AÑOAD IN (@pAño, @pAño - 1) 
		  AND ADJUDICADA = 'S'

		UNION ALL

		-- Contratacion registrada directamente en SQL Server
		SELECT 
			CodCentro, 
			CASE WHEN ISNUMERIC(CodProv) = 1 THEN 'Nacional' ELSE 'Internacional' END AS Mercado, 
			CodAct1 AS Act1, 
			CodAct2 AS Act2, 
			AñoAdjudicacion AS Anio, 
			MONTH(FAdjudicacion) AS Mes, 
			ImporteContratado AS Importe
		FROM OfertasSQL
		WHERE AñoAdjudicacion IN (@pAño, @pAño - 1)
	),

	-- 2. Consolidar Contrataciones y Objetivos uniendo el Sumarigrama historico filtrado y Actividades
	CTE_Datos_Base AS (
		-- Contratacion cruzada con el Sumarigrama filtrado por RLS
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

		-- Objetivos cruzados con el Sumarigrama filtrado por RLS
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
			WHERE OASQL.Año IN (@pAño, @pAño - 1)
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

	-- 3. Agrupacion temporal para el Anio Actual (meses acumulados)
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
		WHERE Año = @pAño AND Mes <= @pMes
		GROUP BY Orden, CodDDirNegocio, NombreDirNegocio, Agrupacion, Act1, Pais, Mes
	),

	-- 4. Agrupacion temporal para el Anio Anterior (meses acumulados)
	CTE_Anio_Anterior AS (
		SELECT 
			CodDDirNegocio, 
			Agrupacion, 
			Act1, 
			Pais, 
			Mes,
			SUM(Contratacion) AS Contratacion
		FROM CTE_Datos_Base
		WHERE Año = @pAño - 1 AND Mes <= @pMes
		GROUP BY CodDDirNegocio, Agrupacion, Act1, Pais, Mes
	)

	-- 5. Consulta Final: LEFT JOIN para comparar Anio Actual vs Anio Anterior
	SELECT 
		t.Orden, 
		t.CodDDirNegocio AS CodDirNegocio, 
		t.NombreDirNegocio, 
		t.Agrupacion, 
		t.Act1 AS ACT1, 
		t.Pais AS Mercado, 
		SUM(ISNULL(t.Objetivos, 0)) AS Objetivos, 
		SUM(ISNULL(t.Contratacion, 0)) AS Contrat, 
		SUM(ISNULL(t_1.Contratacion, 0)) AS Contrat_1, 
		@pAño AS Año
	FROM CTE_Anio_Actual t
	LEFT JOIN CTE_Anio_Anterior t_1 ON t.CodDDirNegocio = t_1.CodDDirNegocio 
									AND t.Agrupacion = t_1.Agrupacion 
									AND t.Act1 = t_1.Act1 
									AND t.Mes = t_1.Mes 
									AND t.Pais = t_1.Pais
	GROUP BY t.Orden, t.CodDDirNegocio, t.NombreDirNegocio, t.Agrupacion, t.Act1, t.Pais
	ORDER BY t.CodDDirNegocio, t.Orden, t.Pais DESC;

	DROP TABLE #SumarigramaHistorico;
END
