CREATE PROCEDURE [dbo].[spContratacion_Obras] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vImporteContratadoSUP float
	DECLARE @vImporteContratadoINF float
		
	DECLARE @vContratacionObras TABLE (CodCentro varchar(50) ,Pais varchar(50),NombrePais varchar(50),Año int,Mes int,CodOferta varchar(10), DescripcionOferta varchar(100),NombreCliente varchar(100), ImporteContratado float, LitMes varchar(20), wTipo int)	

	-- CONTRATOS MARCO Sobre Ofertas (Oferta cartera Diferida)
	INSERT INTO @vContratacionObras(CodCentro ,Pais,NombrePais,Año,Mes,CodOferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo)	
	SELECT CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwOF.CodOferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado ,0 as wTipo 	
	FROM (	SELECT CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,CodOferta,DescripcionOferta,NombreCliente,dbo.fnOfertaMesActual (MesAdjudicacion, @pMes) as LitMes, ImporteContratado 
			FROM dbo.vwOfertasCliente 
			WHERE  AñoAdjudicacion=@pAño AND MesAdjudicacion = @pMes) AS vwOF
	INNER JOIN dbo.OfertaCarteraDiferida ON dbo.OfertaCarteraDiferida.CodOferta = vwOF.CodOferta
	
	-- CONTRATOS MARCO Sobre Regularizaciones (Oferta cartera Diferida)
	INSERT INTO @vContratacionObras(CodCentro,Pais,NombrePais,Año,Mes,Codoferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo)	
	SELECT  CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwRegularizacionesQ.Codoferta,DescripcionOferta,NombreCliente,dbo.fnOfertaMesActual (MesAdjudicacion, @pMes) as LitMes, sum(ImporteContratado) as ImporteContratado,0 as wTipo
	FROM   (SELECT   Codoferta,DescripcionOferta,NombreCliente,AñoAdjudicacion,MesAdjudicacion,ImporteContratado,codCentro,Pais,NombrePais
			FROM dbo.vwRegularizacionesCliente 
			WHERE  (AñoAdjudicacion = @pAño) AND (MesAdjudicacion = @pMes)) AS vwRegularizacionesQ	INNER JOIN
				 dbo.OfertaCarteraDiferida ON dbo.OfertaCarteraDiferida.CodOferta = vwRegularizacionesQ.CodOferta			
	GROUP BY CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwRegularizacionesQ.Codoferta,DescripcionOferta,NombreCliente
	
	-- OFERTAS
	INSERT INTO @vContratacionObras(CodCentro ,Pais,NombrePais,Año,Mes,Codoferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo)	
	SELECT CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwOfertasCliente.CodOferta,DescripcionOferta,NombreCliente,dbo.fnOfertaMesActual (MesAdjudicacion, @pMes), ImporteContratado ,1
	FROM dbo.vwOfertasCliente LEFT JOIN
		 dbo.OfertaCarteraDiferida ON dbo.OfertaCarteraDiferida.CodOferta = vwOfertasCliente.CodOferta
	WHERE  AñoAdjudicacion=@pAño AND MesAdjudicacion = @pMes 
