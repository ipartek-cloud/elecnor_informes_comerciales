

CREATE PROCEDURE [dbo].[spWEB_Copy_Tendencia_CT]
	@pAño int,
	@pMes int,
	@pCodCentro varchar(3)	
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY

	    DELETE Tendencias WHERE Año=@pAño AND Mes=@pMes+1 AND CodCentro=@pCodCentro

		INSERT INTO Tendencias(CodCentro,Año,Mes,TendenciaCierre,ContratacionPdteImputar,AsuntosPdtes)
		SELECT CodCentro,Año,Mes+1,TendenciaCierre,ContratacionPdteImputar,AsuntosPdtes FROM Tendencias
		WHERE  CodCentro=@pCodCentro AND Año=@pAño AND Mes=@pMes

		return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH
		return ERROR_NUMBER ()
	END CATCH
	
END

