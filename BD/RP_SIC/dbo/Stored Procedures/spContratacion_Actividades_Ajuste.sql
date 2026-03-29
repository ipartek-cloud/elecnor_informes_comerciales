CREATE PROCEDURE [dbo].[spContratacion_Actividades_Ajuste] 		
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
	
	-- REGULARIZACIONES
		
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT  NombreDirGeneral,CodAct1,CodAct2,Pais,sum(ImporteContratado),0
	FROM         (SELECT   CodCentro,CodAct1,CodAct2 ,Pais,ImporteContratado
				  FROM     dbo.vwRegularizaciones
				  WHERE    (AñoAdjudicacion = @pAño) AND (MesAdjudicacion <= @pMes) ) AS vwRegularizacionesQ INNER JOIN
							 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais	
	
	
	-- OFERTASsql	dbo.fnSubActividadOfertasSQL(CodAct1, CodAct2, Reparto) 
		
	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT     NombreDirGeneral,CodAct1,CodAct2,Pais,sum(ImporteContratado),0
	FROM         dbo.OfertasSQL INNER JOIN
                      dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO INNER JOIN
                      dbo.Sumarigrama ON dbo.OfertasSQL.CodCentro = dbo.Sumarigrama.CodCentro
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes
	GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais

	---------------------- OfertasSQL_Ajustes ----------------------

	INSERT INTO @vContratacionActividades(NombreDirGeneral,CodAct1,CodAct2,Pais,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoanterior)	
	SELECT     '',CodAct1,CodAct2,Pais,sum(Importe),0
	FROM         dbo.OfertasSQL_Ajustes INNER JOIN
                     dbo.Provincias ON dbo.OfertasSQL_Ajustes.CodProv = dbo.Provincias.CDPRO 
	WHERE AñoAdjudicacion=@pAño AND month(FAdjudicacion) <= @pMes
	GROUP BY CodAct1,CodAct2,Pais
	
	
	SELECT NombreDirGeneral,Pais,CodAct1 as CodActividad,Agrupacion as Actividad,Orden,ImporteContratadoAcumulado,ImporteContratadoAcumuladoAñoAnterior, 0 as ImporteContratadoAcumuladoLastYear
	FROM 
		(SELECT NombreDirGeneral,CodAct1,CodAct2,Pais,Sum(ImporteContratadoAcumulado) as ImporteContratadoAcumulado, sum(ImporteContratadoAcumuladoAñoAnterior) as ImporteContratadoAcumuladoAñoAnterior 
		 FROM @vContratacionActividades	
		 GROUP BY NombreDirGeneral,CodAct1,CodAct2,Pais) OfertasSQL
			INNER JOIN
			dbo.ActividadesSQL ON OfertasSQL.CodAct1 = dbo.ActividadesSQL.CDAC1 AND OfertasSQL.CodAct2 = dbo.ActividadesSQL.CDAC2
			
	UNION
	
	SELECT  '',Mercado,'00',Agrupacion,dbo.fnOrdenActividadAgrupacion(Agrupacion),0,sum(Importe), 0 as ImporteContratadoAcumuladoLastYear
	FROM Historico_Mercado_ActividadSQL
	WHERE Año=@pAño-1 
	GROUP BY Agrupacion,Mercado	

	UNION -- Modificacion 9/6/2014

	SELECT '',Mercado,'LY',Agrupacion,Orden,0,0, sum(Importe) as ImporteContratadoAcumuladoLastYear
	FROM            dbo.ActividadesSQL INNER JOIN
                         dbo.HistoricoContratacionGrupoSQL ON dbo.ActividadesSQL.CDAC1 = dbo.HistoricoContratacionGrupoSQL.CodAct1 AND 
                         dbo.ActividadesSQL.CDAC2 = dbo.HistoricoContratacionGrupoSQL.CodAct2
	WHERE Año=@pAño-1 AND Mes<= @pMes
	GROUP BY Agrupacion,Mercado,Orden
		
END