-- Paco 13/12/2022				AND isnull(vwOfertasCliente.CodOferta,-1)=-1 
			AND isnull(OfertaCarteraDiferida.CodOferta,'')='' 
	
	-- REGULARIZACIONES
	INSERT INTO @vContratacionObras(CodCentro,Pais,NombrePais,Año,Mes,Codoferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo)	
	SELECT  CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwRegularizacionesQ.Codoferta,DescripcionOferta,NombreCliente,dbo.fnOfertaMesActual (MesAdjudicacion, @pMes) as LitMes, sum(ImporteContratado) as ImporteContratado,2 as wTipo
	FROM   (SELECT   vwRegularizacionesCliente.Codoferta,DescripcionOferta,NombreCliente,AñoAdjudicacion,MesAdjudicacion,ImporteContratado,codCentro,Pais,NombrePais
			FROM dbo.vwRegularizacionesCliente LEFT JOIN
				 dbo.OfertaCarteraDiferida ON dbo.OfertaCarteraDiferida.CodOferta = vwRegularizacionesCliente.CodOferta
			WHERE  (AñoAdjudicacion = @pAño) AND (MesAdjudicacion = @pMes) 
-- Paco 13/12/2022					AND isnull(vwRegularizacionesCliente.CodOferta,-1)=-1 
					AND isnull(OfertaCarteraDiferida.CodOferta,'')=''
			) AS vwRegularizacionesQ				
	GROUP BY CodCentro,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,vwRegularizacionesQ.Codoferta,DescripcionOferta,NombreCliente

	-- OFERTASSQL (No Repartos)
	INSERT INTO @vContratacionObras(CodCentro,Pais,Año,Mes,NombrePais,Codoferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo)	
	SELECT  CodCentro,dbo.Provincias.Pais,AñoAdjudicacion,month(FAdjudicacion) as Mes, dbo.fnNombrePais(CDAUT, NMPRO)AS NombrePais,Codoferta,DescripcionOferta,NomAgrupado,dbo.fnOfertaMesActual (month(FAdjudicacion), @pMes) as LitMes, sum(ImporteContratado) as ImporteContratado,3 as wTipo
	FROM dbo.OfertasSQL INNER JOIN
	 	 dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
		 dbo.ClientesSQL ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) = @pMes AND Reparto=0
	GROUP BY CodCentro,dbo.Provincias.Pais,AñoAdjudicacion,month(FAdjudicacion), dbo.fnNombrePais(CDAUT, NMPRO),Codoferta,DescripcionOferta,NomAgrupado,dbo.fnOfertaMesActual (month(FAdjudicacion), @pMes)

	-- Update
	UPDATE rptPrincipalesObras
	SET DescripcionOferta=w.DescripcionOferta,NombreCliente=isnull(w.NombreCliente,'-'),ImporteContratado=w.ImporteContratado,Pais=w.Pais
	FROM (
			SELECT [@vContratacionObras].CodCentro,[@vContratacionObras].codOferta,[@vContratacionObras].Pais,[@vContratacionObras].DescripcionOferta,rtrim([@vContratacionObras].NombreCliente) + ' ' + [@vContratacionObras].NombrePais as NombreCliente ,round(sum([@vContratacionObras].ImporteContratado)/1000,0) as ImporteContratado ,[@vContratacionObras].Año,[@vContratacionObras].Mes ,[@vContratacionObras].wTipo
			FROM @vContratacionObras 				 
			GROUP BY [@vContratacionObras].CodCentro,[@vContratacionObras].codOferta,[@vContratacionObras].Pais,[@vContratacionObras].DescripcionOferta,rtrim([@vContratacionObras].NombreCliente) + ' ' + [@vContratacionObras].NombrePais ,[@vContratacionObras].Año,[@vContratacionObras].Mes ,[@vContratacionObras].wTipo	
			) as w
			WHERE
					dbo.rptPrincipalesObras.DescripcionOferta = w.DescripcionOferta AND 
					isnull(dbo.rptPrincipalesObras.CodOferta,'') = isnull(w.CodOferta,'') AND 
					dbo.rptPrincipalesObras.wTipo= w.wTipo AND
					dbo.rptPrincipalesObras.Año = w.Año AND
					dbo.rptPrincipalesObras.Mes = w.Mes
	
	-- Insertamos el Resultado		
	INSERT INTO rptPrincipalesObras(CodCentro,codOferta,Pais,DescripcionOferta,DescripcionOferta_OK,NombreCliente,NombreCliente_OK,ImporteContratado,ImporteContratado_OK,Año,Mes,wTipo)						
	SELECT w.CodCentro,w.codOferta,w.Pais,isnull(w.DescripcionOferta,''),isnull(w.DescripcionOferta,''),isnull(w.NombreCliente,'-'),isnull(w.NombreCliente,'-') ,w.ImporteContratado,w.ImporteContratado,w.Año,w.Mes ,w.wTipo
	FROM (
						SELECT [@vContratacionObras].CodCentro,[@vContratacionObras].codOferta,[@vContratacionObras].Pais,[@vContratacionObras].DescripcionOferta,rtrim([@vContratacionObras].NombreCliente) + ' ' + [@vContratacionObras].NombrePais as NombreCliente,round(sum([@vContratacionObras].ImporteContratado)/1000,0) as ImporteContratado ,[@vContratacionObras].Año,[@vContratacionObras].Mes ,[@vContratacionObras].wTipo
						FROM @vContratacionObras 
						LEFT OUTER JOIN dbo.rptPrincipalesObras ON
								dbo.rptPrincipalesObras.DescripcionOferta = [@vContratacionObras].DescripcionOferta AND 
								isnull(dbo.rptPrincipalesObras.CodOferta,'') = isnull([@vContratacionObras].CodOferta,'') AND 
								dbo.rptPrincipalesObras.wTipo=[@vContratacionObras].wTipo AND
								dbo.rptPrincipalesObras.Año = [@vContratacionObras].Año AND
								dbo.rptPrincipalesObras.Mes = [@vContratacionObras].Mes			             
						WHERE rptPrincipalesObras.DescripcionOferta IS NULL 
						GROUP BY [@vContratacionObras].CodCentro,[@vContratacionObras].codOferta,[@vContratacionObras].Pais,[@vContratacionObras].DescripcionOferta,rtrim([@vContratacionObras].NombreCliente) + ' ' + [@vContratacionObras].NombrePais ,[@vContratacionObras].Año,[@vContratacionObras].Mes ,[@vContratacionObras].wTipo) w
	LEFT OUTER JOIN dbo.OfertaAsociadaInversion ON	OfertaAsociadaInversion.JVAYNB=w.CodOferta					
	WHERE isnull(JVAYNB,'')=''
					
	select 0
	
END