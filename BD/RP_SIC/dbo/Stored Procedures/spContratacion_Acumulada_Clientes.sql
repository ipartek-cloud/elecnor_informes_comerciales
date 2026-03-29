
CREATE PROCEDURE [dbo].[spContratacion_Acumulada_Clientes] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE (CodCentro varchar(3),DescripcionOferta varchar(255),CodCliente varchar(50),ImporteContratadoAcumulado float)
	
	-- OFERTAS
	INSERT INTO @vContratacion(CodCentro,DescripcionOferta,CodCliente,ImporteContratadoAcumulado)	
	SELECT  CodCentro,DescripcionOferta,CodCliente,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado
	FROM dbo.vwOFER 
	WHERE  (year(FAdjudicacion)=@pAño or year(FAdjudicacion)=@pAño-1) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodCentro,DescripcionOferta,CodCliente
	
	-- REGULARIZACIONES
	INSERT INTO @vContratacion(CodCentro,DescripcionOferta,CodCliente,ImporteContratadoAcumulado)	
	SELECT  CodCentro,DescripcionOferta,CodCliente,			
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado
	FROM         (SELECT dbo.vwREG.*  
				  FROM     dbo.vwREG
				  WHERE   (year(FAdjudicacion)=@pAño or year(FAdjudicacion)=@pAño-1) AND month(FAdjudicacion) <= @pMes ) AS vwRegularizacionesQ
	GROUP BY CodCentro,DescripcionOferta,CodCliente
	
	-- OFERTASsql
	INSERT INTO @vContratacion(CodCentro,DescripcionOferta,CodCliente,ImporteContratadoAcumulado)	
	SELECT  CodCentro,DescripcionOferta,CodCliente,
			sum(dbo.fnImporteContratacion_Acumulado(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratadoAcumulado
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO
	WHERE  (year(FAdjudicacion)=@pAño or year(FAdjudicacion)=@pAño-1) AND month(FAdjudicacion) <= @pMes 
	GROUP BY CodCentro,DescripcionOferta,CodCliente
	
	SELECT [@vContratacion].CodCentro,DescripcionOferta, dbo.ClientesSQL.NomAgrupado AS NombreCliente,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado
	FROM @vContratacion	
		 LEFT JOIN dbo.ClientesSQL ON
			[@vContratacion].CodCliente = dbo.ClientesSQL.CodCliente
			-- INNER JOIN dbo.sumarigrama ON 
			--[@vContratacion].CodCentro = dbo.sumarigrama.CodCentro	
	--WHERE sumarigrama.CodSubDirGeneral=221
	GROUP BY [@vContratacion].CodCentro,DescripcionOferta, dbo.ClientesSQL.NomAgrupado
	
END