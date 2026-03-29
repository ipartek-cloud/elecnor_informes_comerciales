create FUNCTION [dbo].[fnNombreProvincia] (@CodProvincia varchar(2))
RETURNS varchar(50)
AS  
BEGIN

	DECLARE @Provincia as varchar(50)

	SELECT @Provincia=[NMPRO] FROM [RP_SIC].[dbo].[Provincias]  WHERE cdpro=@CodProvincia
	
	RETURN(@Provincia)

END
