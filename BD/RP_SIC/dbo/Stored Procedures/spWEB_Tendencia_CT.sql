

CREATE PROCEDURE [dbo].[spWEB_Tendencia_CT]
	@pAño int,
	@pMes int,
	@pCodCentro varchar(3),
	@pTendenciaCierre float,
	@pContratacionPdteImputar float,
	@pAsuntosPdtes float
	AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY

	    DECLARE @Num integer

		SELECT @Num= Count(*) FROM Tendencias WHERE CodCentro=@pCodCentro AND Año=@pAño AND Mes=@pMes

		IF isnull(@Num,0)=0 
			INSERT INTO Tendencias(CodCentro,Año,Mes,TendenciaCierre,ContratacionPdteImputar,AsuntosPdtes)
			VALUES (@pCodCentro, @pAño, @pMes, @pTendenciaCierre, @pContratacionPdteImputar, @pAsuntosPdtes)
		ELSE
			UPDATE Tendencias
			SET TendenciaCierre=isnull(@pTendenciaCierre,0), ContratacionPdteImputar=isnull(@pContratacionPdteImputar,0), AsuntosPdtes=isnull(@pAsuntosPdtes,0)
			WHERE CodCentro=@pCodCentro AND Año=@pAño AND Mes=@pMes

		return 0 -- NO ERROR
	
	END TRY
	BEGIN CATCH
		return ERROR_NUMBER ()
	END CATCH
	
END

