
--[dbo].[spContratacion_Mensual_ZONA_CLIENTE_800] 2014,2

CREATE PROCEDURE [dbo].[spContratacion_Mensual_ZONA_CLIENTE_800] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE (CodCentro varchar(3),NombreCentro varchar(50),Mercado varchar(50),Pais varchar(50),CodDDirNegocio numeric (3,0),NombreDirNegocio varchar(30),CodProv varchar(2),DescripcionOferta varchar(50),CodCliente varchar(8), ImporteContratadoAcumulado float)

	-- OFERTAS
	INSERT INTO @vContratacion(CodCentro,NombreCentro,Mercado,Pais,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,ImporteContratadoAcumulado)	
	SELECT  vwOFER.CodCentro,NombreCentro,Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,sum(ImporteContratado) as ImporteContratadoAcumulado
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.vwOFER ON dbo.Sumarigrama.CodCentro = dbo.vwOFER.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) = @pMes AND CodSubDirGeneral=800
	GROUP BY vwOFER.CodCentro,NombreCentro,Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta	

	-- REGULARIZACIONES
	INSERT INTO @vContratacion(CodCentro,NombreCentro,Mercado,Pais,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,ImporteContratadoAcumulado)	
	SELECT  vwRegularizacionesQ.CodCentro,NombreCentro,Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,sum(ImporteContratado) as ImporteContratadoAcumulado
	FROM         (SELECT dbo.vwREG.*  
				  FROM     dbo.vwREG
				  WHERE   (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) = @pMes ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro 
	WHERE CodSubDirGeneral=800
	GROUP BY vwRegularizacionesQ.CodCentro,NombreCentro,Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta	

	-- OFERTASsql
	INSERT INTO @vContratacion(CodCentro,NombreCentro,Mercado,Pais,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,ImporteContratadoAcumulado)	
	SELECT  OfertasSQL.CodCentro,NombreCentro,Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,sum(ImporteContratado) as ImporteContratadoAcumulado
	FROM         dbo.OfertasSQL LEFT JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO LEFT JOIN
                      dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) = @pMes AND CodSubDirGeneral=800
	GROUP BY OfertasSQL.CodCentro,NombreCentro,Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta
	
	SELECT 2 as Orden,NombreDirNegocio as Nombre,dbo.[fnAgrupacionCentro](CodCentro,NombreCentro) as AgrupacionCentro,NomAgrupado +' ('+ dbo.fnPaises(Mercado,ClientesSQL.Pais) +')' as Cliente,DescripcionOferta, Sum(ImporteContratadoAcumulado) as ImporteContratadoMensual
	FROM @vContratacion 
		LEFT JOIN dbo.ClientesSQL ON [@vContratacion].CodCliente = dbo.ClientesSQL.CodCliente				
	WHERE Mercado='Internacional' --AND ImporteContratadoAcumulado>0
	GROUP BY dbo.[fnAgrupacionCentro](CodCentro,NombreCentro),dbo.fnPaises(Mercado,ClientesSQL.Pais),NombreDirNegocio,NomAgrupado,DescripcionOferta
	
END