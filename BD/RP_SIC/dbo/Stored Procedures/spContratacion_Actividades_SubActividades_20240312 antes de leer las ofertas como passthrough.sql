
--[dbo].[spContratacion_Actividades_SubActividades] 		 2019,2

CREATE PROCEDURE [dbo].[spContratacion_Actividades_SubActividades_20240312 antes de leer las ofertas como passthrough] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @vContratacionActividades TABLE (NombreDirGeneral varchar(100),CodAct1 varchar(2),CodAct2 varchar(2),Pais varchar(50), ImporteContratadoAcumulado float, ImporteContratadoAcumuladoAñoanterior float)
	
	-- OFERTAS
			
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT NombreDirGeneral,CodAct1,CodAct2,Pais,sum(ImporteContratado),0
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.vwOfertas ON dbo.Sumarigrama.CodCentro = dbo.vwOfertas.CodCentro
	WHERE  AñoAdjudicacion=@pAño AND MesAdjudicacion <= @pMes 
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais
	
	/*
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT NombreDirGeneral,CodAct1,CodAct2,Pais,0,sum(ImporteContratado)
	FROM dbo.Sumarigrama INNER JOIN
		 dbo.vwOfertas ON dbo.Sumarigrama.CodCentro = dbo.vwOfertas.CodCentro
	WHERE  AñoAdjudicacion=@pAño-1 AND MesAdjudicacion <= @pMes --AND Adjudicada='S'
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais
	*/
	
	-- REGULARIZACIONES
		
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  NombreDirGeneral,CodAct1,CodAct2,Pais,sum(ImporteContratado),0
	FROM         (SELECT   CodCentro,CodAct1,CodAct2 ,Pais,ImporteContratado
				  FROM     dbo.vwRegularizaciones
				  WHERE    (AñoAdjudicacion = @pAño) AND (MesAdjudicacion <= @pMes) ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais
	
	/*
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  NombreDirGeneral,CodAct1,CodAct2,Pais,0,sum(ImporteContratado)
	FROM         (SELECT   CodCentro,CodAct1,CodAct2 ,Pais,ImporteContratado
				  FROM     dbo.vwRegularizaciones
				  WHERE    (AñoAdjudicacion = @pAño-1) AND (MesAdjudicacion <= @pMes) ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais
	*/

	-- OFERTASsql	dbo.fnSubActividadOfertasSQL(CodAct1, CodAct2, Reparto) 
		
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT     NombreDirGeneral,CodAct1,CodAct2,Pais,sum(ImporteContratado),0
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais
	
	/*
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT     NombreDirGeneral,CodAct1,CodAct2,Pais,0,sum(ImporteContratado)
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
	WHERE AñoAdjudicacion=@pAño-1 AND month(FAdjudicacion) <= @pMes
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais	
	*/
	
	
	/*
	SELECT NombreDirGeneral,Pais,CodAct1 as CodActividad,Agrupacion as Actividad,CodAct1,CodAct2,Orden,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoAnterior 
	FROM 
		(SELECT NombreDirGeneral,CodAct1,CodAct2,Pais,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 
		 FROM @vContratacionActividades	
		 GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais) OfertasSQL
			INNER JOIN
			dbo.ActividadesSQL ON OfertasSQL.CodAct1 = dbo.ActividadesSQL.CDAC1 AND OfertasSQL.CodAct2 = dbo.ActividadesSQL.CDAC2
	*/
				
	SELECT NombreDirGeneral,Pais,CodAct1 as CodActividad,Agrupacion as Actividad,CodAct1,CodAct2,Orden,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoAnterior,0 as Desglose_AñoAnterior
	FROM 
		(SELECT NombreDirGeneral,CodAct1,CodAct2,Pais,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 
		 FROM @vContratacionActividades	
		 GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais) OfertasSQL
			INNER JOIN
			dbo.ActividadesSQL ON OfertasSQL.CodAct1 = dbo.ActividadesSQL.CDAC1 AND OfertasSQL.CodAct2 = dbo.ActividadesSQL.CDAC2
			
	UNION -- Nivel Superior de Año Anterior	
	
	SELECT  '',Mercado,dbo.fnAgrupacionCDAC1(Agrupacion),Agrupacion,dbo.fnAgrupacionCDAC1(Agrupacion),'00',dbo.fnOrdenActividadAgrupacion(Agrupacion),0,sum(Importe),0 as Desglose_AñoAnterior
	FROM Historico_Mercado_ActividadSQL
	WHERE Año=@pAño-1 
	GROUP BY Agrupacion,Mercado	
	
	UNION -- Desglose de Año Anterior
	
	--SELECT  '',Mercado,dbo.fnAgrupacionCDAC1(Agrupacion),Agrupacion,dbo.fnAgrupacionCDAC1(Agrupacion),CodAct2,dbo.fnOrdenActividadAgrupacion(Agrupacion),0,sum(Importe*1000),1 as Desglose_AñoAnterior
	--FROM Historico_Mercado_SubActividadSQL
	--WHERE Año=@pAño-1 
	--GROUP BY Agrupacion,Mercado,CodAct2	
	
	SELECT  '',Mercado,dbo.fnAgrupacionCDAC1(Agrupacion),Agrupacion,dbo.fnAgrupacionCDAC1(Agrupacion),CodAct2,dbo.fnOrdenActividadAgrupacion(Agrupacion),0,sum(Importe),1 as Desglose_AñoAnterior
	FROM Historico_Mercado_SubActividadSQL
	WHERE Año=@pAño-1 
	GROUP BY Agrupacion,Mercado,CodAct2			
	
END
