CREATE FUNCTION [dbo].[fgConvertirFechaDMY_CarteraPdte] (@pFecha varchar(7))
	RETURNS datetime
AS  

BEGIN

	DECLARE @FechaContratacion datetime
	DECLARE @vFecha as varchar(6)
    
    IF len(@pFecha)>5  and right(@pFecha,6)<>'000000' --isnull(@pFecha,'')<>'' and @pFecha<>'0'
		BEGIN			
			SET @vFecha=right(@pFecha,6)
			SET @FechaContratacion = right(@vFecha, 2) + '/' + SUBSTRING(@vFecha,3,2) + '/' + left(@vFecha,2)				
		END
	ELSE IF @pFecha='0'
		BEGIN
			SET @FechaContratacion ='1/1/1999'
		END

	return @FechaContratacion

END
