CREATE PROCEDURE [dbo].[spContratacion_Clientes_Desglose_OLD] 		
	@pMercado varchar(50),
	@pAño int,
	@pMes int
	AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @vContratacionClientes TABLE (Mercado varchar(50),Pais varchar(50),AsociadaInversion numeric(10,0),Cliente varchar(100),ClienteDesglose varchar(100), ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)
	
	---------------------- OFERTAS ----------------------
			
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ClienteDesglose,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  Mercado,Pais, AsociadaInversion, NomAgrupado,NomAgrupadoDesglose, sum(ImporteContratado),0
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.vwOfertas_AsociadasInversion_Pais_Cliente_Desglose ON dbo.Sumarigrama.CodCentro = dbo.vwOfertas_AsociadasInversion_Pais_Cliente_Desglose.CodCentro
	WHERE  AñoAdjudicacion=@pAño AND MesAdjudicacion <= @pMes 
	GROUP BY Mercado,Pais, AsociadaInversion, NomAgrupado,NomAgrupadoDesglose	
	
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ClienteDesglose,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  Mercado,Pais, AsociadaInversion, NomAgrupado,NomAgrupadoDesglose,0, sum(ImporteContratado)
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.vwOfertas_AsociadasInversion_Pais_Cliente_Desglose ON dbo.Sumarigrama.CodCentro = dbo.vwOfertas_AsociadasInversion_Pais_Cliente_Desglose.CodCentro
	WHERE  AñoAdjudicacion=@pAño-1 AND MesAdjudicacion <= @pMes 
	GROUP BY Mercado,Pais, AsociadaInversion, NomAgrupado,NomAgrupadoDesglose	
	
	---------------------- REGULARIZACIONES ----------------------
		
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ClienteDesglose,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  Mercado,Pais, AsociadaInversion, NomAgrupado,NomAgrupadoDesglose, sum(ImporteContratado),0
	FROM         (SELECT   Mercado,Pais, AsociadaInversion, NomAgrupado,NomAgrupadoDesglose,ImporteContratado,CodCentro
				  FROM     dbo.vwRegularizaciones_AsociadasInversion_Pais_Cliente_Desglose
				  WHERE    (AñoAdjudicacion = @pAño) AND (MesAdjudicacion <= @pMes)) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY Mercado,Pais, AsociadaInversion, NomAgrupado,NomAgrupadoDesglose

	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ClienteDesglose,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  Mercado,Pais, AsociadaInversion, NomAgrupado,NomAgrupadoDesglose, 0,sum(ImporteContratado)
	FROM         (SELECT   Mercado,Pais, AsociadaInversion, NomAgrupado,NomAgrupadoDesglose,ImporteContratado,CodCentro
				  FROM     dbo.vwRegularizaciones_AsociadasInversion_Pais_Cliente_Desglose
				  WHERE    (AñoAdjudicacion = @pAño-1) AND (MesAdjudicacion <= @pMes)) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY Mercado,Pais, AsociadaInversion, NomAgrupado,NomAgrupadoDesglose

	---------------------- OfertasSQL ----------------------
	
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ClienteDesglose,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT dbo.Provincias.Pais,NMPRO, JVAYNB, NomAgrupado,NomAgrupadoDesglose, sum(ImporteContratado),0
	FROM    dbo.OfertasSQL INNER JOIN
            dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
            dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
            dbo.ClientesSQL ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
            dbo.OfertaAsociadaInversion ON dbo.OfertasSQL.CodOferta = dbo.OfertaAsociadaInversion.JVAYNB
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes AND VisibleDesglose = 1
	GROUP BY dbo.Provincias.Pais,NMPRO, JVAYNB, NomAgrupado,NomAgrupadoDesglose
	
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ClienteDesglose,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT dbo.Provincias.Pais,NMPRO, JVAYNB, NomAgrupado,NomAgrupadoDesglose, 0, sum(ImporteContratado)
	FROM    dbo.OfertasSQL INNER JOIN
            dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO --INNER JOIN
            --dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
            LEFT OUTER JOIN
            dbo.ClientesSQL ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
            dbo.OfertaAsociadaInversion ON dbo.OfertasSQL.CodOferta = dbo.OfertaAsociadaInversion.JVAYNB
	WHERE AñoAdjudicacion=@pAño-1 AND month(FAdjudicacion) <= @pMes AND VisibleDesglose = 1 and reparto=0
	GROUP BY dbo.Provincias.Pais,NMPRO, JVAYNB, NomAgrupado,NomAgrupadoDesglose	
	
	
	DECLARE @vContratacionClientes_Agrupado TABLE (Mercado varchar(50),Pais varchar(50),AsociadaInversion float,Cliente varchar(100),ClienteDesglose varchar(100), ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)
	
	INSERT INTO @vContratacionClientes_Agrupado(Mercado,Pais,AsociadaInversion,Cliente,ClienteDesglose,ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior)
	SELECT Mercado,dbo.fnPaises(Mercado,Pais) as Pais,avg(isnull(AsociadaInversion,0)),Cliente,ClienteDesglose,sum(ImporteContratadoAcumulado),sum(ImporteContratadoAcumuladoAñoanterior) 
	FROM @vContratacionClientes
    WHERE Mercado=@pMercado 
	GROUP BY Mercado,dbo.fnPaises(Mercado,Pais),cliente,ClienteDesglose
	
	SELECT Mercado,Pais, dbo.fnAI(AsociadaInversion) as AI, Cliente ,ClienteDesglose,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior	
	FROM @vContratacionClientes_Agrupado	
	WHERE Mercado=@pMercado 
	GROUP BY Mercado,pais,dbo.fnAI(AsociadaInversion),Cliente,ClienteDesglose

END