
 -- exec spContratacion_Mensual_Acumulada_AñoAnterior_GERENCIA_CENTROS_Fotovoltaica  2019,2

CREATE PROCEDURE [dbo].[spContratacion_Mensual_Acumulada_AñoAnterior_GERENCIA_CENTROS_Fotovoltaica] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE (CodCentro varchar(3),Pais varchar(50), ImporteContratado float,ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float, Objetivos float)
	
	-- OFERTAS
	INSERT INTO @vContratacion(CodCentro,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior, Objetivos)	
	SELECT  CodCentro,Pais,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0,0
	FROM dbo.vwOFER_Fotovoltaica 		
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodCentro	,Pais
	
	-- REGULARIZACIONES
	INSERT INTO @vContratacion(CodCentro,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior, Objetivos)	
	SELECT  CodCentro,Pais,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0,0 
	FROM         (SELECT dbo.vwREG_Fotovoltaica.*  
				  FROM     dbo.vwREG_Fotovoltaica
				  WHERE   (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes ) AS vwRegularizacionesQ
	GROUP BY CodCentro, Pais
	
	-- OFERTASsql
	INSERT INTO @vContratacion(CodCentro, Pais, ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior, Objetivos)	
	SELECT  CodCentro,Pais,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0,0 
	FROM    dbo.OfertasSQL	INNER JOIN
    dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO
	WHERE  (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes and CodAct1='04' AND CodAct2='42'
	GROUP BY CodCentro, Pais
	
	-- CONTRATACION AÑO ANTERIOR de HISTORICO
	INSERT INTO @vContratacion(CodCentro,Pais, ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior, Objetivos)	
	SELECT CodCentro,Mercado,0, 0,sum(Importe),0 
	FROM dbo.HistoricoContratacionGrupoSQL 
	WHERE  Año=@pAño-1 AND Mes <= @pMes and CodAct1='04' AND CodAct2='42'
	GROUP BY CodCentro,Mercado

	-- OBJETIVOS
	INSERT INTO @vContratacion(CodCentro,Pais, ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior, Objetivos)	
	SELECT CodCentro,Mercado,0, 0,0,Importe
	FROM vwObjetivosActividadSQL_04_42

	SELECT 'Fotovoltaica' as NombreGerente, CodCentro, Pais, sum(isnull(ImporteContratado,0)) as ImporteContratado,Sum(isnull(ImporteContratadoAcumulado,0)) as ImporteContratadoAcumulado, sum(isnull(ImporteContratadoAcumuladoAñoAnterior,0)) as ImporteContratadoAcumuladoAñoAnterior, Sum((isnull(Objetivos,0))) as Objetivos
	FROM  @vContratacion -- WHERE CodCentro IN (SELECT CodCentro FROM sumarigrama)
	GROUP BY CodCentro, Pais
		
END