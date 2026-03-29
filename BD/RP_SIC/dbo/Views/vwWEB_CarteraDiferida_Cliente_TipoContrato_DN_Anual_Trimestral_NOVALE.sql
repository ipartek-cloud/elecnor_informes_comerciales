CREATE VIEW [dbo].[vwWEB_CarteraDiferida_Cliente_TipoContrato_DN_Anual_Trimestral_NOVALE]
AS
SELECT        Usuario, Año, Mes, Cliente, AGRUP, CodDDirNegocio, NombreDirNegocio,
                         SUM(CASE TIPO WHEN 'T' THEN NTrimestre * MontoTrimestre ELSE MontoAnual END) AS Total, SUM(Contrat) AS Contrat, SUM(CarteraPendiente) 
                         AS CarteraPendiente, SUM(Produccion_A) AS Produccion_A, SUM(MargenProduccion_A) AS MargenProduccion_A, SUM(A_Año) AS A_Año, SUM(A_Año1) AS A_Año1, 
                         SUM(Facturacion_Origen_A) AS Facturacion_Origen_A, SUM(Facturacion_Anticipada_A) AS Facturacion_Anticipada_A, SUM(Produccion_Curso_A) 
                         AS Produccion_Curso_A, SUM(Facturacion_A) AS Facturacion_A
FROM            dbo.WEB_CarteraDiferidaPdteEjecutarUsuarioCentro
GROUP BY Usuario, Año, Mes, Cliente, AGRUP, CodDDirNegocio, NombreDirNegocio