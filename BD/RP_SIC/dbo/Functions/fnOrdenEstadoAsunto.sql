CREATE FUNCTION [dbo].[fnOrdenEstadoAsunto] (@pAsunto varchar(50))
RETURNS int
AS  
BEGIN

DECLARE @vOrden as int

SET @vOrden=0

IF(@pAsunto='Asunto')
	BEGIN
		 SET @vOrden=1
	END
ELSE IF(@pAsunto='En Preparación')
	BEGIN
		 SET @vOrden=2
	END
ELSE IF(@pAsunto='Pdte.Decisión')
	BEGIN
		 SET @vOrden=3
	END
ELSE IF(@pAsunto='Preadjudicado')
	BEGIN
		 SET @vOrden=4
	END
ELSE IF(@pAsunto='Adjudicado')
	BEGIN
		 SET @vOrden=5
	END
ELSE IF(@pAsunto='En Vigor')
	BEGIN
		 SET @vOrden=6
	END
ELSE IF(@pAsunto='Denegado')
	BEGIN
		 SET @vOrden=7
	END
ELSE IF(@pAsunto='Archivado')
	BEGIN
		 SET @vOrden=8
	END
	
RETURN(@vOrden)

END
