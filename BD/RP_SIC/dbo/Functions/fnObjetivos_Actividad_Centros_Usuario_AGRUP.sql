CREATE FUNCTION [dbo].[fnObjetivos_Actividad_Centros_Usuario_AGRUP] ( @pAño  int, @pCentros varchar(8000)  )
RETURNS
 @ObjetivosActividad TABLE (
	 Año int,
	 Agrupacion varchar(50),
	 Importe float
 )
AS
BEGIN

  INSERT INTO @ObjetivosActividad(Año,Agrupacion,Importe) 
  SELECT vw.Año, dbo.vwActividadesCDAC.Agrupacion, sum(ISNULL(vw.Importe, 0)) AS Importe
  FROM dbo.vwActividadesCDAC LEFT OUTER JOIN
                       (
					    SELECT Año, dbo.fnCDAC(CDAC1, CDAC2) AS CDAC, SUM(Importe) AS Importe
						FROM  dbo.ObjetivosActividadSQL
						WHERE CodCentro IN (Select Name FROM dbo.fnSplitString(@pCentros+',')) AND Año=@pAño
						GROUP BY Año, dbo.fnCDAC(CDAC1, CDAC2)
					   ) as vw  ON dbo.vwActividadesCDAC.CDAC = vw.CDAC
  WHERE ISNULL(vw.Importe, 0) <> 0
  GROUP BY vw.Año, dbo.vwActividadesCDAC.Agrupacion

 RETURN

END