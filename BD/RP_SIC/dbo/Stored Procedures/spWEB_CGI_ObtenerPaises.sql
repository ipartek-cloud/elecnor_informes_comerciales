-- =============================================
-- Author:		Carlos García
-- Create date: 2014/06/16
-- Description:	Obtiene todos los paises del mercado internacional
-- =============================================
CREATE PROCEDURE spWEB_CGI_ObtenerPaises
AS
BEGIN
	SELECT [CDPRO] AS IdPais
		  ,[NMPRO] AS NombrePais
	  FROM [RP_SIC].[dbo].[Provincias]
	  WHERE pais = 'internacional'
	  ORDER BY NMPRO
 END
