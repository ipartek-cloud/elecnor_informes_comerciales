
CREATE VIEW [dbo].[vwTIPOUNO_Produccion_Detallado_WEB]
AS
SELECT        dbo.ObrasActualesSQL.Año, dbo.ObrasActualesSQL.Mes, dbo.vwTipoUNO_Detallado.CTRO AS CodCentro, dbo.vwTipoUNO_Detallado.CDOFT AS CodOferta, 
                         dbo.ObrasActualesSQL.OBRA, dbo.ObrasActualesSQL.OBRAL, 
                         dbo.vwTipoUNO_Detallado.OBRA + '-' + dbo.vwTipoUNO_Detallado.OBRAL + ' ' + dbo.ObrasActualesSQL.DSOBR AS NombreObra, SUM(dbo.ObrasActualesSQL.SOP) 
                         AS ImporteProduccion, SUM(dbo.ObrasActualesSQL.SOF) AS ImporteFactura, SUM(dbo.ObrasActualesSQL.SOL) AS ImporteFot, dbo.ObrasActualesSQL.STOBR AS Est, 
                         dbo.vwTipoUNO_Detallado.FECHAAPERTURA, dbo.vwTipoUNO_Detallado.FECHACIERRE
FROM            dbo.vwTipoUNO_Detallado INNER JOIN
                         dbo.ObrasActualesSQL ON dbo.vwTipoUNO_Detallado.CTRO = dbo.ObrasActualesSQL.CTR AND 
                         dbo.vwTipoUNO_Detallado.OBRA = dbo.ObrasActualesSQL.OBRA AND dbo.vwTipoUNO_Detallado.OBRAL = dbo.ObrasActualesSQL.OBRAL
GROUP BY dbo.ObrasActualesSQL.Año, dbo.ObrasActualesSQL.Mes, dbo.vwTipoUNO_Detallado.CTRO, dbo.vwTipoUNO_Detallado.OBRA, dbo.vwTipoUNO_Detallado.OBRAL, 
                         dbo.ObrasActualesSQL.DSOBR, dbo.ObrasActualesSQL.STOBR, dbo.vwTipoUNO_Detallado.CDOFT, dbo.vwTipoUNO_Detallado.FECHAAPERTURA, 
                         dbo.vwTipoUNO_Detallado.FECHACIERRE, dbo.ObrasActualesSQL.OBRA, dbo.ObrasActualesSQL.OBRAL

