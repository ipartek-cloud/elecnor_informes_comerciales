
CREATE PROCEDURE [dbo].[spContratacion_Mensual_Acumulada_AñoAnterior_ACTIVIDAD_DN] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE (CodCentro varchar(3),CodAct1 varchar(2), CodAct2 varchar(2), ImporteContratado float,ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)
	
	-- OFERTAS
	INSERT INTO @vContratacion(CodCentro,CodAct1,CodAct2,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodCentro,CodAct1,CodAct2,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0
	FROM dbo.vwOFER 
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodCentro,CodAct1,CodAct2	
	
	-- REGULARIZACIONES
	INSERT INTO @vContratacion(CodCentro,CodAct1,CodAct2,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodCentro,CodAct1,CodAct2,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0
	FROM         (SELECT dbo.vwREG.*  
				  FROM     dbo.vwREG
				  WHERE   (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes ) AS vwRegularizacionesQ
	GROUP BY CodCentro,CodAct1,CodAct2
	
	-- OFERTASsql
	INSERT INTO @vContratacion(CodCentro,CodAct1,CodAct2,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodCentro,CodAct1,CodAct2,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0
	FROM         dbo.OfertasSQL 
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodCentro,CodAct1,CodAct2		
	
	-- CONTRATACION AÑO ANTERIOR de HISTORICO
	INSERT INTO @vContratacion(CodCentro,CodAct1,CodAct2,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT CodCentro,CodAct1,CodAct2,0, 0,sum(Importe) 
	FROM dbo.HistoricoContratacionGrupoSQL 
	WHERE  Año=@pAño-1 AND Mes <= @pMes 
	GROUP BY CodCentro,CodAct1,CodAct2	

	SELECT CodDDirNegocio,NombreDirNegocio,CodAct1,CodAct2,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 
	FROM (
		SELECT [@vContratacion].CodCentro,CodAct1,CodAct2,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 
		FROM @vContratacion
		GROUP BY  [@vContratacion].CodCentro,CodAct1,CodAct2
		 )w INNER JOIN
				dbo.sumarigrama ON w.CodCentro = dbo.sumarigrama.CodCentro	
	WHERE sumarigrama.CodSubDirGeneral=221
	GROUP BY CodDDirNegocio,NombreDirNegocio,CodAct1,CodAct2
	order by NombreDirNegocio

		
END