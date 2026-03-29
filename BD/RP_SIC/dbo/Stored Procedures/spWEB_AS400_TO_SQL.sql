
-- exec spWEB_AS400_TO_SQL 'eluque'

CREATE PROCEDURE [dbo].[spWEB_AS400_TO_SQL]
@Usuario varchar(50)
AS
BEGIN	
	
	SET NOCOUNT ON;

	BEGIN TRY	

	
	DECLARE @Sql as varchar(1000)
	DECLARE @AñoActual int=YEAR(GetDate())
	DECLARE @StartTime AS DATETIME = GETDATE()   

	DECLARE @Usuario_Sin_Fecha varchar(50)
	DECLARE @Posicion as int		

	--SELECT @AñoActual = MAX(Año) FROM WEB_FiltroAños
	SELECT @AñoActual = RIGHT(dbo.fnFechaCierre(),4)	-- 01/02/2021 para que cargue con la información correspondiente al año del ultimo cierre

	SET @Posicion=CHARINDEX('_',@Usuario)-1
	IF  @Posicion>0
		SET @Usuario_Sin_Fecha=left(@Usuario,@Posicion)
	ELSE	 
		SET @Usuario_Sin_Fecha=@Usuario

   -- *********************************************
   -- *****************  ENLACES ******************
   -- *********************************************

	DELETE FROM CO005BP WHERE Usuario LIKE @Usuario_Sin_Fecha + '%'

	PRINT 'Time CO005BP (DEL) --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	INSERT INTO [dbo].[CO005BP]([Usuario],[CTRO],[OBRA],[OBRAL],[CDOFT],[FechaApertura],[FechaCierre])
	SELECT @Usuario,CTRO, LEFT(OBRA, 3) AS OBRA, RIGHT(OBRA, 2) AS OBRAL, CDOFT, AAMMA, AAMMC 
	FROM OPENQUERY(SIC, 'SELECT * FROM S44DD901.FICOSCO.CO005BP AS Enlaces')

	PRINT 'Time CO005BP (INS) --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

   -- *********************************************
   -- ************ ENLACES HISTORICO  *************
   -- *********************************************

    DELETE FROM CO005BPH WHERE Usuario LIKE @Usuario_Sin_Fecha + '%'

	PRINT 'Time CO005BPH (DEL) --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	INSERT INTO [dbo].[CO005BPH]([Usuario],[CTRO],[OBRA],[OBRAL],[CDOFT],[FechaApertura],[FechaCierre],AñoCierre)
	SELECT @Usuario,CTRO, LEFT(OBRA, 3) AS OBRA, RIGHT(OBRA, 2) AS OBRAL, CDOFT, AAMMA, AAMMC , left(AAMMC,2)
	FROM OPENQUERY(SIC, 'SELECT * FROM S44DD901.FICOSCO.CO005BPH AS EnlacesHistorico WHERE left(AAMMC,2)>=15')

	PRINT 'Time CO005BPH (INS) --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

   -- *********************************************
   -- ***************** OFERREGU ******************
   -- *********************************************

    DELETE FROM OFERREGU WHERE Usuario LIKE @Usuario_Sin_Fecha + '%'

	PRINT 'Time OFERREGU (DEL) --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

