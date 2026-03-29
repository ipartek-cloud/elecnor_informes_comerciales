CREATE FUNCTION [dbo].[fnChangeChar] (@str varchar(50))
RETURNS varchar(50)
AS  
BEGIN

	DECLARE @literal as varchar(50)

	Set @literal = REPLACE(@str, '¥', 'Ñ')
	Set @literal = REPLACE(@literal, '¦', 'ª')
	Set @literal = REPLACE(@literal, '§', 'º')
	Set @literal = REPLACE(@literal, 'µ', 'Á')
	Set @literal = REPLACE(@literal, 'à', 'Ó')
	Set @literal = REPLACE(@literal, 'Ö', 'Í')
	Set @literal = REPLACE(@literal, 'š', 'Ú')
	Set @literal = REPLACE(@literal, 'é', 'Ú')	
	Set @literal = REPLACE(@literal, 'š', 'Ü')	
	Set @literal = REPLACE(@literal, '€', 'Ç')	
	Set @literal = REPLACE(@literal, '@', '')
	Set @literal = REPLACE(@literal, ' ', '')
	Set @literal = REPLACE(@literal, '-', '')
	Set @literal = REPLACE(@literal, '.', '')
	Set @literal = REPLACE(@literal, ',', '')

	RETURN(@literal)

END

