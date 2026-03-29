CREATE PROCEDURE [dbo].[spContratacion_Clientes_OLD] 		
	@pMercado varchar(50),
	@pAño int,
	@pMes int
	AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @vContratacionClientes TABLE (Mercado varchar(50),Pais varchar(50),AsociadaInversion numeric(10,0),Cliente varchar(100), ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float, ImporteContratadoAcumulado_Ajuste float)
	
	---------------------- OFERTAS ----------------------
			
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,ImporteContratadoAcumulado_Ajuste)	
	SELECT  Mercado,Pais, AsociadaInversion, NomAgrupado, sum(ImporteContratado),0,0
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.vwOfertas_AsociadasInversion_Pais_Cliente ON dbo.Sumarigrama.CodCentro = dbo.vwOfertas_AsociadasInversion_Pais_Cliente.CodCentro
	WHERE  AñoAdjudicacion=@pAño AND MesAdjudicacion <= @pMes 
	GROUP BY Mercado,Pais, AsociadaInversion, NomAgrupado	
	
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,ImporteContratadoAcumulado_Ajuste)	
	SELECT  Mercado,Pais, AsociadaInversion, NomAgrupado, 0, sum(ImporteContratado),0
	--FROM dbo.Sumarigrama INNER JOIN
	--	 dbo.vwOfertas_AsociadasInversion_Pais_Cliente ON dbo.Sumarigrama.CodCentro = dbo.vwOfertas_AsociadasInversion_Pais_Cliente.CodCentro
	FROM dbo.vwOfertas_AsociadasInversion_Pais_Cliente
	WHERE  AñoAdjudicacion=@pAño-1 AND MesAdjudicacion <= @pMes
	GROUP BY Mercado,Pais, AsociadaInversion, NomAgrupado
	
	---------------------- REGULARIZACIONES ----------------------
		
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,ImporteContratadoAcumulado_Ajuste)	
	SELECT  Mercado,Pais, AsociadaInversion, NomAgrupado, sum(ImporteContratado),0,0
	FROM         (SELECT   Mercado,Pais, AsociadaInversion, NomAgrupado, ImporteContratado,CodCentro
				  FROM     dbo.vwRegularizaciones_AsociadasInversion_Pais_Cliente
				  WHERE    (AñoAdjudicacion = @pAño) AND (MesAdjudicacion <= @pMes)) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY Mercado,Pais, AsociadaInversion, NomAgrupado

	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,ImporteContratadoAcumulado_Ajuste)	
	SELECT  Mercado,Pais, AsociadaInversion, NomAgrupado, 0,sum(ImporteContratado),0
	FROM         (SELECT   Mercado,Pais, AsociadaInversion, NomAgrupado, ImporteContratado,CodCentro
				  FROM     dbo.vwRegularizaciones_AsociadasInversion_Pais_Cliente
				  WHERE    (AñoAdjudicacion = @pAño-1) AND (MesAdjudicacion <= @pMes)) AS vwRegularizacionesQ --INNER JOIN
							 --dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY Mercado,Pais, AsociadaInversion, NomAgrupado

	---------------------- OfertasSQL ----------------------
	
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,ImporteContratadoAcumulado_Ajuste)	
	SELECT dbo.Provincias.Pais,dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado, sum(ImporteContratado),0,0
	FROM    dbo.OfertasSQL INNER JOIN
            dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
            dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro LEFT OUTER JOIN
            dbo.ClientesSQL ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
            dbo.OfertaAsociadaInversion ON dbo.OfertasSQL.CodOferta = dbo.OfertaAsociadaInversion.JVAYNB
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes --and reparto=0
	GROUP BY dbo.Provincias.Pais,dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado
	
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,ImporteContratadoAcumulado_Ajuste)	
	SELECT dbo.Provincias.Pais,dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado,0, sum(ImporteContratado),0
	FROM    dbo.OfertasSQL INNER JOIN
            dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO --INNER JOIN
            --dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
             LEFT OUTER JOIN
            dbo.ClientesSQL ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
            dbo.OfertaAsociadaInversion ON dbo.OfertasSQL.CodOferta = dbo.OfertaAsociadaInversion.JVAYNB
	WHERE AñoAdjudicacion=@pAño-1 AND month(FAdjudicacion) <= @pMes and reparto=0
	GROUP BY dbo.Provincias.Pais,dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado

	---------------------- OfertasSQL_Ajustes ----------------------
	
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,ImporteContratadoAcumulado_Ajuste)	
	SELECT dbo.Provincias.Pais,dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado, sum(Importe),0,sum(Importe)
	FROM    dbo.OfertasSQL_Ajustes INNER JOIN
            dbo.Provincias ON dbo.OfertasSQL_Ajustes.CodProv = dbo.Provincias.CDPRO LEFT OUTER JOIN
            dbo.ClientesSQL ON dbo.OfertasSQL_Ajustes.CodCliente = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
            dbo.OfertaAsociadaInversion ON dbo.OfertasSQL_Ajustes.CodOferta = dbo.OfertaAsociadaInversion.JVAYNB
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes 
	GROUP BY dbo.Provincias.Pais,dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado
	
	INSERT INTO @vContratacionClientes(Mercado,Pais, AsociadaInversion, Cliente,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior,ImporteContratadoAcumulado_Ajuste)	
	SELECT dbo.Provincias.Pais,dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado,0, sum(Importe),sum(Importe)
	FROM    dbo.OfertasSQL_Ajustes INNER JOIN
            dbo.Provincias ON dbo.OfertasSQL_Ajustes.CodProv = dbo.Provincias.CDPRO LEFT OUTER JOIN
            dbo.ClientesSQL ON dbo.OfertasSQL_Ajustes.CodCliente = dbo.ClientesSQL.CodCliente LEFT OUTER JOIN
            dbo.OfertaAsociadaInversion ON dbo.OfertasSQL_Ajustes.CodOferta = dbo.OfertaAsociadaInversion.JVAYNB
	WHERE AñoAdjudicacion=@pAño-1 AND month(FAdjudicacion) <= @pMes 
	GROUP BY dbo.Provincias.Pais,dbo.ClientesSQL.Pais, JVAYNB, NomAgrupado
	
	DECLARE @vContratacionClientes_Agrupado TABLE (Mercado varchar(50),Pais varchar(50),AsociadaInversion float,Cliente varchar(100), ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float,ImporteContratadoAcumulado_Ajuste float)
	
	INSERT INTO @vContratacionClientes_Agrupado(Mercado,Pais,AsociadaInversion,Cliente, ImporteContratadoAcumulado, ImporteContratadoAcumuladoAñoanterior,ImporteContratadoAcumulado_Ajuste)
	SELECT Mercado,dbo.fnPaises(Mercado,Pais) as Pais,avg(isnull(AsociadaInversion,0)),Cliente,sum(ImporteContratadoAcumulado),sum(ImporteContratadoAcumuladoAñoanterior),sum(ImporteContratadoAcumulado_Ajuste) 
	FROM @vContratacionClientes
    WHERE Mercado=@pMercado 
	GROUP BY Mercado,dbo.fnPaises(Mercado,Pais),cliente
	
	SELECT row_number() over (order by [dbo].[fnClienteVisible](Cliente) desc, Sum(ImporteContratadoAcumulado) desc) as Row,
	Mercado, Pais, dbo.fnAI(AsociadaInversion) as AI, Cliente ,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior,sum(ImporteContratadoAcumulado_Ajuste)as ImporteContratadoAcumulado_Ajuste
	FROM @vContratacionClientes_Agrupado	
	WHERE Mercado=@pMercado  
	GROUP BY Mercado,Pais, dbo.fnAI(AsociadaInversion), Cliente
	order by ImporteContratadoAcumulado desc	
	

END