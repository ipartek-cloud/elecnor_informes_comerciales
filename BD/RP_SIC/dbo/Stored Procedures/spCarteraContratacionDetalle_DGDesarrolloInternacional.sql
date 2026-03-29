CREATE PROCEDURE [dbo].[spCarteraContratacionDetalle_DGDesarrolloInternacional] 		
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

	DECLARE @Sql as varchar(max)
	CREATE TABLE #CarteraPorPais (Pais varchar(100), ImporteCarteraPais float)
	CREATE TABLE #CarteraPorDN  (DN varchar(100), ImporteCarteraDN float)
	CREATE TABLE #CarteraPorDNPais  (DN varchar(100), Pais varchar(100), ImporteCarteraDNPais float, N int)

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

		--CREATE TABLE #CarteraPorPais (Pais varchar(100), ImporteCarteraPais float)
		SET @Sql = '
			SELECT TOP ' + CAST(@pLimitePaises as varchar(5)) + ' Pais, Sum(ImporteEUR)
			FROM CarterasContratacionSQL
			WHERE AnioInforme=' + CAST(@pAño as varchar(4)) + ' AND MesInforme=' + CAST(@pMes as varchar(2)) + ' 
					AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR Pais<>''Nacional'')
			GROUP BY Pais
			ORDER BY Sum(ImporteEUR) DESC;
			'
		INSERT INTO #CarteraPorPais
		EXEC (@Sql)
--select * from #CarteraPorPais order by ImporteCarteraPais desc

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

		--PRINT (@Sql)
		EXEC (@Sql)

	END

	IF @pInforme= '8.1'
	BEGIN

		SET @Sql = '
			SELECT TOP ' + CAST(@pLimitePaises as varchar(5)) + ' Pais, Sum(ImporteEUR)
			FROM CarterasContratacionSQL
			WHERE AnioInforme=' + CAST(@pAño as varchar(4)) + ' AND MesInforme=' + CAST(@pMes as varchar(2)) + ' 
					AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR Pais<>''Nacional'')
			GROUP BY Pais
			ORDER BY Sum(ImporteEUR) DESC;
			'
		INSERT INTO #CarteraPorPais
		EXEC (@Sql)

		SET @Sql = '
			SELECT CodDDirNegocio DN, Sum(ImporteEUR)
			FROM CarterasContratacionSQL C
				LEFT JOIN SumarigramaHistorico S ON C.CentroChar = S.CodCentro AND C.AnioInforme = S.Año
			WHERE AnioInforme=' + CAST(@pAño as varchar(4)) + ' AND MesInforme=' + CAST(@pMes as varchar(2)) + ' 
					AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR Pais<>''Nacional'')
			GROUP BY CodDDirNegocio
			ORDER BY Sum(ImporteEUR) DESC;
			'
		INSERT INTO #CarteraPorDN
		EXEC (@Sql)

		SET @Sql = '
			SELECT DN, Pais, Importe, N
			FROM (
				SELECT DN, Pais, Importe, ROW_NUMBER() OVER(PARTITION BY DN ORDER BY Importe DESC) N
				FROM (
					SELECT RIGHT(''000'' + CAST(S.CodDDirNegocio as varchar(3)), 3) DN, Pais, Sum(ImporteEUR) Importe 
								FROM CarterasContratacionSQL C
									LEFT JOIN SumarigramaHistorico S ON C.CentroChar = S.CodCentro AND C.AnioInforme = S.Año
								WHERE AnioInforme=' + CAST(@pAño as varchar(4)) + ' AND MesInforme=' + CAST(@pMes as varchar(2)) + ' 
										AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR Pais<>''Nacional'')
								GROUP BY CodDDirNegocio, Pais
					--			ORDER BY CodDDirNegocio, Sum(ImporteEUR) DESC;
					) q
			) r 
			WHERE r.N <= ' + CAST(@pLimitePaises as varchar(5)) 

		INSERT INTO #CarteraPorDNPais
		EXEC (@Sql)
