CREATE PROCEDURE [dbo].[spContratacion_Obras_Asociadas_Inversion] 		
	@pAño int,
	@pMes int
	AS
BEGIN
	
	DECLARE @vContratacionObrasAI TABLE (NombreDirNegocio varchar(30), Pais varchar(50),NombrePais varchar(50),Año int,Mes int,CodOferta varchar(10), DescripcionOferta varchar(100),NombreCliente varchar(100), ImporteContratado float, LitMes varchar(20), wTipo int, CodCentro varchar(3))	
	
	-- OFERTAS
	INSERT INTO @vContratacionObrasAI(NombreDirNegocio,Pais,NombrePais,Año,Mes,CodOferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo,CodCentro)	
	SELECT NombreDirNegocio,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,CodOferta,DescripcionOferta,isnull(NombreCliente,' '),dbo.fnOfertaMesActual (MesAdjudicacion, @pMes), sum(ImporteContratado) as ImporteContratado,1,dbo.vwOfertasAICliente.CodCentro
	FROM dbo.vwOfertasAICliente LEFT JOIN dbo.Sumarigrama
		  ON dbo.Sumarigrama.CodCentro = dbo.vwOfertasAICliente.CodCentro
	WHERE  AñoAdjudicacion=@pAño AND MesAdjudicacion <= @pMes 
	GROUP BY NombreDirNegocio,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,CodOferta,DescripcionOferta,NombreCliente,NombrePais,MesAdjudicacion,dbo.vwOfertasAICliente.CodCentro	

	-- REGULARIZACIONES
	
	INSERT INTO @vContratacionObrasAI(NombreDirNegocio,Pais,NombrePais,Año,Mes,CodOferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo,CodCentro)	
	SELECT  NombreDirNegocio,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,Codoferta,DescripcionOferta,isnull(NombreCliente,' '),dbo.fnOfertaMesActual (MesAdjudicacion, @pMes) as LitMes, sum(ImporteContratado) as ImporteContratado,2 as wTipo,vwRegularizacionesQ.CodCentro
	FROM         (SELECT   Codoferta,DescripcionOferta,NombreCliente,AñoAdjudicacion,MesAdjudicacion,ImporteContratado,codCentro,Pais,NombrePais
				  FROM     dbo.vwRegularizacionesAICliente
				  WHERE    (AñoAdjudicacion = @pAño) AND (MesAdjudicacion <= @pMes)) AS vwRegularizacionesQ LEFT JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY NombreDirNegocio,Pais,NombrePais,AñoAdjudicacion,MesAdjudicacion,Codoferta,DescripcionOferta,NombreCliente,vwRegularizacionesQ.CodCentro		

	-- OFERTASsql	
/*	INSERT INTO @vContratacionObrasAI(NombreDirNegocio,Pais,Año,Mes,NombrePais,CodOferta,DescripcionOferta,NombreCliente,LitMes,ImporteContratado,wTipo)	
	SELECT  NombreDirNegocio,dbo.Provincias.Pais,AñoAdjudicacion,month(FAdjudicacion), dbo.fnNombrePais(CDAUT, NMPRO)AS NombrePais,Codoferta,DescripcionOferta,NomAgrupado,dbo.fnOfertaMesActual (month(FAdjudicacion), @pMes), sum(ImporteContratado) as ImporteContratado,3 as wTipo
	FROM dbo.OfertasSQL INNER JOIN
         dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
         dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro INNER JOIN
         dbo.ClientesSQL ON dbo.OfertasSQL.CodCliente = dbo.ClientesSQL.CodCliente INNER JOIN
          dbo.OfertaAsociadaInversion ON dbo.OfertasSQL.CodOferta = dbo.OfertaAsociadaInversion.JVAYNB
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes
	GROUP BY NombreDirNegocio,dbo.Provincias.Pais,AñoAdjudicacion,month(FAdjudicacion), dbo.fnNombrePais(CDAUT, NMPRO),Codoferta,DescripcionOferta,NomAgrupado,dbo.fnOfertaMesActual (month(FAdjudicacion), @pMes)		
*/		
	
			-- ACTUALIZAMOS EXISTENTES
	
			UPDATE rptPrincipalesObrasAI
			SET NombreDirNegocio=w.NombreDirNegocio,
				Pais=w.Pais,
				DescripcionOferta=w.DescripcionOferta,
				NombreCliente=isnull(w.NombreCliente,''),
				ImporteContratado=round(w.ImporteContratado/1000,0),
				Año=w.Año,
				Mes=w.Mes,
				CodCentro=w.CodCentro
			FROM (SELECT isnull(NombreDirNegocio,'-') as NombreDirNegocio,Pais,CodOferta,DescripcionOferta,rtrim(NombreCliente) + ' ' + NombrePais as NombreCliente,Año,Mes,sum(ImporteContratado) as ImporteContratado,wTipo,MAX(CodCentro) as CodCentro
				  FROM @vContratacionObrasAI
				  WHERE Año=@pAño
				  GROUP BY isnull(NombreDirNegocio,'-'),Pais,CodOferta,DescripcionOferta,rtrim(NombreCliente) + ' ' + NombrePais,Año,Mes,wTipo 
			) as w
			WHERE 
				  dbo.rptPrincipalesObrasAI.CodOferta = w.CodOferta AND
				  dbo.rptPrincipalesObrasAI.wTipo=w.wTipo AND
			      dbo.rptPrincipalesObrasAI.Año = w.Año AND
			      dbo.rptPrincipalesObrasAI.Mes = w.Mes 			
			
			-- AÑADIMOS NUEVOS	

			INSERT INTO rptPrincipalesObrasAI(NombreDirNegocio,NombreDirNegocio_OK,Pais,DescripcionOferta,DescripcionOferta_OK,NombreCliente,NombreCliente_OK,ImporteContratado,ImporteContratado_OK,Año,Mes,CodOferta,wTipo,CodCentro)			
			SELECT isnull(w.NombreDirNegocio,'-'),isnull(w.NombreDirNegocio,'-'),w.Pais,w.DescripcionOferta,w.DescripcionOferta,rtrim(isnull(w.NombreCliente,'')) + ' ' + isnull(w.NombrePais,''),rtrim(isnull(w.NombreCliente,'')) + ' ' +isnull( w.NombrePais,''),round((sum(w.ImporteContratado)/1000),0) ,round((sum(w.ImporteContratado)/1000),0),w.Año,w.Mes,w.CodOferta,w.wTipo,MAX(w.CodCentro) as CodCentro
			FROM  @vContratacionObrasAI as w LEFT OUTER JOIN dbo.rptPrincipalesObrasAI ON
				  dbo.rptPrincipalesObrasAI.CodOferta = w.CodOferta AND 
                  dbo.rptPrincipalesObrasAI.wTipo=w.wTipo AND
                  dbo.rptPrincipalesObrasAI.Año = w.Año AND
                  dbo.rptPrincipalesObrasAI.Mes = w.Mes			             
            WHERE rptPrincipalesObrasAI.DescripcionOferta IS NULL AND w.Año=@pAño
			GROUP BY isnull(w.NombreDirNegocio,'-'),w.Pais,w.DescripcionOferta,rtrim(isnull(w.NombreCliente,'')) + ' ' + isnull(w.NombrePais,''),w.Año,w.Mes,w.CodOferta,w.wTipo				
	
	select 0
	
END