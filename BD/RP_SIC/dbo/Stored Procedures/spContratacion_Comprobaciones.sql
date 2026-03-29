
CREATE PROCEDURE [dbo].[spContratacion_Comprobaciones] 		
	@pAño int,
	@pMes int
	AS
BEGIN

	DECLARE @vContratacion TABLE (CodCentro varchar(3),CodOferta varchar(10),CodAct1 varchar(2), CodAct2 varchar(2), ImporteContratado float, Tipo varchar(100))
	
	-- OFERTAS
	INSERT INTO @vContratacion(CodCentro,CodOferta,CodAct1,CodAct2,ImporteContratado,Tipo)
	SELECT  CodCentro,CodOferta,CodAct1,CodAct2,sum(ImporteContratado), 'Oferta'
	FROM dbo.vwOFER 
	WHERE  year(FAdjudicacion)=@pAño AND month(FAdjudicacion) = @pMes 
	GROUP BY CodCentro,CodOferta,CodAct1,CodAct2	
	
	-- REGULARIZACIONES
	INSERT INTO @vContratacion(CodCentro,CodOferta,CodAct1,CodAct2,ImporteContratado,Tipo)	
	SELECT  CodCentro,CodOferta,CodAct1,CodAct2,sum(ImporteContratado), 'Regularizacion'
	FROM         (SELECT dbo.vwREG.*  
				  FROM     dbo.vwREG
				  WHERE   (year(FAdjudicacion)=@pAño) AND month(FAdjudicacion) = @pMes ) AS vwRegularizacionesQ
	GROUP BY CodCentro,CodOferta,CodAct1,CodAct2
	
	-- OFERTASsql
	INSERT INTO @vContratacion(CodCentro,CodOferta,CodAct1,CodAct2,ImporteContratado,Tipo)	
	SELECT  CodCentro,CodOferta,CodAct1,CodAct2,sum(ImporteContratado), 'OfertasSQL'
	FROM         dbo.OfertasSQL 
	WHERE  (year(FAdjudicacion)=@pAño ) AND month(FAdjudicacion) = @pMes 
	GROUP BY CodCentro,CodOferta,CodAct1,CodAct2


	SELECT CodCentro as Centro,CodOferta as Oferta,CodAct1,CodAct2,ImporteContratado as Importe, Tipo as Prodecencia,@pAño as Año,@pMes as Mes
	FROM @vContratacion
	order by CodCentro,CodOferta
		
END