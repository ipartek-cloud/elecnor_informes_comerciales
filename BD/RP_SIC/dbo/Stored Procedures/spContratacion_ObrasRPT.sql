


CREATE PROCEDURE [dbo].[spContratacion_ObrasRPT] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @vImporteContratadoSUP float
	DECLARE @vImporteContratadoINF float

	DECLARE @StartTime AS DATETIME = GETDATE()
	
	DECLARE @vContratacionObras TABLE (CodCentro varchar(50) ,Pais varchar(50),NombrePais varchar(50),Año int,Mes int,CodOferta varchar(10), DescripcionOferta varchar(100),NombreCliente varchar(100), ImporteContratado float, LitMes varchar(20), wTipo int)	

	-- CONTRATOS MARCO Sobre Ofertas (Oferta cartera Diferida)
	INSERT INTO @vContratacionObras(CodCentro ,Pais,NombrePais,Año,Mes,CodOferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo)	
	SELECT CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwOF.CodOferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado ,0 as wTipo 	
	FROM (	SELECT CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,CodOferta,DescripcionOferta,NombreCliente,dbo.fnOfertaMesActual (MesAdjudicacion, @pMes) as LitMes, ImporteContratado 
			FROM dbo.vwOfertasCliente 
			WHERE  AñoAdjudicacion=@pAño AND MesAdjudicacion = @pMes) AS vwOF
	INNER JOIN dbo.OfertaCarteraDiferida ON dbo.OfertaCarteraDiferida.CodOferta = vwOF.CodOferta

	--PRINT 'Time 1º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	
	
	-- CONTRATOS MARCO Sobre Regularizaciones (Oferta cartera Diferida)
	INSERT INTO @vContratacionObras(CodCentro,Pais,NombrePais,Año,Mes,Codoferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo)	
	SELECT  CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwRegularizacionesQ.Codoferta,DescripcionOferta,NombreCliente,dbo.fnOfertaMesActual (MesAdjudicacion, @pMes) as LitMes, sum(ImporteContratado) as ImporteContratado,0 as wTipo
	FROM   (SELECT   Codoferta,DescripcionOferta,NombreCliente,AñoAdjudicacion,MesAdjudicacion,ImporteContratado,codCentro,Pais,NombrePais
			FROM dbo.vwRegularizacionesCliente 
			WHERE  (AñoAdjudicacion = @pAño) AND (MesAdjudicacion = @pMes)) AS vwRegularizacionesQ	INNER JOIN
				 dbo.OfertaCarteraDiferida ON dbo.OfertaCarteraDiferida.CodOferta = vwRegularizacionesQ.CodOferta			
	GROUP BY CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwRegularizacionesQ.Codoferta,DescripcionOferta,NombreCliente

	--PRINT 'Time 2º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	

	-- OFERTAS
	INSERT INTO @vContratacionObras(CodCentro ,Pais,NombrePais,Año,Mes,Codoferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo)	
	SELECT CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwOfertasCliente.CodOferta,DescripcionOferta,NombreCliente,dbo.fnOfertaMesActual (MesAdjudicacion, @pMes), ImporteContratado ,1
	FROM dbo.vwOfertasCliente LEFT JOIN
		 dbo.OfertaCarteraDiferida ON dbo.OfertaCarteraDiferida.CodOferta = vwOfertasCliente.CodOferta
	WHERE  AñoAdjudicacion=@pAño AND MesAdjudicacion = @pMes AND isnull(OfertaCarteraDiferida.CodOferta,'')='' 

	--PRINT 'Time 3º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	

	-- REGULARIZACIONES
	INSERT INTO @vContratacionObras(CodCentro,Pais,NombrePais,Año,Mes,Codoferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo)	
	SELECT  CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwRegularizacionesQ.Codoferta,DescripcionOferta,NombreCliente,dbo.fnOfertaMesActual (MesAdjudicacion, @pMes) as LitMes, sum(ImporteContratado) as ImporteContratado,2 as wTipo
	FROM   (SELECT   vwRegularizacionesCliente.Codoferta,DescripcionOferta,NombreCliente,AñoAdjudicacion,MesAdjudicacion,ImporteContratado,codCentro,Pais,NombrePais
			FROM dbo.vwRegularizacionesCliente LEFT JOIN
				 dbo.OfertaCarteraDiferida ON dbo.OfertaCarteraDiferida.CodOferta = vwRegularizacionesCliente.CodOferta
			WHERE  (AñoAdjudicacion = @pAño) AND (MesAdjudicacion = @pMes) AND isnull(OfertaCarteraDiferida.CodOferta,'')='' ) AS vwRegularizacionesQ				
	GROUP BY CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwRegularizacionesQ.Codoferta,DescripcionOferta,NombreCliente

	--PRINT 'Time 4º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	

	-- OFERTASSQL (No Repartos)
	INSERT INTO @vContratacionObras(CodCentro,Pais,Año,Mes,NombrePais,Codoferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo)	
	SELECT  CodCentro,dbo.Provincias.Pais,AñoAdjudicacion,month(FAdjudicacion) as Mes, dbo.fnNombrePais(CDAUT, NMPRO)AS NombrePais,Codoferta,DescripcionOferta,NomAgrupado,dbo.fnOfertaMesActual (month(FAdjudicacion), @pMes) as LitMes, sum(ImporteContratado) as ImporteContratado,3 as wTipo
	FROM dbo.OfertasSQL INNER JOIN
	 	 dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
		 dbo.ClientesSQL ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) = @pMes --AND Reparto=0
	GROUP BY CodCentro,dbo.Provincias.Pais,AñoAdjudicacion,month(FAdjudicacion), dbo.fnNombrePais(CDAUT, NMPRO),Codoferta,DescripcionOferta,NomAgrupado,dbo.fnOfertaMesActual (month(FAdjudicacion), @pMes)

	--PRINT 'Time 5º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	

	-- Update
	
	UPDATE rptPrincipalesContratacion
	SET DescripcionOferta=w.DescripcionOferta,NombreCliente=isnull(w.NombreCliente,'-'),ImporteContratado=w.ImporteContratado,Pais=w.Pais,wTipo= w.wTipo
	FROM (
			SELECT [@vContratacionObras].CodCentro,[@vContratacionObras].codOferta,[@vContratacionObras].Pais,[@vContratacionObras].DescripcionOferta,rtrim([@vContratacionObras].NombreCliente) + ' ' + [@vContratacionObras].NombrePais as NombreCliente ,round(sum([@vContratacionObras].ImporteContratado)/1000,0) as ImporteContratado ,[@vContratacionObras].Año,[@vContratacionObras].Mes ,[@vContratacionObras].wTipo
			FROM @vContratacionObras 				 
			GROUP BY [@vContratacionObras].CodCentro,[@vContratacionObras].codOferta,[@vContratacionObras].Pais,[@vContratacionObras].DescripcionOferta,rtrim([@vContratacionObras].NombreCliente) + ' ' + [@vContratacionObras].NombrePais ,[@vContratacionObras].Año,[@vContratacionObras].Mes ,[@vContratacionObras].wTipo	
			) as w
			WHERE					
					dbo.rptPrincipalesContratacion.CodOferta = w.CodOferta AND 
					--dbo.rptPrincipalesContratacion.wTipo= w.wTipo AND
					dbo.rptPrincipalesContratacion.Año = w.Año AND
					dbo.rptPrincipalesContratacion.Mes = w.Mes AND 
					isnull(w.CodOferta,'') <> '' -- Para OfertasSQL 	

	--PRINT 'Time 6º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	
	
	-- Insertamos el Resultado	
		
	INSERT INTO rptPrincipalesContratacion(CodCentro,codOferta,Pais,DescripcionOferta,DescripcionOferta_OK,NombreCliente,NombreCliente_OK,ImporteContratado,ImporteContratado_OK,Año,Mes,wTipo)						
	SELECT w.CodCentro,w.codOferta,w.Pais,isnull(w.DescripcionOferta,''),isnull(w.DescripcionOferta,''),isnull(w.NombreCliente,'-') ,isnull(w.NombreCliente,'-') ,w.ImporteContratado,w.ImporteContratado,w.Año,w.Mes ,w.wTipo
	FROM (
						SELECT [@vContratacionObras].CodCentro,[@vContratacionObras].codOferta,[@vContratacionObras].Pais,[@vContratacionObras].DescripcionOferta,rtrim([@vContratacionObras].NombreCliente) + ' ' + [@vContratacionObras].NombrePais as NombreCliente,round(sum([@vContratacionObras].ImporteContratado)/1000,0) as ImporteContratado ,[@vContratacionObras].Año,[@vContratacionObras].Mes ,[@vContratacionObras].wTipo
						FROM @vContratacionObras 
						LEFT OUTER JOIN dbo.rptPrincipalesContratacion ON								
								isnull(dbo.rptPrincipalesContratacion.CodOferta,'') = isnull([@vContratacionObras].CodOferta,'') AND 
								--dbo.rptPrincipalesContratacion.wTipo=[@vContratacionObras].wTipo AND
								dbo.rptPrincipalesContratacion.Año = [@vContratacionObras].Año AND
								dbo.rptPrincipalesContratacion.Mes = [@vContratacionObras].Mes			             
						WHERE rptPrincipalesContratacion.DescripcionOferta IS NULL 
						GROUP BY [@vContratacionObras].CodCentro,[@vContratacionObras].codOferta,[@vContratacionObras].Pais,[@vContratacionObras].DescripcionOferta,rtrim([@vContratacionObras].NombreCliente) + ' ' + [@vContratacionObras].NombrePais ,[@vContratacionObras].Año,[@vContratacionObras].Mes ,[@vContratacionObras].wTipo) w						

	--PRINT 'Time 7º --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'	
		
	select 0
	
END