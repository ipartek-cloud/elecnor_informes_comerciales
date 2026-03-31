
CREATE PROCEDURE [dbo].[sp_Exportacion_Contratacion_Analitica]
 @pCentros varchar(max)=''
AS
BEGIN
PRINT DB_NAME() + '..sp_Exportacion_Contratacion_Analitica ' + @pCentros

declare @LoggerError as varchar(1000)=DB_NAME() + '..sp_Exportacion_Contratacion_Analitica ' + @pCentros
declare @MenError as varchar(1000)= @LoggerError 
declare @FechaError as datetime=GETDATE()

BEGIN TRY

	DECLARE @Sql as varchar(max)
	DECLARE @CondicionCentros as varchar(max) = ''

	IF ISNULL(@pCentros, '') <> ''
		SET @CondicionCentros = ' AND R.CDCEN IN (' + REPLACE(@pCentros, '''', '''''') + ')' -- Para que al formar la cadena de Sql se tomen las comillas
	ELSE
		SET @CondicionCentros = ' AND 1=2' -- Para que al formar la cadena de Sql se tomen las comillas

	CREATE TABLE #Ofertas (IdOferta varchar(10), IdRegularizacion int, Oferta varchar(200), IdCliente varchar(8), Cliente varchar(200), IdProvPais varchar(2), ImporteAdjudicado float, ImporteOfertado float, Tipo varchar(1), FechaAdjudicacion date, Causa varchar(100), Baja varchar(1), IdCentroE varchar(3), AA varchar(4), MM varchar(2))
	CREATE TABLE #Regularizaciones (IdOferta varchar(10), IdRegularizacion int, Oferta varchar(1000), IdCliente varchar(8), Cliente varchar(1000), IdProvPais varchar(2), ImporteAdjudicado float, ImporteOfertado float, Tipo varchar(1), FechaAdjudicacion date, Causa varchar(100), Baja varchar(1), IdCentroE varchar(3), AA varchar(4), MM varchar(2))
	CREATE TABLE #OfertasSQL (IdOfe@pCentrosrta varchar(10), IdRegularizacion int, Oferta varchar(1000), IdCliente varchar(8), Cliente varchar(1000), IdProvPais varchar(2), ImporteAdjudicado float, ImporteOfertado float, Tipo varchar(1), FechaAdjudicacion date, Causa varchar(100), Baja varchar(1), IdCentroE varchar(3), AA varchar(4), MM varchar(2))

	SET @Sql = 'SELECT CDOFT IdOferta, 0 IdRegularizacion, REPLACE(DCOF, CHAR(26),'''') Oferta, CDCLI IdCliente, DESPRO Cliente, PROOF IdProvPais, PREAD ImporteAdjudicado, IMAOF ImporteOfertado, WS10 Tipo, CAST(AA+MM+DD as date) FechaAdjudicacion
					, ''CONTRATO'' Causa, BAJA Baja
					, CDCEN IdCentroE 
					, AA, MM
				FROM OPENQUERY(SIC, ''	
										SELECT CDCEN, CDOFT, 0 NUMREG, DCOF, CDCLI, DESPRO, FECHAD, PREAD, IMAOF, 
											substr( digits(dec(19000000+FECHAD,8,0)), 1, 4 ) AA,
											substr( digits(dec(19000000+FECHAD,8,0)), 5, 2 ) MM,
											substr( digits(dec(19000000+FECHAD,8,0)), 7, 2 ) DD
											, substr( digits(dec(19000000+FECHAD,8,0)), 1, 8 ) FechaF
											, BAJA, WS10, PROOF
										FROM S44DD901.ICOMERF.IC09AP R
										WHERE Adele=''''S''''
											AND WS10=''''F''''
											AND FECHAD<>0
											AND UCASE(PROOF)<>LCASE(PROOF) -- Para sacar sólo las ofertas de internacional (campo Pais no numerico)
											' + @CondicionCentros + '
								'') Ofertas
								--WHERE LEN(BAJA)>1
				'
	PRINT (@Sql)
	INSERT INTO #Ofertas
	EXEC (@Sql)

	SET @Sql = 'SELECT CDOFT IdOferta, NUMRE Idregularizacion, REPLACE(DCOF, CHAR(26),'''') Oferta, CDCLI IdCliente, DESPRO Cliente, PROOF IdProvPais, IMPRE ImporteAdjudicado, 0 ImporteOfertado, WS10 Tipo, CAST(AA+MM+DD as date) FechaAdjudicacion
					, CAUS Causa, BAJA Baja
					, CDCEN IdCentroE 
					, AA, MM
				FROM OPENQUERY(SIC, ''	
										SELECT R.CDCEN, R.CDOFT, NUMRE, O.DCOF, O.CDCLI, O.DESPRO, FECHAR, IMPRE, CAUS,
											substr( digits(dec(19000000+FECHAR,8,0)), 1, 4 ) AA,
											substr( digits(dec(19000000+FECHAR,8,0)), 5, 2 ) MM,
											substr( digits(dec(19000000+FECHAR,8,0)), 7, 2 ) DD
											, substr( digits(dec(19000000+FECHAR,8,0)), 1, 8 ) FechaF
											, O.BAJA, O.WS10, O.PROOF
									FROM S44DD901.ICOMERF.IC10AP R 
											INNER JOIN S44DD901.ICOMERF.IC09AP O ON R.CDCEN=O.CDCEN AND R.CDOFT=O.CDOFT
										WHERE O.Adele=''''S''''
											AND O.WS10=''''F''''
											AND FECHAR<>0
											AND UCASE(O.PROOF)<>LCASE(O.PROOF) -- Para sacar sólo las ofertas de internacional (campo Pais no numerico)
											' + @CondicionCentros + '
								'') Regularizaciones 
				'
	--PRINT (@Sql)	
	INSERT INTO #Regularizaciones
	EXEC (@Sql)

	IF ISNULL(@pCentros, '') <> ''
		SET @CondicionCentros = ' AND R.CDCEN IN (' + @pCentros + ')' -- Para deshacer el doblecomillado

	SET @Sql = 'SELECT CodOferta IdOferta, ISNULL(NumRegularizacion, 0) IdRegularizacion, REPLACE(DescripcionOferta, CHAR(26),'''') Oferta, CodCliente Idcliente, '''' Cliente, CodProv IdProvPais, 
					SUM(ISNULL(ImporteContratado,0)) ImporteAdjudicado, SUM(ISNULL(PresupuestoVenta,0)) ImporteOfertado, '''' Tipo, CAST(FAdjudicacion as date) FechaAdjudicacion
					, CASE WHEN NumRegularizacion=0 THEN ''CONTRATO'' ELSE ''REGULARIZACION'' END Causa, '''' Baja
					, CodCentro_Origen IdCentroE  
					, YEAR(Fadjudicacion) AA, MONTH(Fadjudicacion) MM

				FROM OfertasSQL
				WHERE IsNumeric(CodProv )=0 
					AND CodOferta IS NOT NULL
					' + REPLACE(@CondicionCentros, 'R.CDCEN', 'CodCentro_Origen') + '
				GROUP BY CodCentro_Origen, CodOferta, NumRegularizacion, FAdjudicacion, DescripcionOferta, CodCliente, CodProv 
				'
	--PRINT (@Sql)
	INSERT INTO #OfertasSQL
	EXEC (@Sql)

	SELECT IdOferta, CAST(AA as int) Año, CAST(MM as int) Mes, Oferta, RIGHT(REPLICATE('0',8)+IdCliente, 8) IdCliente, Cliente, IdProvPais, ISNULL(P.Pais,'') ProvPais,
					SUM(ImporteAdjudicado) ImporteAdjudicado, SUM(ImporteOfertado) ImporteOfertado, Tipo,
					Causa, Baja
					, @pCentros CentrosElecnor, RIGHT('000' + IdCentroE, 3) IdCentroE  
					
	FROM (
			SELECT * FROM #Ofertas
			UNION
			SELECT * FROM #Regularizaciones
			UNION
			SELECT * FROM #OfertasSQL
	) q LEFT JOIN [IPK_Objetivos]..Paises P ON q.IdProvPais=P.IdPais
	--WHERE IdOferta in ('2009100001')
	GROUP BY IdOferta, AA, MM, Oferta, RIGHT(REPLICATE('0',8)+IdCliente, 8), Cliente, IdProvPais, 
					Tipo,
					Causa, Baja
					, IdCentroE , P.Pais
	ORDER BY IdOferta
END TRY
BEGIN CATCH
	SET @MenError =  (@Sql)
	
	INSERT INTO [SISCALADATA].IPK_CA_WEB.dbo.[Log4NetLog] ([Date], [Thread], [Level], [Logger], [Message])
	VALUES (@FechaError, 1, 'ERROR', @LoggerError, @MenError)

END CATCH
END