
CREATE PROCEDURE [dbo].[spContratacion_Mensual_Acumulada_AñoAnterior_ZONA] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE (CodSubDirGeneral int,NombreSubDirGeneral varchar(100),NombreDirNegocio varchar(30),NombreSubDirNegocioArea varchar(100), Pais varchar(50),CodProv varchar(2), ImporteContratado float,ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)
	
	-- OFERTAS
	INSERT INTO @vContratacion(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,CodProv,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,
			Pais,CodProv,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.vwOFER ON dbo.Sumarigrama.CodCentro = dbo.vwOFER.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,CodProv	
	
	-- REGULARIZACIONES
	INSERT INTO @vContratacion(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,CodProv,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,
			Pais,CodProv,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0
	FROM         (SELECT dbo.vwREG.*  
				  FROM     dbo.vwREG
				  WHERE   (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,CodProv
	
	-- OFERTASsql
	INSERT INTO @vContratacion(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,CodProv,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,
			Pais,CodProv,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			0
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,CodProv 
	
	-- CONTRATACION AÑO ANTERIOR de HISTORICO
	INSERT INTO @vContratacion(CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Pais,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Mercado,0, 0,sum(Importe) 
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.HistoricoContratacionGrupoSQL ON dbo.Sumarigrama.CodCentro = dbo.HistoricoContratacionGrupoSQL.CodCentro
	WHERE  dbo.HistoricoContratacionGrupoSQL.Año=@pAño-1 AND Mes <= @pMes 
	GROUP BY CodSubDirGeneral,NombreSubDirGeneral,NombreDirNegocio,NombreSubDirNegocioArea,Mercado	
		
	SELECT CodZona,NombreZona,Presencia, sum(ImporteContratado) as ImporteContratado,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 
	FROM @vContratacion	
	INNER JOIN vwProvinciasZonasPresencia ON vwProvinciasZonasPresencia.CodProv=[@vContratacion].CodProv	
	GROUP BY CodZona,NombreZona,Presencia	
	
END