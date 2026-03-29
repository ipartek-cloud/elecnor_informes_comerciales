
CREATE PROCEDURE [dbo].[spContratacion_Mensual_CENTROS] 
	@pMercado varchar(30),		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE (Pais varchar(30),CodCentro varchar(3),DescripcionOferta varchar(50),CodCliente varchar(100), ImporteContratado float)
	
	-- OFERTAS
	INSERT INTO @vContratacion(Pais,CodCentro,DescripcionOferta,CodCliente,ImporteContratado)	
	SELECT  Pais,CodCentro,DescripcionOferta,CodCliente,sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado
	FROM dbo.vwOFER 
	WHERE  (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes 
	GROUP BY Pais,CodCentro,DescripcionOferta,CodCliente
	
	-- REGULARIZACIONES
	INSERT INTO @vContratacion(Pais,CodCentro,DescripcionOferta,CodCliente,ImporteContratado)	
	SELECT  Pais,CodCentro,DescripcionOferta,CodCliente,sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado
	FROM         (SELECT dbo.vwREG.*  
				  FROM     dbo.vwREG
				  WHERE   (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes ) AS vwRegularizacionesQ
	GROUP BY Pais,CodCentro,DescripcionOferta,CodCliente
	
	-- OFERTASsql
	INSERT INTO @vContratacion(Pais,CodCentro,DescripcionOferta,CodCliente,ImporteContratado)	
	SELECT  Pais,CodCentro,DescripcionOferta,CodCliente,sum(dbo.fnImporteContratacion_MesActual(FAdjudicacion,@pAño,@pMes,ImporteContratado)) as ImporteContratado
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO
	WHERE  (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) <= @pMes 
	GROUP BY Pais,CodCentro,DescripcionOferta,CodCliente
	
	
	SELECT CodCentro, DescripcionOferta,isnull(NomAgrupado,'') as Cliente,sum(ImporteContratado) as ImporteContratado
	FROM @vContratacion	 LEFT JOIN
                      dbo.ClientesSQL ON [@vContratacion].CodCliente = dbo.ClientesSQL.CodCliente
	WHERE [@vContratacion].Pais=@pMercado
	GROUP BY CodCentro,DescripcionOferta,NomAgrupado
	
		
END