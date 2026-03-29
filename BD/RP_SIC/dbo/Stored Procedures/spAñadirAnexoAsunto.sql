create PROCEDURE [dbo].[spAñadirAnexoAsunto] 
	@pIdAsunto int,		
	@pNumAnexo int
	AS
BEGIN

	IF @pNumAnexo=1
		BEGIN
			UPDATE RPI_Asuntos SET Anexo1=1 WHERE idAsunto=@pIdAsunto
		END
	ELSE IF @pNumAnexo=2
		BEGIN
			UPDATE RPI_Asuntos SET Anexo2=1 WHERE idAsunto=@pIdAsunto
		END
	ELSE IF @pNumAnexo=3
		BEGIN
			UPDATE RPI_Asuntos SET Anexo3=1 WHERE idAsunto=@pIdAsunto
		END

	SELECT * FROM vwRPI_Asuntos_Singulares WHERE idAsunto=@pIdAsunto
	
		
END