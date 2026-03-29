
CREATE FUNCTION [dbo].[fnAgrupPaises] 
(
	@Area varchar(100)
)
RETURNS varchar(50)
AS  
BEGIN

	DECLARE @Agrup as varchar(50)

	IF (@Area = 'Pais Estable')
		BEGIN
			SET @Agrup ='Presencia Estable'
		END
	ELSE
		BEGIN
			SET @Agrup ='Áreas Geográficas'
		END

	RETURN @Agrup

END