
CREATE PROCEDURE [dbo].[spContratacion_Mensual_Acumulada_AñoAnterior_ZONA_CLIENTE] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE ( Mercado varchar(50),Pais varchar(50),CodProv varchar(2),DescripcionOferta varchar(50),CodCliente varchar(8), ImporteContratado float,ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)

	-- OFERTAS
	INSERT INTO @vContratacion(Mercado,Pais,CodProv,CodCliente,DescripcionOferta,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  Pais,NMPRO,CodProv,CodCliente,DescripcionOferta,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			sum(dbo.fnImporteContratacion_AñoAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoAñoanterior
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.vwOFER ON dbo.Sumarigrama.CodCentro = dbo.vwOFER.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño or year(FAdjudicacion)=@pAño-1) AND month(FAdjudicacion) <= @pMes 
	GROUP BY Pais,NMPRO,CodProv,CodCliente,DescripcionOferta	

	-- REGULARIZACIONES
	INSERT INTO @vContratacion(Mercado,Pais,CodProv,CodCliente,DescripcionOferta,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  Pais,NMPRO,CodProv,CodCliente,DescripcionOferta,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			sum(dbo.fnImporteContratacion_AñoAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoAñoanterior
	FROM         (SELECT dbo.vwREG.*  
				  FROM     dbo.vwREG
				  WHERE   (year(FAdjudicacion)=@pAño or year(FAdjudicacion)=@pAño-1) AND month(FAdjudicacion) <= @pMes ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro 
	GROUP BY Pais,NMPRO,CodProv,CodCliente,DescripcionOferta	

	-- OFERTASsql
	INSERT INTO @vContratacion(Mercado,Pais,CodProv,CodCliente,DescripcionOferta,ImporteContratado,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  Pais,NMPRO,CodProv,CodCliente,DescripcionOferta,
			sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado,
			sum(dbo.fnImporteContratacion_AñoAnterior(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumuladoAñoanterior
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño or year(FAdjudicacion)=@pAño-1) AND month(FAdjudicacion) <= @pMes 
	GROUP BY Pais,NMPRO,CodProv,CodCliente,DescripcionOferta	
				
	SELECT CodZona,NombreZona,Presencia,Mercado,dbo.fnPaises(Mercado,[@vContratacion].Pais)as Pais,NomAgrupado,DescripcionOferta, sum(ImporteContratado) as ImporteContratado,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 
	FROM @vContratacion 
		INNER JOIN dbo.ClientesSQL ON [@vContratacion].CodCliente = dbo.ClientesSQL.CodCliente
		INNER JOIN vwProvinciasZonasPresencia ON vwProvinciasZonasPresencia.CodProv=[@vContratacion].CodProv				
	GROUP BY CodZona,NombreZona,Presencia,Mercado,dbo.fnPaises(Mercado,[@vContratacion].Pais),NomAgrupado,DescripcionOferta
	
END