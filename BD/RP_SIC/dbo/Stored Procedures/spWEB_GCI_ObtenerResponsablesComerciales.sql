

-- =============================================
-- Author:		Carlos García García
-- Create date: 2014-06-20
-- Description:	Obtiene los responsables comerciales de  de AS400 que hay que mostrar en la web de Gestión Comercial Internacional
-- =============================================
create PROCEDURE [dbo].[spWEB_GCI_ObtenerResponsablesComerciales]
AS
BEGIN
	SELECT distinct CodResponsableComercial as IdResponsableComercial, NombreResponsableComercial 
	FROM ResponsablesComercialesPorPais
	ORDER BY NombreResponsableComercial 
END







