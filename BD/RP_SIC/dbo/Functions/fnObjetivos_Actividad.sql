CREATE FUNCTION [dbo].[fnObjetivos_Actividad] (@pAño int,@pCDAC1 varchar(2),@pCDAC2 varchar(2))
RETURNS float
AS  
BEGIN

DECLARE @Objetivos as float
Declare @vCDAC as varchar(4)

SET @Objetivos=0
SET @vCDAC=[dbo].[fnCDAC](@pCDAC1,@pCDAC2)

SELECT @Objetivos=sum(importe)
FROM ObjetivosActividadSQL
WHERE Año=@pAño and [dbo].[fnCDAC](CDAC1,CDAC2)=@vCDAC
GROUP BY Año,cdac1
	
RETURN(isnull(@Objetivos,0))

END