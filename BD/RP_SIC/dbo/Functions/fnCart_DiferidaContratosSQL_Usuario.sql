
CREATE FUNCTION [dbo].[fnCart_DiferidaContratosSQL_Usuario] ( @pTipo  varchar(1), @pUsuario  varchar(50))
RETURNS
 @Cart_DiferidaContratosSQL TABLE (
	ID int,
	Contrato varchar(255),
	Cliente varchar(255)  NULL,
	CodigoContratoClient varchar(255) ,
	Gerencia varchar(100) ,
	Prorrogable varchar(50) ,
	Tipo varchar(1) ,
	Mercado varchar(1),
	FInicio datetime,
	FFinal datetime,
	FFinalEfectiva datetime,
	Zona varchar(250)
 )
AS
BEGIN

  DECLARE @NumGerencias int

  SELECT @NumGerencias=isnull(COUNT(Usuario),0) FROM [dbo].[WEB_UsuariosGerencias] WHERE Usuario=@pUsuario

  IF @NumGerencias=0 -- Si no Tiene Gerencias puede ver Todas
	BEGIN
		INSERT INTO @Cart_DiferidaContratosSQL([ID],[Contrato],[Cliente],[CodigoContratoClient],[Gerencia],[Prorrogable],[Tipo],[Mercado],[FInicio],[FFinal],[FFinalEfectiva],[Zona]) 
		SELECT [ID],[Contrato],[Cliente],isnull([CodigoContratoClient],''),[Gerencia],isnull([Prorrogable],''),[Tipo],[Mercado],[FInicio],[FFinal],[FFinalEfectiva],isnull([Zona],'')
		FROM [dbo].[Cart_DiferidaContratosSQL]
		WHERE Vigente=1 AND Tipo= @pTipo
	END
  ELSE	-- solamante las Indicadas
	BEGIN
		INSERT INTO @Cart_DiferidaContratosSQL([ID],[Contrato],[Cliente],[CodigoContratoClient],[Gerencia],[Prorrogable],[Tipo],[Mercado],[FInicio],[FFinal],[FFinalEfectiva],[Zona]) 
		SELECT [ID],[Contrato],[Cliente],isnull([CodigoContratoClient],''),[Gerencia],isnull([Prorrogable],''),[Tipo],[Mercado],[FInicio],[FFinal],[FFinalEfectiva],isnull([Zona],'')
		FROM [dbo].[Cart_DiferidaContratosSQL]
		WHERE Vigente=1 AND Tipo= @pTipo AND Gerencia IN(SELECT Gerencia FROM [dbo].[WEB_UsuariosGerencias] WHERE Usuario=@pUsuario )
	END

 RETURN

END