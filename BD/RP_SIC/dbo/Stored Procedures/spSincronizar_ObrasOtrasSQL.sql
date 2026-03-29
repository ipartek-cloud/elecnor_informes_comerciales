
-- [dbo].[spSincronizar_ObrasOtrasSQL]


CREATE PROCEDURE [dbo].[spSincronizar_ObrasOtrasSQL]
AS
BEGIN	
	
	BEGIN TRY	

		-- Incrementamos los Montos de las Ofertas que Existan
		UPDATE [dbo].[ObrasOtrasSQL]
		SET dbo.ObrasOtrasSQL.SOP=  (dbo.ObrasOtrasSQL.SOP * Acumular) + isnull(dbo.ObrasOtrasSQL_Importacion.SOP,0),
			dbo.ObrasOtrasSQL.SOF=  (dbo.ObrasOtrasSQL.SOF * Acumular) + isnull(dbo.ObrasOtrasSQL_Importacion.SOF,0),
			dbo.ObrasOtrasSQL.SOL=	(dbo.ObrasOtrasSQL.SOL * Acumular) + isnull(dbo.ObrasOtrasSQL_Importacion.SOL,0)
		FROM   dbo.ObrasOtrasSQL INNER JOIN
               dbo.ObrasOtrasSQL_Importacion ON dbo.ObrasOtrasSQL.CDOFT = dbo.ObrasOtrasSQL_Importacion.CDOFT AND 
               dbo.ObrasOtrasSQL.CTR = dbo.ObrasOtrasSQL_Importacion.CTR

		-- Insertamos las Ofertas que NO Existan
		INSERT INTO ObrasOtrasSQL ([CDOFT],[CTR],[OBRA],[OBRAL],[DSOBR],[FAPERTURA],[FCIERRE],[SOP],[SOF],[SOL],[TipoOferta])
		SELECT dbo.ObrasOtrasSQL_Importacion.CDOFT, dbo.ObrasOtrasSQL_Importacion.CTR, dbo.ObrasOtrasSQL_Importacion.OBRA,dbo.ObrasOtrasSQL_Importacion.OBRAL, dbo.ObrasOtrasSQL_Importacion.DSOBR, dbo.ObrasOtrasSQL_Importacion.FAPERTURA, dbo.ObrasOtrasSQL_Importacion.FCIERRE, dbo.ObrasOtrasSQL_Importacion.SOP, dbo.ObrasOtrasSQL_Importacion.SOF, dbo.ObrasOtrasSQL_Importacion.SOL, dbo.ObrasOtrasSQL_Importacion.TipoOferta
		FROM   dbo.ObrasOtrasSQL RIGHT OUTER JOIN
               dbo.ObrasOtrasSQL_Importacion ON dbo.ObrasOtrasSQL.CDOFT = dbo.ObrasOtrasSQL_Importacion.CDOFT AND 
               dbo.ObrasOtrasSQL.CTR = dbo.ObrasOtrasSQL_Importacion.CTR
		WHERE  ISNULL(dbo.ObrasOtrasSQL.id, 0) = 0		
	
		select 0 -- NO ERROR
   
	END TRY
	BEGIN CATCH
		select ERROR_NUMBER (), ERROR_Message()
	END CATCH
    
END
