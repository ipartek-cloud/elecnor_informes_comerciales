create FUNCTION [dbo].[fnNumReferencia_Montos] (@pidReferencia  int)
	RETURNS int
AS  

BEGIN

	DECLARE @Num int
	
	SELECT @Num= COUNT(idCertificadosClasificacionEmpresarial_AñoMonto) 
	FROM dbo.Referencias INNER JOIN
         dbo.ReferenciasCertificadosClasificacionEmpresarial ON 
         dbo.Referencias.idReferencia = dbo.ReferenciasCertificadosClasificacionEmpresarial.idReferencia INNER JOIN
         dbo.ReferenciasCertificadosClasificacionEmpresarial_AñoMonto ON 
         dbo.ReferenciasCertificadosClasificacionEmpresarial.idCertificadosClasificacionEmpresarial = dbo.ReferenciasCertificadosClasificacionEmpresarial_AñoMonto.idCertificadosClasificacionEmpresarial
	WHERE dbo.Referencias.idReferencia = @pidReferencia

	return isnull(@Num,0)
END