create FUNCTION [dbo].[fnFechaCierre] ()
	RETURNS varchar (50)
AS  

BEGIN

	DECLARE @FechaCierre as varchar(50)

	SELECT @FechaCierre=FechaCierre FROM dbo.WEB_Parametros
	
	return @FechaCierre

END
