
CREATE VIEW [dbo].[vwWEB_CarteraDiferida_DN_Agrup_RPT_OLD]
AS
SELECT        dbo.vwWEB_CarteraDiferida_DN_Agrup.Usuario, dbo.vwWEB_CarteraDiferida_DN_Agrup.Año, dbo.vwWEB_CarteraDiferida_DN_Agrup.Mes, 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.CodDDirNegocio, RTRIM(dbo.vwWEB_CarteraDiferida_DN_Agrup.NombreDirNegocio) 
                         + ' (' + LTRIM(STR(dbo.vwWEB_CarteraDiferida_DN_Agrup.CodDDirNegocio)) + ')' AS NombreDirNegocio, dbo.vwWEB_CarteraDiferida_DN_DN_RPT.Total_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_DN_RPT.Contrat_DN, dbo.vwWEB_CarteraDiferida_DN_DN_RPT.CarteraPendiente_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_DN_RPT.Produccion_A_DN, dbo.vwWEB_CarteraDiferida_DN_DN_RPT.MargenProduccion_A_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_DN_RPT.PorcentajeProduccion_DN, dbo.vwWEB_CarteraDiferida_DN_DN_RPT.A_Año_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_DN_RPT.A_Año1_DN, dbo.vwWEB_CarteraDiferida_DN_DN_RPT.Facturacion_Origen_A_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_DN_RPT.Facturacion_Anticipada_A_DN, dbo.vwWEB_CarteraDiferida_DN_DN_RPT.Produccion_Curso_A_DN, 
                         dbo.vwWEB_CarteraDiferida_DN_DN_RPT.Facturacion_A_DN, dbo.vwWEB_CarteraDiferida_DN_Agrup.Cliente, 
                         dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.Total_CLI, dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.Contrat_CLI, 
                         dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.CarteraPendiente_CLI, dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.Produccion_A_CLI, 
                         dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.MargenProduccion_A_CLI, dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.PorcentajeProduccion_CLI, 
                         dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.A_Año_CLI, dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.A_Año1_CLI, 
                         dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.Facturacion_Origen_A_CLI, dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.Facturacion_Anticipada_A_CLI, 
                         dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.Produccion_Curso_A_CLI, dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.Facturacion_A_CLI, 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.Contrato, ISNULL(dbo.vwWEB_CarteraDiferida_DN_Agrup.FInicio, '') AS FInicio, 
                         ISNULL(dbo.vwWEB_CarteraDiferida_DN_Agrup.FFinal, '') AS FFinal, ISNULL(dbo.vwWEB_CarteraDiferida_DN_Agrup.Prorroga, '') AS Prorroga, 
                         dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.Total_CON, dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.Contrat_CON, 
                         dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.CarteraPendiente_CON, dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.Produccion_A_CON, 
                         dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.MargenProduccion_A_CON, dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.PorcentajeProduccion_CON, 
                         dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.A_Año_CON, dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.A_Año1_CON, 
                         dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.Facturacion_Origen_A_CON, dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.Facturacion_Anticipada_A_CON, 
                         dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.Produccion_Curso_A_CON, dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.Facturacion_A_CON, 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.Total, dbo.vwWEB_CarteraDiferida_DN_Agrup.Contrat, dbo.vwWEB_CarteraDiferida_DN_Agrup.CarteraPendiente, 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.Produccion_A, dbo.vwWEB_CarteraDiferida_DN_Agrup.MargenProduccion_A, 
                         CASE Produccion_A WHEN 0 THEN 0 ELSE 100 * MargenProduccion_A / Produccion_A END AS PorcentajeProduccion, dbo.vwWEB_CarteraDiferida_DN_Agrup.A_Año, 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.A_Año1, dbo.vwWEB_CarteraDiferida_DN_Agrup.Facturacion_Origen_A, 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.Facturacion_Anticipada_A, dbo.vwWEB_CarteraDiferida_DN_Agrup.Produccion_Curso_A, 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.Facturacion_A
FROM            dbo.vwWEB_CarteraDiferida_DN_Agrup INNER JOIN
                         dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT ON dbo.vwWEB_CarteraDiferida_DN_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.CodDDirNegocio = dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.CodDDirNegocio AND 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.Cliente = dbo.vwWEB_CarteraDiferida_DN_CLIENTE_RPT.Cliente INNER JOIN
                         dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT ON 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.CodDDirNegocio = dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.CodDDirNegocio AND 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.Cliente = dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.Cliente AND 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.Contrato = dbo.vwWEB_CarteraDiferida_DN_CONTRATO_RPT.Contrato INNER JOIN
                         dbo.vwWEB_CarteraDiferida_DN_DN_RPT ON dbo.vwWEB_CarteraDiferida_DN_Agrup.Usuario = dbo.vwWEB_CarteraDiferida_DN_DN_RPT.Usuario AND 
                         dbo.vwWEB_CarteraDiferida_DN_Agrup.CodDDirNegocio = dbo.vwWEB_CarteraDiferida_DN_DN_RPT.CodDDirNegocio

