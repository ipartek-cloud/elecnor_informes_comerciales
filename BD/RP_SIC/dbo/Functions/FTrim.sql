create FUNCTION [dbo].[FTrim] (@Cadena varchar(1000))
RETURNS varchar(1000)
AS  
BEGIN

DECLARE @vCadena as varchar(1000)

Set @vCadena = ltrim(rtrim(@Cadena))

RETURN(@vCadena)

END