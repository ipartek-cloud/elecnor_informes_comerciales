


CREATE PROCEDURE [dbo].[spWEB_Copy_Tendencias_CT]
	@pAño int,
	@pMes int,
	@pCodDelegacion varcHAR(3)	
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY

	    DELETE Tendencias WHERE Año=@pAño AND Mes=@pMes+1 AND CodCentro IN (SELECT CodCentro FROM Sumarigrama WHERE CodDelegacion=@pCodDelegacion AND Año=@pAño)

		INSERT INTO Tendencias(CodCentro,Año,Mes,TendenciaCierre,ContratacionPdteImputar,AsuntosPdtes)
		SELECT CodCentro,Año,Mes+1,TendenciaCierre,ContratacionPdteImputar,AsuntosPdtes FROM Tendencias
		WHERE Año=@pAño AND Mes=@pMes AND CodCentro IN (SELECT CodCentro FROM Sumarigrama WHERE CodDelegacion=@pCodDelegacion AND Año=@pAño)

		return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH
		return ERROR_NUMBER ()
	END CATCH
	
END

