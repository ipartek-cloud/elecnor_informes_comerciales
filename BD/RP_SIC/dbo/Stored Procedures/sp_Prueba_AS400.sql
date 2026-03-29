-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_Prueba_AS400] 

AS
BEGIN


DECLARE	@return_value int

EXEC	@return_value = [dbo].[spWEB_ContratacionUsuario]
		@Usuario = N'svadillo_9999',
		@pAño = 2015,
		@pMes = 9

SELECT	'Return Value' = @return_value

EXEC	@return_value = [dbo].[spWEB_OfertacionUsuario]
		@Usuario = N'svadillo_9999',
		@pAño = 2015,
		@pMes = 9

SELECT	'Return Value' = @return_value

EXEC	@return_value = [dbo].[spWEB_CarteraUsuario]
		@Usuario = N'svadillo_9999',
		@pAño = 2015,
		@pMes = 9

SELECT	'Return Value' = @return_value





END
