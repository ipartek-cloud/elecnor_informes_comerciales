--exec spContratacion_Mensual_Acumulada_AñoAnterior_GERENCIA_CENTROS_NOVALE 2018,6


CREATE PROCEDURE [dbo].[spContratacion_Mensual_Acumulada_AñoAnterior_GERENCIA_CENTROS_NOVALE] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE (CodCentro varchar(3), ImporteContratado float,ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)
	
	-- OFERTAS
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0
	FROM dbo.vwOFER 		
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodCentro	
	
	-- REGULARIZACIONES
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0 
	FROM         (SELECT dbo.vwREG.*  
				  FROM     dbo.vwREG
				  WHERE   (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes ) AS vwRegularizacionesQ
	GROUP BY CodCentro
	
	-- OFERTASsql
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodCentro,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0 
	FROM    dbo.OfertasSQL	
	WHERE  (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodCentro	
	
	-- CONTRATACION AÑO ANTERIOR de HISTORICO
	INSERT INTO @vContratacion(CodCentro,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT HistoricoContratacionGrupoSQL.CodCentro,0, 0,sum(Importe) 
	FROM dbo.HistoricoContratacionGrupoSQL 
	WHERE  Año=@pAño-1 AND Mes <= @pMes 
	GROUP BY CodCentro

	
	SELECT NombreGerente,CentrosGerentesSQL.CodCentro, sum(isnull(ImporteContratado,0)) as ImporteContratado,Sum(isnull(ImporteContratadoAcumulado,0)) as ImporteContratadoAcumulado, sum(isnull(ImporteContratadoAcumuladoAñoAnterior,0)) as ImporteContratadoAcumuladoAñoAnterior 
	FROM CentrosGerentesSQL	LEFT JOIN @vContratacion ON
		[@vContratacion].CodCentro=CentrosGerentesSQL.CodCentro		
		where [@vContratacion].CodCentro in (select CodCentro from Sumarigrama where CodSubDirGeneral=221)
	GROUP BY NombreGerente,CentrosGerentesSQL.CodCentro
	
	ORDER BY CentrosGerentesSQL.CodCentro
		
END