--select * from #CarteraPorPais order by ImporteCarteraPais desc

		SET @Sql = '
			SELECT CASE WHEN P.Pais=''Nacional'' THEN ''España'' ELSE P.Pais END Pais, P.ImporteCarteraDNPais ImporteCarteraPais, ISNULL(q.ImporteCarteraDN, 0) ImporteCarteraDN
					, CASE WHEN q.AnioInforme IS NULL THEN ' + CAST(@pAño as varchar(4)) + ' ELSE q.AnioInforme END AnioInforme
					, CASE WHEN q.MesInforme IS NULL THEN ' + CAST(@pMes as varchar(2)) + ' ELSE q.MesInforme END MesInforme
					, q.CodSubDirGeneral
					, q.CodDDirNegocio, q.NombreDirNegocio
					, ISNULL(q.DesOferta, '''') DesOferta
					, ISNULL(q.NomCliente, '''') NomCliente
					, ISNULL(q.ImporteCarteraOferta, 0) ImporteCarteraOferta
					, ISNULL(q.ImporteContratadoOferta, 0) ImporteContratadoOferta
			FROM #CarteraPorDNPais P
					LEFT JOIN (

			SELECT AnioInforme, MesInforme
					, CodSubDirGeneral
					, CodDDirNegocio, NombreDirNegocio, DN.ImporteCarteraDN
					, P.Pais, P.ImporteCarteraDNPais
					, REPLACE(DesOferta, '''''''', '''') DesOferta, REPLACE(NomCliente, '''''''', '''') NomCliente
					, Sum(ImporteEUR) AS ImporteCarteraOferta
					, Sum(ISNULL(ImporteContratado, 0)) AS ImporteContratadoOferta
			FROM #CarteraPorDNPais P
					LEFT JOIN CarterasContratacionSQL C ON P.Pais=C.Pais AND P.DN=C.DN
					LEFT JOIN SumarigramaHistorico S ON C.CentroChar = S.CodCentro AND C.AnioInforme = S.Año
					LEFT JOIN #CarteraPorDN DN ON S.CodDDirNegocio = DN.DN AND S.Año=' + CAST(@pAño as varchar(4)) + '
					LEFT JOIN #Ofertas O ON C.CodOferta=O.CodOferta
			WHERE (C.AnioInforme IS NULL OR (C.AnioInforme = ' + CAST(@pAño as varchar(4)) + ' AND C.MesInforme = ' + CAST(@pMes as varchar(2)) + '))
				AND (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR C.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
			GROUP BY C.AnioInforme, C.MesInforme
						, CodSubDirGeneral, CodDDirNegocio, NombreDirNegocio, DN.ImporteCarteraDN
						, C.DesOferta, C.NomCliente, P.Pais, P.ImporteCarteraDNPais
			HAVING Sum(ImporteEUR) > ISNULL(' + CAST(@pLimiteImporte as varchar(35)) + ', 10000)
					) q ON P.Pais=q.Pais AND P.DN=q.CodDDirNegocio
			WHERE (' + CAST(@pTodoInternacional as varchar(1)) + '=1 OR P.Pais<>''Nacional'') -- si @pTodoInternacional=1 saca todo / si no, solo lo que no es Nacional (Internacional)
			ORDER BY CASE WHEN q.AnioInforme IS NULL THEN ' + CAST(@pAño as varchar(4)) + ' ELSE q.AnioInforme END 
					, CASE WHEN q.MesInforme IS NULL THEN ' + CAST(@pMes as varchar(2)) + ' ELSE q.MesInforme END
					, q.CodSubDirGeneral, q.CodDDirNegocio, q.NombreDirNegocio
					, P.ImporteCarteraDNPais DESC, q.ImporteCarteraOferta DESC;
			'
		--PRINT (@Sql)
		EXEC (@Sql)

	END
END