
CREATE FUNCTION [dbo].[fnMontoAsunto](
	@pEstado varchar(50),
	@pMontoAsunto float,
	@pMontoPresentado float,
	@pMontoPreadjudicado float,
	@pMontoAdjudicado float,
	@pMontoEnVigor float,
	@pMontoDenegado float
)
RETURNS float
AS  
BEGIN

	DECLARE @Monto float

	IF @pEstado = 'Asunto'
		BEGIN
			Set @Monto= @pMontoAsunto
		END
	ELSE IF @pEstado = 'En Preparación' OR @pEstado = 'Pdte.Decisión'
		BEGIN
			Set @Monto= @pMontoPresentado
		END
	ELSE IF @pEstado = 'Preadjudicado'
		BEGIN
			Set @Monto= @pMontoPreadjudicado
		END
	ELSE IF @pEstado = 'Adjudicado'
		BEGIN
			Set @Monto= @pMontoAdjudicado
		END
	ELSE IF @pEstado = 'En Vigor'
		BEGIN
			Set @Monto= @pMontoEnVigor
		END
	ELSE IF @pEstado = 'Denegado'
		BEGIN
			Set @Monto= @pMontoDenegado
		END
	ELSE IF @pEstado = 'Archivado'
		BEGIN
			IF @pMontoDenegado>0
				Set @Monto= @pMontoDenegado
			ELSE IF @pMontoEnVigor>0
				Set @Monto= @pMontoEnVigor
		END
		
	Return isnull(@Monto,0)

END

