
-- exec [dbo].[spWEB_CarteraDiferidaPdteEjecutar_OfertaObras] 2019,4,1737200009,'372'

CREATE PROCEDURE [dbo].[spWEB_CarteraDiferidaPdteEjecutar_OfertaObras]	
	@pAño int,
	@pMes int,
	@pCodOferta varchar(10),
	@pCodCentro varchar(3)
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY
	
		DECLARE @SQL_AS400_select as varchar(1000)
		DECLARE @SQL_AS400_from as varchar(1000)
		DECLARE @SQL_AS400 as varchar(max)
	
		CREATE TABLE #Enlaces  (CTRO numeric(3,0), OBRA varchar(5), CDOFT numeric(10,0), FechaApertura varchar(10), FechaCierre varchar(10))	

		SET @SQL_AS400_select = 'INSERT INTO #Enlaces (CTRO, OBRA, CDOFT, FechaApertura, FechaCierre)
								 SELECT CTRO, OBRA, CDOFT, AAMMA, AAMMC'

		SET @SQL_AS400_from = 'SELECT * FROM OPENQUERY(SIC, 
									'' SELECT CTRO, OBRA, CDOFT, AAMMA, AAMMC
									   FROM S44DD901.FICOSCO.CO005BP as Enlaces
									   WHERE CTRO=' + @pCodCentro + ' AND CDOFT='+ cast(@pCodOferta as varchar(10))+''')'
							 	
		SET @SQL_AS400 = @SQL_AS400_select + ' FROM (' + @SQL_AS400_from + ') vwWEB_Enlaces'	
		EXEC (@SQL_AS400)

		SELECT vw.CDOFT as CodOferta, vw.OBRA, vw.OBRAL, vw.DSOBR as NombreObra,  dbo.fnFormatFecha(vw.FechaApertura) as FechaApertura,dbo.fnFormatFecha(vw.FechaCierre) as FechaCierre,
		vw.Produccion_A/1000 as Produccion_A, vw.MargenProduccion_A/1000 as MargenProduccion_A,
		vw.Facturacion_A/1000 as Facturacion_A,vw.Facturacion_Origen_A/1000 as Facturacion_Origen_A,vw.Facturacion_Anticipada_A/1000 as Facturacion_Anticipada_A,vw.Produccion_Curso_A/1000 as Produccion_Curso_A			 		
		FROM( 
				SELECT E.CDOFT, O.OBRA, O.OBRAL, O.DSOBR,
				SUM(O.SAP) Produccion_A,				
				SUM(O.SAP) - SUM((O.SAMO + O.SAMA + O.SAE + O.SAT + O.SAS + O.SAV + O.SAI + O.SAPR)) MargenProduccion_A,
				E.FechaApertura, E.FechaCierre,
				SUM(O.SAF) Facturacion_A,
				SUM(O.SOF) Facturacion_Origen_A,
				SUM(O.SOF-O.SOL) Facturacion_Anticipada_A,
				SUM(O.SOP-O.SOL) Produccion_Curso_A
				FROM (
					SELECT * FROM #Enlaces
				) E INNER JOIN 
				(
					SELECT * FROM ObrasActualesSQL WHERE Año = @pAño AND Mes = @pMes AND NOT (STOBR='C' AND SAP=0 AND (SAMO + SAMA + SAE + SAT + SAS +SAV + SAI + SAPR)=0)
				) O ON E.CTRO=O.CTR AND E.OBRA=O.OBRA+O.OBRAL 	
			GROUP BY E.CDOFT, O.OBRA, O.OBRAL, O.DSOBR,E.FechaApertura, E.FechaCierre
		) vw
		ORDER BY vw.OBRA, vw.OBRAL	

		--return (0)	
	
	END TRY
	BEGIN CATCH	
		return  ERROR_NUMBER ()		
	END CATCH
	
END