------------------------------------------------------------
	--INSERT INTO OFERREGU ([Usuario],[CT],[MERCADO],[CODOFER],[DESOFER],[REG],[CAUSA],[LOCALIDAD],[CODPROVINCIA],[NOMPROVINCIA],[CODCLIENTE],[NOMCLIENTE],[ACT1],[ACT2],[RESPONSABLE],[AÑOGRAB],[MESGRAB],[IMPAPROX],[AÑOPRES],[MESPRES],[IMPPRES],[ADJUDICADA],[AÑOAD],[MESAD],[IMPAD],[TIPO],[OFERTAR],[TOTCOSTOS],[IMPTOTAL],[CLIENTPROV],[BAJA],[AI],[ORIGEN])
	--SELECT @Usuario,[CT],[MERCADO],[CODOFER],[DESOFER],[REG],[CAUSA],[LOCALIDAD],[CODPROVINCIA],[NOMPROVINCIA],[CODCLIENTE],[NOMCLIENTE],[ACT1],[ACT2],[RESPONSABLE],[AÑOGRAB],[MESGRAB],[IMPAPROX],[AÑOPRES],[MESPRES],[IMPPRES],[ADJUDICADA],[AÑOAD],[MESAD],[IMPAD],[TIPO],[OFERTAR],[TOTCOSTOS],[IMPTOTAL],[CLIENTPROV],[BAJA],[AI],[ORIGEN]
	--FROM  OPENQUERY(SIC, 'SELECT * FROM S44DD901.ICOMERF.OFERREGU WHERE AÑOAD=2019 AND ADJUDICADA=''S''')
	SET @Sql = '
					INSERT INTO OFERREGU ([Usuario],[CT],[MERCADO],[CODOFER],[DESOFER],[REG],[CAUSA],[LOCALIDAD],[CODPROVINCIA],[NOMPROVINCIA],[CODCLIENTE],[NOMCLIENTE],[ACT1],[ACT2],[RESPONSABLE],[AÑOGRAB],[MESGRAB],[IMPAPROX],[AÑOPRES],[MESPRES],[IMPPRES],[ADJUDICADA],[AÑOAD],[MESAD],[IMPAD],[TIPO],[OFERTAR],[TOTCOSTOS],[IMPTOTAL],[CLIENTPROV],[BAJA],[AI],[ORIGEN])
					SELECT ''' + @Usuario + ''',[CT],[MERCADO],[CODOFER],[DESOFER],[REG],[CAUSA],[LOCALIDAD],[CODPROVINCIA],[NOMPROVINCIA],[CODCLIENTE],[NOMCLIENTE],[ACT1],[ACT2],[RESPONSABLE],[AÑOGRAB],[MESGRAB],[IMPAPROX],[AÑOPRES],[MESPRES],[IMPPRES],[ADJUDICADA],[AÑOAD],[MESAD],[IMPAD],[TIPO],[OFERTAR],[TOTCOSTOS],[IMPTOTAL],[CLIENTPROV],[BAJA],[AI],[ORIGEN]
					FROM  OPENQUERY(SIC, ''SELECT * FROM S44DD901.ICOMERF.OFERREGU WHERE AÑOAD=' + CAST(@AñoActual as varchar(4)) + ' AND ADJUDICADA=''''S'''''')
	'
	print (@Sql)
	EXEC (@Sql)

------------------------------------------------------------

	PRINT 'Time OFERREGU (INS) --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

   -- *********************************************
   -- ************ REGULARIZACIONS ****************
   -- *********************************************	
	
	DELETE FROM IC10AP WHERE Usuario LIKE @Usuario_Sin_Fecha + '%'

	PRINT 'Time IC10AP (DEL) --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

------------------------------------------------------------
	--INSERT INTO [dbo].[IC10AP]([Usuario],[CDCEN],[CDOFT],[IMPRE],[AR],[MR])
	--SELECT @Usuario,CDCEN, CDOFT, IMPRE, AR, MR
	--FROM   OPENQUERY(SIC, ' SELECT CDCEN, CDOFT, IMPRE, substr( digits(dec(19000000+FECHAR,8,0)), 1, 4 ) AR,substr( digits(dec(19000000+FECHAR,8,0)), 5, 2) MR
	--						FROM S44DD901.ICOMERF.IC10AP
	--						WHERE substr( digits(dec(19000000+FECHAR,8,0)), 1, 4 )>=2019')	
	SET @Sql = '
					INSERT INTO [dbo].[IC10AP]([Usuario],[CDCEN],[CDOFT],[IMPRE],[AR],[MR])
					SELECT ''' + @Usuario + ''',CDCEN, CDOFT, IMPRE, AR, MR
					FROM   OPENQUERY(SIC, '' SELECT CDCEN, CDOFT, IMPRE, substr( digits(dec(19000000+FECHAR,8,0)), 1, 4 ) AR,substr( digits(dec(19000000+FECHAR,8,0)), 5, 2) MR
											FROM S44DD901.ICOMERF.IC10AP
											WHERE substr( digits(dec(19000000+FECHAR,8,0)), 1, 4 )>=' + CAST(@AñoActual as varchar(4)) + ''')	

	'
	print (@Sql)
	EXEC (@Sql)
------------------------------------------------------------

	PRINT 'Time IC10AP (INS) --> ' + cast(DATEDIFF(ms,@StartTime,GETDATE())/1000 as varchar(100)) + ' seg.'

	return 0 -- NO ERROR
   
	END TRY
	BEGIN CATCH
		--SELECT ERROR_NUMBER (), ERROR_Message()
		return 1
	END CATCH
    
END
