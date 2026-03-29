create PROCEDURE [dbo].[spBorrarAnexoAsunto] 
	@pIdAsunto int,		
	@pNumAnexo int
	AS
BEGIN

	IF @pNumAnexo=1
		BEGIN
			UPDATE RPI_Asuntos SET Anexo1=0 WHERE idAsunto=@pIdAsunto
		END
	ELSE IF @pNumAnexo=2
		BEGIN
			UPDATE RPI_Asuntos SET Anexo2=0 WHERE idAsunto=@pIdAsunto
		END
	ELSE IF @pNumAnexo=3
		BEGIN
			UPDATE RPI_Asuntos SET Anexo3=0 WHERE idAsunto=@pIdAsunto
		END

	SELECT * FROM vwRPI_Asuntos_Singulares WHERE idAsunto=@pIdAsunto
	
		
END