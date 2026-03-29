
-- =============================================
-- Author:		Carlos García García
-- Create date: 2014-06-05
-- Description:	Obtiene ofertas de AS400 dado su codOferta
-- =============================================
CREATE PROCEDURE [dbo].[spWEB_GCI_ObtenerOfertasInternacionalPorCodOferta]
	@CodOferta as int 
AS
BEGIN
SELECT	
		RTRIM(LTRIM([Sumarigrama].NombreDirNegocio)) as Intervinientes,
		RTRIM(LTRIM([DSACT])) as Actividad,
		CASE 
			WHEN Ofertar = '' THEN 'Asunto'
			WHEN Ofertar = 'NO' THEN 'Abandonada'
			WHEN (AÑOPRES IS NULL AND MESPRES IS NULL) THEN 'Preparación'
			WHEN Adjudicada = 'N' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN 'Denegada'
			WHEN Adjudicada = 'S' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN 'Adjudicada'
			WHEN Adjudicada = ''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN 'Presentada'
		END as Nombrefase,
		CAST([CodOfer] AS VARCHAR(10)) AS CodOferta,
		RTRIM(LTRIM([DesOfer])) AS Proyecto,
		RTRIM(LTRIM([NomProvincia])) as NombrePais,
		RTRIM(LTRIM([ClienAgrupado])) as Cliente,
		RTRIM(LTRIM([DSROF])) AS Responsable,
		[CodResponsableComercial],
		CASE 
			WHEN Ofertar = '' THEN ImpAprox
			WHEN Ofertar = 'NO' THEN ImpAprox
			WHEN (AÑOPRES IS NULL AND MESPRES IS NULL) THEN ImpAprox
			WHEN Adjudicada = 'N' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ImpPres
			WHEN Adjudicada = 'S' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ImpAdj
			WHEN Adjudicada = ''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ImpPres
		END AS ImporteEstimadoEnEuros,
		CAST([AñoPres] AS varchar(4))+'-'+ RIGHT ('00'+ltrim(str(MesPres)),2 ) AS FechaPresentacion 
FROM	[RP_SIC].[dbo].[@@@Ofertas2005] as Ofertas 		
		LEFT JOIN  [RP_SIC].[dbo].[Sumarigrama] ON Ofertas.CT = [RP_SIC].[dbo].[Sumarigrama].CodCentro 
		LEFT JOIN [RP_SIC].[dbo].[Actividades] ON Ofertas.Act2 = [RP_SIC].[dbo].[Actividades].[CDAC2]
		LEFT JOIN [RP_SIC].[dbo].[Responsable] ON Ofertas.Responsable = [RP_SIC].[dbo].[Responsable].[RESOF]
		LEFT JOIN ResponsablesComercialesPorPais RCP on RCP.CodPais = Ofertas.CodProvincia
WHERE	Mercado = 'Internacional'
		AND ((ImpAprox >= 10000000 AND OfertaR = '') or 
			(ImpAprox >= 10000000 AND OfertaR = 'NO') OR
			(ImpAprox >= 10000000 AND AÑOPRES IS NULL AND MESPRES IS NULL) OR 
			(ImPPres  >= 10000000 AND (Adjudicada = 'N' OR Adjudicada = '') AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL)) OR
			(ImpAdj >= 10000000 AND Adjudicada = 'S' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL)))
		--AND Ofertar <> ''
		AND Ofertas.BAJA <> 'B'		
		AND	CodOfer = @CodOferta
ORDER BY DesOfer
END

