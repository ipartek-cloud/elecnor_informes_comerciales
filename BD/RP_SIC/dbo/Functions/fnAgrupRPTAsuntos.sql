
CREATE FUNCTION [dbo].[fnAgrupRPTAsuntos] (@pEstado varchar(50))
RETURNS varchar(50)
AS  
BEGIN

	DECLARE @vAgrup varchar(50)	

	IF @pEstado='Asunto'
		BEGIN
			SET @vAgrup='Oportunidades y gestiones'
		END
	ELSE IF @pEstado='Pdte.Decisión' OR @pEstado='En Preparación' 
		BEGIN
			SET @vAgrup='Ofertas en preparación'
		END
	ELSE IF @pEstado='Preadjudicado' OR @pEstado='Adjudicado' OR @pEstado='Denegado' OR @pEstado='En Vigor' 
		BEGIN
			SET @vAgrup='Ofertas presentadas'
		END
	ELSE IF @pEstado='Archivado'
		BEGIN
			SET @vAgrup='Ofertas archivadas'
		END
	ELSE
		BEGIN
			SET @vAgrup=''
		END
		
	RETURN(@vAgrup)

END
