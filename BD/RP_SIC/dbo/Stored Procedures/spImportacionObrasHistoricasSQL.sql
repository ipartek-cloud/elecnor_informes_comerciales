CREATE PROCEDURE [dbo].[spImportacionObrasHistoricasSQL] 
	AS
BEGIN

	-- Deberemos modificar este Procedimeientro para que no borre y añada lo corespondiente a este año, si no que añada lo que no existe de este año

	DELETE [dbo].[ObrasHistoricasSQL] --> QUITAR

	INSERT INTO [dbo].[ObrasHistoricasSQL] --> INserte lo que no exietan en la tabla ObrasHistoricoSQL
           ([CDOFT]
           ,[CTR]
           ,[OBRA]
           ,[OBRAL]
           ,[DSOBR]
           ,[FAPERTURA]
           ,[FCIERRE]
           ,[SOP]
           ,[SOF]
           ,[SOL])
	SELECT [CDOFT]
           ,[CTR]
           ,[OBRA]
           ,[OBRAL]
           ,[DSOBR]
           ,[FAPERTURA]
           ,[FCIERRE]
           ,[SOP]
           ,[SOF]
           ,[SOL]
	FROM [dbo].[vwExportacionObrasHistoricasSQL]

	-- ********** XLS Para Angel con ObrasHistoricoSQL_2018 que se importaron no automaticamente *********

	--SELECT        TOP (100) PERCENT dbo.ObrasHistoricasSQL_2018.CTR, dbo.ObrasHistoricasSQL_2018.OBRA, dbo.ObrasHistoricasSQL_2018.OBRAL, 
	--                        dbo.ObrasHistoricasSQL_2018.CDOFT, dbo.ObrasHistoricasSQL_2018.DSOBR, LEFT(dbo.ObrasHistoricasSQL_2018.FAPERTURA, 2) AS FApertura_Mes, 
	--                        RIGHT(dbo.ObrasHistoricasSQL_2018.FAPERTURA, 2) AS FApertura_Año, LEFT(dbo.ObrasHistoricasSQL_2018.FCIERRE, 2) AS FCierre_Mes, 
	--                        RIGHT(dbo.ObrasHistoricasSQL_2018.FCIERRE, 2) AS FCierre_Año, dbo.ObrasHistoricasSQL_2018.SOP, dbo.ObrasHistoricasSQL_2018.SOF, 
	--                        dbo.ObrasHistoricasSQL_2018.SOL
	--FROM            dbo.ObrasHistoricasSQL_2018 LEFT OUTER JOIN
	--						 dbo.ObrasHistoricasSQL ON dbo.ObrasHistoricasSQL_2018.CDOFT = dbo.ObrasHistoricasSQL.CDOFT AND 
	--						 dbo.ObrasHistoricasSQL_2018.CTR = dbo.ObrasHistoricasSQL.CTR AND dbo.ObrasHistoricasSQL_2018.OBRA = dbo.ObrasHistoricasSQL.OBRA AND 
	--						 dbo.ObrasHistoricasSQL_2018.OBRAL = dbo.ObrasHistoricasSQL.OBRAL
	--WHERE        (dbo.ObrasHistoricasSQL.CDOFT IS NULL)
	--ORDER BY dbo.ObrasHistoricasSQL_2018.FCIERRE, dbo.ObrasHistoricasSQL_2018.CTR, dbo.ObrasHistoricasSQL_2018.OBRA, dbo.ObrasHistoricasSQL_2018.OBRAL

	-- ********* COnsulta de Insertcion de 2018 --> Actual que no estan ********
	INSERT INTO [dbo].[ObrasHistoricasSQL] --> INserte lo que no exietan en la tabla ObrasHistoricoSQL
           ([CDOFT]
           ,[CTR]
           ,[OBRA]
           ,[OBRAL]
           ,[DSOBR]
           ,[FAPERTURA]
           ,[FCIERRE]
           ,[SOP]
           ,[SOF]
           ,[SOL])
	SELECT       dbo.ObrasHistoricasSQL_2018.CDOFT, dbo.ObrasHistoricasSQL_2018.CTR, dbo.ObrasHistoricasSQL_2018.OBRA, 
                         dbo.ObrasHistoricasSQL_2018.OBRAL, dbo.ObrasHistoricasSQL_2018.DSOBR, dbo.ObrasHistoricasSQL_2018.FAPERTURA, 
                         dbo.ObrasHistoricasSQL_2018.FCIERRE, dbo.ObrasHistoricasSQL_2018.SOP, dbo.ObrasHistoricasSQL_2018.SOF, dbo.ObrasHistoricasSQL_2018.SOL
	FROM            dbo.ObrasHistoricasSQL_2018 LEFT OUTER JOIN
							 dbo.ObrasHistoricasSQL ON dbo.ObrasHistoricasSQL_2018.CDOFT = dbo.ObrasHistoricasSQL.CDOFT AND 
							 dbo.ObrasHistoricasSQL_2018.CTR = dbo.ObrasHistoricasSQL.CTR AND dbo.ObrasHistoricasSQL_2018.OBRA = dbo.ObrasHistoricasSQL.OBRA AND 
							 dbo.ObrasHistoricasSQL_2018.OBRAL = dbo.ObrasHistoricasSQL.OBRAL
	WHERE        (dbo.ObrasHistoricasSQL.CDOFT IS NULL)	

	SELECT * FROM [dbo].[ObrasHistoricasSQL]
		
END