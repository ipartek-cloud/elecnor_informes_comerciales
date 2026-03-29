CREATE FUNCTION [dbo].[fnContratacionMensual] (@pMercado varchar(50),@pAño int,@pMes int)
RETURNS float
AS  
BEGIN
-- @pMercado : Internacional,Nacional

DECLARE @ContratacionMensual_Ofertas as float
DECLARE @ContratacionMensual_Regularizaciones as float
DECLARE @ContratacionMensual_OfertasSQL as float

-- OFERTAS
SELECT @ContratacionMensual_Ofertas=sum(ImporteContratado)
FROM dbo.Sumarigrama INNER JOIN
     dbo.vwOfertas ON dbo.Sumarigrama.CodCentro = dbo.vwOfertas.CodCentro
WHERE Pais=@pMercado AND AñoAdjudicacion=@pAño AND MesAdjudicacion = @pMes AND Adjudicada='S'

-- REGULARIZACIONES
SELECT  @ContratacionMensual_Regularizaciones=sum(vwRegularizacionesQ.ImporteContratado)
FROM         (SELECT     CodCentro, CodOferta, NumRegularizacion, FAlta, DescripcionOferta, CodCliente, Localidad, CodProv, ImporteAprox, CodAct1, CodAct2, 
                         CodResponsable, FPresentacion, PresupuestoVenta, FAdjudicacion, AñoAdjudicacion, MesAdjudicacion, Adjudicada, ImporteContratado,Pais
              FROM          dbo.vwRegularizaciones
              WHERE     (Pais=@pMercado) AND (AñoAdjudicacion = @pAño) AND (MesAdjudicacion = @pMes) AND Adjudicada='S') AS vwRegularizacionesQ INNER JOIN
						 dbo.Sumarigrama ON vwRegularizacionesQ.CodCentro = dbo.Sumarigrama.CodCentro

-- OFERTASsql
SELECT @ContratacionMensual_OfertasSQL=sum(ImporteContratado)    
FROM dbo.OfertasSQL INNER JOIN
     dbo.Provincias ON dbo.OfertasSQL.CodProv = dbo.Provincias.CDPRO
WHERE Pais=@pMercado AND AñoAdjudicacion=@pAño AND month(FAdjudicacion) = @pMes 
	
RETURN(@ContratacionMensual_Ofertas + @ContratacionMensual_Regularizaciones+@ContratacionMensual_OfertasSQL)

END
