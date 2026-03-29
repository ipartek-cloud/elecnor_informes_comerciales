

CREATE FUNCTION [dbo].[fnEstadoAsunto](
@pFechaPresentado	varchar(10),
@pFechaPreAdjudicado varchar(10),
@pFechaAdjudicado	varchar(10),
@pFechaEnVigor	varchar(10),
@pFechaDenegado	varchar(10)
)
RETURNS varchar(50)
AS  
BEGIN

	DECLARE @Estado varchar(50)
	DECLARE @FechaCambioAño as date
	DECLARE @FechaActual as date

	SELECT @FechaCambioAño=FechaCambioAño, @FechaActual=GETDATE() FROM WEB_Parametros
	
	IF ISNULL( @pFechaDenegado, '')	<>''
		BEGIN				
			IF @FechaCambioAño>@FechaActual
				SET @Estado =  'Denegado'
			ELSE			
				SET @Estado =  'Archivado'	
		END	
	ELSE IF ISNULL(@pFechaEnVigor, '') <>''
		BEGIN
			IF @FechaCambioAño>@FechaActual
				SET @Estado =  'En Vigor'
			ELSE
				SET @Estado =  'Archivado'				
		END
	ELSE IF ISNULL(@pFechaAdjudicado,'') <>''
		BEGIN
			SET @Estado =  'Adjudicado'
		END
	ELSE IF ISNULL(@pFechaPreAdjudicado,'') <>''
		BEGIN
			SET @Estado =  'Preadjudicado'
		END
	ELSE IF ISNULL(@pFechaPresentado,'') <>''
		BEGIN
		    IF cast(@pFechaPresentado as Date)<cast(@FechaActual as Date)
				BEGIN
					SET @Estado = 'Pdte.Decisión'
				END
			ELSE
				BEGIN
					SET @Estado = 'En Preparación'
				END
		END
	ELSE
		BEGIN
			SET @Estado = 'Asunto'
		END

	Return @Estado

END
