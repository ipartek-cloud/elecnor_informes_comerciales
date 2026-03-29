
CREATE PROCEDURE [dbo].[spContratacion_Acumulada_ZONA_CLIENTE] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE (Mercado varchar(50),Pais varchar(50),CodDDirNegocio numeric (3,0),NombreDirNegocio varchar(30),CodProv varchar(2),DescripcionOferta varchar(50),CodCliente varchar(8), ImporteContratadoAcumulado float)

	-- OFERTAS
	INSERT INTO @vContratacion(Mercado,Pais,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,ImporteContratadoAcumulado)	
	SELECT  Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,sum(ImporteContratado) as ImporteContratadoAcumulado
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.vwOFER ON dbo.Sumarigrama.CodCentro = dbo.vwOFER.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes AND CodSubDirGeneral=221
	GROUP BY Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta	

	-- REGULARIZACIONES
	INSERT INTO @vContratacion(Mercado,Pais,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,ImporteContratadoAcumulado)	
	SELECT  Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,sum(ImporteContratado) as ImporteContratadoAcumulado
	FROM         (SELECT dbo.vwREG.*  
				  FROM     dbo.vwREG
				  WHERE   (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro 
	WHERE CodSubDirGeneral=221
	GROUP BY Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta	

	-- OFERTASsql
	INSERT INTO @vContratacion(Mercado,Pais,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,ImporteContratadoAcumulado)	
	SELECT  Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta,sum(ImporteContratado) as ImporteContratadoAcumulado
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) <= @pMes AND CodSubDirGeneral=221
	GROUP BY Pais,NMPRO,CodDDirNegocio,NombreDirNegocio,CodProv,CodCliente,DescripcionOferta
				
	SELECT CodZona,NombreZona,Presencia,Mercado,dbo.fnPaises(Mercado,ClientesSQL.Pais)as Pais,CodDDirNegocio,NombreDirNegocio,NomAgrupado,DescripcionOferta, Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado
	FROM @vContratacion 
		INNER JOIN dbo.ClientesSQL ON [@vContratacion].CodCliente = dbo.ClientesSQL.CodCliente
		INNER JOIN vwProvinciasZonasPresencia ON vwProvinciasZonasPresencia.CodProv=[@vContratacion].CodProv				
	GROUP BY CodZona,NombreZona,Presencia,Mercado,dbo.fnPaises(Mercado,ClientesSQL.Pais),CodDDirNegocio,NombreDirNegocio,NomAgrupado,DescripcionOferta
	
END