create FUNCTION [dbo].[fnFormat]
(
	@Valor bigint,
	@NumeroCaracteres integer
)
RETURNS varchar(50)
AS
BEGIN
		
	RETURN  LEFT(REPLACE(STR(@Valor,@NumeroCaracteres),' ','0'),@NumeroCaracteres)
	
END
