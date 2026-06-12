CREATE PROCEDURE [dbo].[spCarteraContratacionDetalle_DGDesarrolloInternacional_DosAños_BACKUP]
	@pAño int,
	@pMes int,
	@pTodoInternacional int=1, -- =1 => todo / <>1 => Internacional
	@pLimiteImporte float =10000,
	@pLimitePaises int = 1000,
	@pInforme as varchar(10) = '9.1'
	AS
BEGIN

CREATE TABLE #Ofertas (CodOferta varchar(10), ImporteContratado float)
	INSERT INTO #Ofertas
	EXEC [spContratacion_PorOferta] @pAño, @pMes

--CREATE TABLE #OfertasAñoAnterior (CodOferta varchar(10), ImporteContratadoAñoAnterior float)
 	DECLARE @AñoAnterior int = @pAño - 1
-- 	INSERT INTO #OfertasAñoAnterior
-- 	EXEC [spContratacion_PorOferta] @AñoAnterior, @pMes

	DECLARE @Sql as varchar(max)
	CREATE TABLE #CarteraPorPais (Pais varchar(100), ImporteCarteraPais float, ImporteCarteraPaisAñoAnterior float)
	CREATE TABLE #CarteraPorDN  (DN varchar(100), ImporteCarteraDN float, ImporteCarteraDNAñoAnterior float)
	CREATE TABLE #CarteraPorDNPais  (DN varchar(100), Pais varchar(100), ImporteCarteraDNPais float, ImporteCarteraDNPaisAñoAnterior float, N int)

	IF @pInforme= '6'
	BEGIN
		SET @Sql = '
		SELECT AnioInforme, MesInforme, REPLACE(DesOferta, '''''''', '''') DesOferta, REPLACE(NomCliente, '''''''', '''') NomCliente
				, Sum(ImporteEUR) AS SumaDeImporteEUR
				, Sum(ISNULL(ImporteContratado, 0)) AS SumaDeImporteContratado
		FROM CarterasContratacionSQL C
				LEFT JOIN SumarigramaHistorico S ON C.CentroChar = S.CodCentro AND C.AnioInforme = S.Año
				LEFT JOIN #Ofertas O ON C.CodOferta=O.CodOferta
		WHERE C.AnioInforme = ' + CAST(@pAño as varchar(4)) + ' AND C.MesInforme = ' + CAST(@pMes as varchar(2)) + '
			AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
		GROUP BY C.AnioInforme, C.MesInforme, C.DesOferta, C.NomCliente
		HAVING Sum(ImporteEUR) > ISNULL(' + CAST(@pLimiteImporte as varchar(35)) + ', 10000)
		ORDER BY C.AnioInforme, C.MesInforme, Sum(C.ImporteEUR) DESC;
		'
		--PRINT (@Sql)
		EXEC (@Sql)
	END

	IF @pInforme= '9.1'
	BEGIN

		SET @Sql = '
			SELECT TOP ' + CAST(@pLimitePaises as varchar(5)) + ' DatosA.Pais, Sum(DatosA.TotAño) ImporteCarteraPais, ISNULL(Sum(DatosA_1.TotAño), 0) ImporteCarteraPaisAñoAnterior
			FROM (' +
		           'SELECT a.AnioInforme, a.MesInforme, a.Pais,
                             S.CodDirGeneral,
                             S.CodSubDirGeneral,
                             S.CodDDirNegocio,
                             SUM(ISNULL(a.ImporteEUR, 0)) AS TotAño
                       FROM CarterasContratacionSQL AS a
                                INNER JOIN SumarigramaHistorico S
                                           ON a.CentroChar = S.CodCentro
                                               AND a.AnioInforme = S.Año
                       WHERE a.AnioInforme = ' + CAST(@pAño as varchar(4)) + '
                           AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                           AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR a.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                       GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio) DatosA
		           LEFT JOIN (
                                -- Año anterior (2025)
                                SELECT a.AnioInforme, a.MesInforme, a.Pais,
                                   S.CodDirGeneral,
                                   S.CodSubDirGeneral,
                                   S.CodDDirNegocio,
                                   ISNULL(SUM(ISNULL(a.ImporteEUR, 0)), 0) AS TotAño
                                FROM CarterasContratacionSQL AS a
                                         INNER JOIN SumarigramaHistorico S
                                                    ON a.CentroChar = S.CodCentro
                                                        AND a.AnioInforme = S.Año
                                WHERE a.AnioInforme = ' + CAST(@AñoAnterior as varchar(4)) + '
                                      AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                                      AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR a.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                                GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio) DatosA_1
        		           ON DatosA.AnioInforme - 1 = DatosA_1.AnioInforme AND DatosA.MesInforme = DatosA_1.MesInforme AND
                                DatosA.Pais  = DatosA_1.Pais AND
                                DatosA.CodDirGeneral = DatosA_1.CodDirGeneral AND
                                DatosA.CodSubDirGeneral = DatosA_1.CodSubDirGeneral AND
                                DatosA.CodDDirNegocio = DatosA_1.CodDDirNegocio
			WHERE DatosA.AnioInforme=' + CAST(@pAño as varchar(4)) + '
		            AND DatosA.MesInforme=' + CAST(@pMes as varchar(2)) + '
        		    AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR DatosA.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
			GROUP BY DatosA.Pais
			ORDER BY Sum(DatosA.TotAño) DESC;
			'
		INSERT INTO #CarteraPorPais
		EXEC (@Sql)

		SET @Sql = '
		SELECT CASE WHEN P.Pais=''Nacional'' THEN ''España'' ELSE P.Pais END Pais, P.ImporteCarteraPais
				, CASE WHEN q.AnioInforme IS NULL THEN ' + CAST(@pAño as varchar(4)) + ' ELSE q.AnioInforme END AnioInforme
				, CASE WHEN q.MesInforme IS NULL THEN ' + CAST(@pMes as varchar(2)) + ' ELSE q.MesInforme END MesInforme
				, ISNULL(q.DesOferta, '''') DesOferta
				, ISNULL(q.NomCliente, '''') NomCliente
				, ISNULL(q.ImporteCarteraOferta, 0) ImporteCarteraOferta
				, ISNULL(q.ImporteContratadoOferta, 0) ImporteContratadoOferta
		FROM #CarteraPorPais P
				LEFT JOIN (

		SELECT AnioInforme, MesInforme
				, P.Pais, P.ImporteCarteraPais
				, REPLACE(DesOferta, '''''''', '''') DesOferta, REPLACE(NomCliente, '''''''', '''') NomCliente
				, Sum(ImporteEUR) AS ImporteCarteraOferta
				, Sum(ISNULL(ImporteContratado, 0)) AS ImporteContratadoOferta
		FROM #CarteraPorPais P
				LEFT JOIN CarterasContratacionSQL C ON P.Pais=C.Pais
				LEFT JOIN Sumarigrama S ON C.CentroChar = S.CodCentro AND C.AnioInforme = S.Año
				LEFT JOIN #Ofertas O ON C.CodOferta=O.CodOferta
		WHERE (C.AnioInforme IS NULL OR (C.AnioInforme = ' + CAST(@pAño as varchar(4)) + ' AND C.MesInforme = ' + CAST(@pMes as varchar(2)) + '))
			AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR C.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
		GROUP BY C.AnioInforme, C.MesInforme, C.DesOferta, C.NomCliente, P.Pais, P.ImporteCarteraPais
		HAVING Sum(ImporteEUR) > ISNULL(' + CAST(@pLimiteImporte as varchar(35)) + ', 10000)
				) q ON P.Pais=q.Pais
		WHERE (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR P.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
		ORDER BY CASE WHEN q.AnioInforme IS NULL THEN ' + CAST(@pAño as varchar(4)) + ' ELSE q.AnioInforme END
				, CASE WHEN q.MesInforme IS NULL THEN ' + CAST(@pMes as varchar(2)) + ' ELSE q.MesInforme END
				, P.ImporteCarteraPais DESC, q.ImporteCarteraOferta DESC;
		'

		SET @Sql = '
		SELECT CASE WHEN P.Pais=''Nacional'' THEN ''España'' ELSE P.Pais END Pais, P.ImporteCarteraPais, P.ImporteCarteraPaisAñoAnterior
				, CASE WHEN q.AnioInforme IS NULL THEN ' + CAST(@pAño as varchar(4)) + ' ELSE q.AnioInforme END AnioInforme
				, CASE WHEN q.MesInforme IS NULL THEN ' + CAST(@pMes as varchar(2)) + ' ELSE q.MesInforme END MesInforme
				, ISNULL(q.DesOferta, '''') DesOferta
				, ISNULL(q.NomCliente, '''') NomCliente
				, ISNULL(q.ImporteCarteraOferta, 0) ImporteCarteraOferta
				, ISNULL(q.ImporteContratadoOferta, 0) ImporteContratadoOferta
				, ISNULL(q.ImporteCarteraOfertaAñoAnterior, 0) ImporteCarteraOfertaAñoAnterior
		FROM #CarteraPorPais P
				LEFT JOIN (

		SELECT DatosA.AnioInforme
                     , DatosA.MesInforme
				, P.Pais, P.ImporteCarteraPais
				, REPLACE(DatosA.DesOferta, '''''''', '''') DesOferta
		        , REPLACE(DatosA.NomCliente, '''''''', '''') NomCliente
				, Sum(DatosA.TotAño) AS ImporteCarteraOferta
				, Sum(ISNULL(ImporteContratado, 0)) AS ImporteContratadoOferta
				, ISNULL(Sum(DatosA_1.TotAñoAnterior), 0) AS ImporteCarteraOfertaAñoAnterior
		FROM #CarteraPorPais P
            LEFT JOIN (
		           SELECT a.AnioInforme,
                           a.MesInforme,
                           a.Pais,
                           S.CodDirGeneral,
                           S.CodSubDirGeneral,
                           S.CodDDirNegocio,
                           S.NombreDirNegocio,
                           a.CodOferta,
                           a.DesOferta,
                           a.NomCliente,
                           SUM(ISNULL(a.ImporteEUR, 0)) AS TotAño
                    FROM CarterasContratacionSQL AS a
                             INNER JOIN SumarigramaHistorico S
                                        ON a.CentroChar = S.CodCentro
                                            AND a.AnioInforme = S.Año
                    WHERE a.AnioInforme = ' + CAST(@pAño as varchar(4)) + '
                      AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                      AND (' + CAST(@pTodoInternacional as varchar(1)) + ' = 1 OR a.Pais <> ''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                    GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio
                           , S.NombreDirNegocio, a.DesOferta, a.NomCliente, a.CodOferta
                    ) DatosA
                        ON P.Pais = DatosA.Pais
          LEFT JOIN (
		           SELECT a.AnioInforme,
                           a.MesInforme,
                           a.Pais,
                           S.CodDirGeneral,
                           S.CodSubDirGeneral,
                           S.CodDDirNegocio,
                           S.NombreDirNegocio,
                           a.CodOferta,
                           a.DesOferta,
                           a.NomCliente,
                           SUM(ISNULL(a.ImporteEUR, 0)) AS TotAñoAnterior
                    FROM CarterasContratacionSQL AS a
                             INNER JOIN SumarigramaHistorico S
                                        ON a.CentroChar = S.CodCentro
                                            AND a.AnioInforme = S.Año
                    WHERE a.AnioInforme = ' + CAST(@AñoAnterior as varchar(4)) + '
                      AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                      AND (' + CAST(@pTodoInternacional as varchar(1)) + ' = 1 OR a.Pais <> ''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                    GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio
                           , S.NombreDirNegocio, a.DesOferta, a.NomCliente
                           , a.CodOferta
                    ) DaTosA_1
                       ON DatosA.AnioInforme - 1 = DatosA_1.AnioInforme AND
                          DatosA.MesInforme = DatosA_1.MesInforme AND
                          DatosA.Pais = DatosA_1.Pais AND
                          DatosA.CodDirGeneral = DatosA_1.CodDirGeneral AND
                          DatosA.CodSubDirGeneral = DatosA_1.CodSubDirGeneral AND
                          DatosA.CodDDirNegocio = DatosA_1.CodDDirNegocio AND
                          DatosA.CodOferta = DatosA_1.CodOferta

				LEFT JOIN #Ofertas O ON DatosA.CodOferta=O.CodOferta
		WHERE (DatosA.AnioInforme IS NULL OR (DatosA.AnioInforme = ' + CAST(@pAño as varchar(4)) + ' AND DatosA.MesInforme = ' + CAST(@pMes as varchar(2)) + '))
			AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR DatosA.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
		GROUP BY DatosA.AnioInforme, DatosA.MesInforme, DatosA.DesOferta, DatosA.NomCliente, P.Pais, P.ImporteCarteraPais, P.ImporteCarteraPaisAñoAnterior
		HAVING Sum(DatosA.TotAño) > ISNULL(' + CAST(@pLimiteImporte as varchar(35)) + ', 10000)
				) q ON P.Pais=q.Pais
		WHERE (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR P.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
		ORDER BY CASE WHEN q.AnioInforme IS NULL THEN ' + CAST(@pAño as varchar(4)) + ' ELSE q.AnioInforme END
				, CASE WHEN q.MesInforme IS NULL THEN ' + CAST(@pMes as varchar(2)) + ' ELSE q.MesInforme END
				, P.ImporteCarteraPais DESC, q.ImporteCarteraOferta DESC;
		'

--		PRINT (@Sql)
		EXEC (@Sql)

	END

	IF @pInforme= '8.1'
	BEGIN

		SET @Sql = '
			SELECT TOP ' + CAST(@pLimitePaises as varchar(5)) + ' DatosA.Pais, Sum(DatosA.TotAño) ImporteCarteraPais, ISNULL(Sum(DatosA_1.TotAño), 0) ImporteCarteraPaisAñoAnterior
			FROM (' +
		           'SELECT a.AnioInforme, a.MesInforme, a.Pais,
                             S.CodDirGeneral,
                             S.CodSubDirGeneral,
                             S.CodDDirNegocio,
                             SUM(ISNULL(a.ImporteEUR, 0)) AS TotAño
                       FROM CarterasContratacionSQL AS a
                                INNER JOIN SumarigramaHistorico S
                                           ON a.CentroChar = S.CodCentro
                                               AND a.AnioInforme = S.Año
                       WHERE a.AnioInforme = ' + CAST(@pAño as varchar(4)) + '
                           AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                           AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR a.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                       GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio) DatosA
		           LEFT JOIN (
                                -- Año anterior (2025)
                                SELECT a.AnioInforme, a.MesInforme, a.Pais,
                                   S.CodDirGeneral,
                                   S.CodSubDirGeneral,
                                   S.CodDDirNegocio,
                                   ISNULL(SUM(ISNULL(a.ImporteEUR, 0)), 0) AS TotAño
                                FROM CarterasContratacionSQL AS a
                                         INNER JOIN SumarigramaHistorico S
                                                    ON a.CentroChar = S.CodCentro
                                                        AND a.AnioInforme = S.Año
                                WHERE a.AnioInforme = ' + CAST(@AñoAnterior as varchar(4)) + '
                                      AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                                      AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR a.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                                GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio) DatosA_1
        		           ON DatosA.AnioInforme - 1 = DatosA_1.AnioInforme AND DatosA.MesInforme = DatosA_1.MesInforme AND
                                DatosA.Pais  = DatosA_1.Pais AND
                                DatosA.CodDirGeneral = DatosA_1.CodDirGeneral AND
                                DatosA.CodSubDirGeneral = DatosA_1.CodSubDirGeneral AND
                                DatosA.CodDDirNegocio = DatosA_1.CodDDirNegocio
			WHERE DatosA.AnioInforme=' + CAST(@pAño as varchar(4)) + '
		            AND DatosA.MesInforme=' + CAST(@pMes as varchar(2)) + '
        		    AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR DatosA.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
			GROUP BY DatosA.Pais
			ORDER BY Sum(DatosA.TotAño) DESC;
			'
		INSERT INTO #CarteraPorPais
		EXEC (@Sql)

		SET @Sql = '
			SELECT DatosA.CodDDirNegocio, Sum(DatosA.TotAño) ImporteCarteraDN, ISNULL(Sum(DatosA_1.TotAño), 0) ImporteCarteraDNAñoAnterior
			FROM (' +
		           'SELECT a.AnioInforme, a.MesInforme, a.Pais,
                             S.CodDirGeneral,
                             S.CodSubDirGeneral,
                             S.CodDDirNegocio,
                             SUM(ISNULL(a.ImporteEUR, 0)) AS TotAño
                       FROM CarterasContratacionSQL AS a
                                INNER JOIN SumarigramaHistorico S
                                           ON a.CentroChar = S.CodCentro
                                               AND a.AnioInforme = S.Año
                       WHERE a.AnioInforme = ' + CAST(@pAño as varchar(4)) + '
                           AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                           AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR a.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                       GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio) DatosA
		           LEFT JOIN (
                                -- Año anterior (2025)
                                SELECT a.AnioInforme, a.MesInforme, a.Pais,
                                   S.CodDirGeneral,
                                   S.CodSubDirGeneral,
                                   S.CodDDirNegocio,
                                   ISNULL(SUM(ISNULL(a.ImporteEUR, 0)), 0) AS TotAño
                                FROM CarterasContratacionSQL AS a
                                         INNER JOIN SumarigramaHistorico S
                                                    ON a.CentroChar = S.CodCentro
                                                        AND a.AnioInforme = S.Año
                                WHERE a.AnioInforme = ' + CAST(@AñoAnterior as varchar(4)) + '
                                      AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                                      AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR a.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                                GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio) DatosA_1
        		           ON DatosA.AnioInforme - 1 = DatosA_1.AnioInforme AND DatosA.MesInforme = DatosA_1.MesInforme AND
                                DatosA.Pais = DatosA_1.Pais AND
                                DatosA.CodDirGeneral = DatosA_1.CodDirGeneral AND
                                DatosA.CodSubDirGeneral = DatosA_1.CodSubDirGeneral AND
                                DatosA.CodDDirNegocio = DatosA_1.CodDDirNegocio
			WHERE DatosA.AnioInforme=' + CAST(@pAño as varchar(4)) + '
		            AND DatosA.MesInforme=' + CAST(@pMes as varchar(2)) + '
        		    AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR DatosA.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
			GROUP BY DatosA.CodDDirNegocio
			ORDER BY Sum(DatosA.TotAño) DESC;
			'
		INSERT INTO #CarteraPorDN
		EXEC (@Sql)

		SET @Sql = 'SELECT DN, Pais, ImporteCarteraDN, ImporteCarteraDNAñoAnterior, N
			FROM (
		        SELECT DN, Pais, ImporteCarteraDN, ImporteCarteraDNAñoAnterior, ROW_NUMBER() OVER(PARTITION BY DN ORDER BY ImporteCarteraDN DESC) N
				FROM (
                    SELECT DatosA.CodDDirNegocio DN, DatosA.Pais, Sum(DatosA.TotAño) ImporteCarteraDN, ISNULL(Sum(DatosA_1.TotAño), 0) ImporteCarteraDNAñoAnterior
                    FROM (' +
                           'SELECT a.AnioInforme, a.MesInforme, a.Pais,
                                     S.CodDirGeneral,
                                     S.CodSubDirGeneral,
                                     S.CodDDirNegocio,
                                     SUM(ISNULL(a.ImporteEUR, 0)) AS TotAño
                              FROM CarterasContratacionSQL AS a
                                       INNER JOIN SumarigramaHistorico S
                                                  ON a.CentroChar = S.CodCentro
                                                      AND a.AnioInforme = S.Año
                              WHERE a.AnioInforme = ' + CAST(@pAño as varchar(4)) + '
                                  AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                                  AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR a.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                              GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio) DatosA
                           LEFT JOIN (
                                        -- Año anterior (2025)
                                        SELECT a.AnioInforme, a.MesInforme, a.Pais,
                                           S.CodDirGeneral,
                                           S.CodSubDirGeneral,
                                           S.CodDDirNegocio,
                                           ISNULL(SUM(ISNULL(a.ImporteEUR, 0)), 0) AS TotAño
                                        FROM CarterasContratacionSQL AS a
                                                 INNER JOIN SumarigramaHistorico S
                                                            ON a.CentroChar = S.CodCentro
                                                                AND a.AnioInforme = S.Año
                                        WHERE a.AnioInforme = ' + CAST(@AñoAnterior as varchar(4)) + '
                                              AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                                              AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR a.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                                        GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio) DatosA_1
                                   ON DatosA.AnioInforme - 1 = DatosA_1.AnioInforme AND DatosA.MesInforme = DatosA_1.MesInforme AND
                                        DatosA.Pais = DatosA_1.Pais AND
                                        DatosA.CodDirGeneral = DatosA_1.CodDirGeneral AND
                                        DatosA.CodSubDirGeneral = DatosA_1.CodSubDirGeneral AND
                                        DatosA.CodDDirNegocio = DatosA_1.CodDDirNegocio
                    WHERE DatosA.AnioInforme=' + CAST(@pAño as varchar(4)) + '
                            AND DatosA.MesInforme=' + CAST(@pMes as varchar(2)) + '
                            AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR DatosA.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                    GROUP BY DatosA.CodDDirNegocio, DatosA.Pais
                    --ORDER BY DatosA.CodDDirNegocio, Sum(DatosA.TotAño) DESC;
					) q
			) r 
			WHERE r.N <= ' + CAST(@pLimitePaises as varchar(5)) 

		INSERT INTO #CarteraPorDNPais
		EXEC (@Sql)

		--SELECT '#CarteraPorDN', * FROM #CarteraPorDN

		SET @Sql = '
			SELECT CASE WHEN P.Pais=''Nacional'' THEN ''España'' ELSE P.Pais END Pais
		            , P.ImporteCarteraDNPais ImporteCarteraPais
		            , ISNULL(q.ImporteCarteraDN, 0) ImporteCarteraDN
					, CASE WHEN q.AnioInforme IS NULL THEN ' + CAST(@pAño as varchar(4)) + ' ELSE q.AnioInforme END AnioInforme
					, CASE WHEN q.MesInforme IS NULL THEN ' + CAST(@pMes as varchar(2)) + ' ELSE q.MesInforme END MesInforme
					, q.CodSubDirGeneral
					, q.CodDDirNegocio, q.NombreDirNegocio
					, ISNULL(q.DesOferta, '''') DesOferta
					, ISNULL(q.NomCliente, '''') NomCliente
					, ISNULL(q.ImporteCarteraOferta, 0) ImporteCarteraOferta
					, ISNULL(q.ImporteContratadoOferta, 0) ImporteContratadoOferta

		            , ISNULL(P.ImporteCarteraDNPaisAñoAnterior, 0) ImporteCarteraPaisAñoAnterior
		            , ISNULL(q.ImporteCarteraDNAñoAnterior, 0) ImporteCarteraDNAñoAnterior
--					, ISNULL(q.ImporteContratadoOfertaAñoAnterior, 0) ImporteContratadoOfertaAñoAnterior
					, ISNULL(q.ImporteCarteraOfertaAñoAnterior, 0) ImporteCarteraOfertaAñoAnterior

			FROM #CarteraPorDNPais P
					LEFT JOIN (

			SELECT DatosA.AnioInforme
                     , DatosA.MesInforme
                     , DatosA.CodSubDirGeneral
                     , DatosA.CodDDirNegocio
                     , DatosA.NombreDirNegocio
		            , DN.ImporteCarteraDN, DN.ImporteCarteraDNAñoAnterior
					, P.Pais, P.ImporteCarteraDNPais
					, REPLACE(DatosA.DesOferta, '''''''', '''') DesOferta
		            , REPLACE(DatosA.NomCliente, '''''''', '''') NomCliente
					, Sum(DatosA.TotAño) AS ImporteCarteraOferta
                    , ISNULL(Sum(DatosA_1.TotAñoAnterior), 0) AS   ImporteCarteraOfertaAñoAnterior
 					, Sum(ISNULL(O.ImporteContratado, 0)) AS ImporteContratadoOferta
-- 					, Sum(ISNULL(OAñoAnterior.ImporteContratadoAñoAnterior, 0)) AS ImporteContratadoOfertaAñoAnterior
			FROM #CarteraPorDNPais P
         LEFT JOIN (
		           SELECT a.AnioInforme,
                           a.MesInforme,
                           a.Pais,
                           S.CodDirGeneral,
                           S.CodSubDirGeneral,
                           S.CodDDirNegocio,
                           S.NombreDirNegocio,
                           a.CodOferta,
                           a.DesOferta,
                           a.NomCliente,
                           SUM(ISNULL(a.ImporteEUR, 0)) AS TotAño
                    FROM CarterasContratacionSQL AS a
                             INNER JOIN SumarigramaHistorico S
                                        ON a.CentroChar = S.CodCentro
                                            AND a.AnioInforme = S.Año
                    WHERE a.AnioInforme = ' + CAST(@pAño as varchar(4)) + '
                      AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                      AND (' + CAST(@pTodoInternacional as varchar(1)) + ' = 1 OR a.Pais <> ''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                    GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio
                           , S.NombreDirNegocio, a.DesOferta, a.NomCliente, a.CodOferta
                    ) DatosA
                        ON P.Pais = DatosA.Pais AND P.DN = DatosA.CodDDirNegocio

         LEFT JOIN (
		           SELECT a.AnioInforme,
                           a.MesInforme,
                           a.Pais,
                           S.CodDirGeneral,
                           S.CodSubDirGeneral,
                           S.CodDDirNegocio,
                           S.NombreDirNegocio,
                           a.CodOferta,
                           a.DesOferta,
                           a.NomCliente,
                           SUM(ISNULL(a.ImporteEUR, 0)) AS TotAñoAnterior
                    FROM CarterasContratacionSQL AS a
                             INNER JOIN SumarigramaHistorico S
                                        ON a.CentroChar = S.CodCentro
                                            AND a.AnioInforme = S.Año
                    WHERE a.AnioInforme = ' + CAST(@AñoAnterior as varchar(4)) + '
                      AND a.MesInforme = ' + CAST(@pMes as varchar(2)) + '
                      AND (' + CAST(@pTodoInternacional as varchar(1)) + ' = 1 OR a.Pais <> ''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
                    GROUP BY a.AnioInforme, a.MesInforme, a.Pais, S.CodDirGeneral, S.CodSubDirGeneral, S.CodDDirNegocio
                           , S.NombreDirNegocio, a.DesOferta, a.NomCliente
                           , a.CodOferta
                    ) DaTosA_1
                       ON DatosA.AnioInforme - 1 = DatosA_1.AnioInforme AND
                          DatosA.MesInforme = DatosA_1.MesInforme AND
                          DatosA.Pais = DatosA_1.Pais AND
                          DatosA.CodDirGeneral = DatosA_1.CodDirGeneral AND
                          DatosA.CodSubDirGeneral = DatosA_1.CodSubDirGeneral AND
                          DatosA.CodDDirNegocio = DatosA_1.CodDDirNegocio AND
                          DatosA.CodOferta = DatosA_1.CodOferta
					LEFT JOIN #CarteraPorDN DN ON DatosA.CodDDirNegocio = DN.DN AND DatosA.AnioInforme=' + CAST(@pAño as varchar(4)) + '
					LEFT JOIN #Ofertas O ON DatosA.CodOferta=O.CodOferta
					--LEFT JOIN #OfertasAñoAnterior OAñoAnterior ON DatosA.CodOferta=OAñoAnterior.CodOferta
			WHERE (DatosA.AnioInforme IS NULL OR (DatosA.AnioInforme = ' + CAST(@pAño as varchar(4)) + ' AND DatosA.MesInforme = ' + CAST(@pMes as varchar(2)) + '))
				AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR DatosA.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
			GROUP BY DatosA.AnioInforme, DatosA.MesInforme
						, DatosA.CodSubDirGeneral, DatosA.CodDDirNegocio, DatosA.NombreDirNegocio
		                , DN.ImporteCarteraDN, DN.ImporteCarteraDNAñoAnterior
						, DatosA.DesOferta, DatosA.NomCliente, P.Pais, P.ImporteCarteraDNPais
			HAVING Sum(DatosA.TotAño) > ISNULL(' + CAST(@pLimiteImporte as varchar(35)) + ', 10000)
					) q ON P.Pais=q.Pais AND P.DN=q.CodDDirNegocio
			WHERE (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR P.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
			ORDER BY CASE WHEN q.AnioInforme IS NULL THEN ' + CAST(@pAño as varchar(4)) + ' ELSE q.AnioInforme END
					, CASE WHEN q.MesInforme IS NULL THEN ' + CAST(@pMes as varchar(2)) + ' ELSE q.MesInforme END
					, q.CodSubDirGeneral, q.CodDDirNegocio, q.NombreDirNegocio
					, P.ImporteCarteraDNPais DESC, q.ImporteCarteraOferta DESC;
			'

--		PRINT (@Sql)
		EXEC (@Sql)

	END
END
