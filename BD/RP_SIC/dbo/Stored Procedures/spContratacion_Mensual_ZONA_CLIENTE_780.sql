
CREATE PROCEDURE [dbo].[spContratacion_Mensual_ZONA_CLIENTE_780] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE (Mercado varchar(50),Pais varchar(50),NombreSubDirNegocioArea varchar(30),CodProv varchar(2),DescripcionOferta varchar(50),CodCliente varchar(8), ImporteContratadoAcumulado float)

	-- OFERTAS
	INSERT INTO @vContratacion(Mercado,Pais,NombreSubDirNegocioArea,CodProv,CodCliente,DescripcionOferta,ImporteContratadoAcumulado)	
	SELECT  Pais,NMPRO,NombreSubDirNegocioArea,CodProv,CodCliente,DescripcionOferta,sum(ImporteContratado) as ImporteContratadoAcumulado
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.vwOFER ON dbo.Sumarigrama.CodCentro = dbo.vwOFER.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) = @pMes AND CodSubDirGeneral=780
	GROUP BY Pais,NMPRO,NombreSubDirNegocioArea,CodProv,CodCliente,DescripcionOferta	

	-- REGULARIZACIONES
	INSERT INTO @vContratacion(Mercado,Pais,NombreSubDirNegocioArea,CodProv,CodCliente,DescripcionOferta,ImporteContratadoAcumulado)	
	SELECT  Pais,NMPRO,NombreSubDirNegocioArea,CodProv,CodCliente,DescripcionOferta,sum(ImporteContratado) as ImporteContratadoAcumulado
	FROM         (SELECT dbo.vwREG.*  
				  FROM     dbo.vwREG
				  WHERE   (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) = @pMes ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro 
	WHERE CodSubDirGeneral=780
	GROUP BY Pais,NMPRO,NombreSubDirNegocioArea,CodProv,CodCliente,DescripcionOferta	

	-- OFERTASsql
	INSERT INTO @vContratacion(Mercado,Pais,NombreSubDirNegocioArea,CodProv,CodCliente,DescripcionOferta,ImporteContratadoAcumulado)	
	SELECT  Pais,NMPRO,NombreSubDirNegocioArea,CodProv,CodCliente,DescripcionOferta,sum(ImporteContratado) as ImporteContratadoAcumulado
	FROM         dbo.OfertasSQL LEFT JOIN 
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO LEFT JOIN
                      dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) = @pMes AND CodSubDirGeneral=780
	GROUP BY Pais,NMPRO,NombreSubDirNegocioArea,CodProv,CodCliente,DescripcionOferta

	SELECT 4 as Orden, NombreSubDirNegocioArea as Nombre,'' as AgrupacionCentro,NomAgrupado +' ('+ dbo.fnPaises(Mercado,ClientesSQL.Pais) +')' as Cliente,DescripcionOferta, Sum(ImporteContratadoAcumulado) as ImporteContratadoMensual
	FROM @vContratacion 
		LEFT JOIN dbo.ClientesSQL ON [@vContratacion].CodCliente = dbo.ClientesSQL.CodCliente	
	WHERE Mercado='Internacional'	--AND ImporteContratadoAcumulado>0	
	GROUP BY dbo.fnPaises(Mercado,ClientesSQL.Pais),NombreSubDirNegocioArea,NomAgrupado,DescripcionOferta	
	--order by NombreSubDirNegocioArea, ImporteContratadoAcumulado desc

END