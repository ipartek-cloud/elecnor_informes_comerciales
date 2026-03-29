

-- =============================================
-- Author:		Carlos García García
-- Create date: 2014-06-05
-- Modify date: 2014-06-16 Permite filtrar por diferentes campos
-- Modify date: 2014-06-19 Permite filtrar por fechas
-- Modify date: 2014-06-19 Permite filtrar por importe y subdirecciones
-- Description:	Obtiene las ofertas de AS400 que hay que mostrar en la web de Gestión Comercial Internacional
-- =============================================
CREATE PROCEDURE [dbo].[spWEB_GCI_ObtenerOfertasInternacionalesPaisesEstables]
	@IdPais as varchar(3) = NULL, 
    @Concepto as varchar(255) = NULL, 
    @ZonaComercial as int = NULL, 
	@ProyectoSingular as bit = NULL, 
	@OfertaAsunto as bit = NULL,
	@OfertaPreparacion as bit = NULL, 
	@OfertaPresentada as bit = NULL, 
	@OfertaDenegada as bit = NULL, 
	@OfertaAdjudicada as bit = NULL,
	@fechaDesde as datetime = NULL, 
	@operacionFecha as varchar(5) = NULL, 
	@idResponsableComercial as varchar(3) = NULL, 
	@ImporteDesde AS money = NULL, 
    @ImporteHasta as money = NULL, 
    @OperacionImporte as varchar(10) = NULL,
    @SDGEnergia as bit = NULL, 
    @SDGRedes as bit = NULL, 
    @SDGInstalacionesCentro as bit = NULL, 
	@SDGInstalacionesNorteAmerica as bit = NULL, 
	@SDGInstalacionesNordeste as bit = NULL, 
	@SDGInstalacionesSur as bit = NULL, 
	@SDGInstalacionesEste as bit = NULL, 
	@SDGIngenieria as bit = NULL	
AS
BEGIN
	SET NOCOUNT ON;

	
	SELECT CASE 
											WHEN Ofertar = ''   THEN CONVERT (DATETIME, CAST(AñoGra AS VARCHAR(4)) + '-' + '01' + '-' + CAST(RIGHT ('00'+ltrim(str(MesGra)),2 ) AS VARCHAR(2)), 104) 
											WHEN Ofertar = 'NO' THEN CONVERT (DATETIME, CAST(AñoGra AS VARCHAR(4)) + '-' + '01' + '-' + CAST(RIGHT ('00'+ltrim(str(MesGra)),2 ) AS VARCHAR(2)), 104) 
											WHEN Ofertar = 'SI' AND(AÑOPRES IS NULL AND MESPRES IS NULL) THEN CONVERT (DATETIME, CAST(AñoGra AS VARCHAR(4)) + '-' + '01' + '-' + RIGHT ('00'+ltrim(str(MesGra)),2 ), 104) 
											WHEN Adjudicada = 'N' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN CONVERT (DATETIME, CAST(AñoPres AS VARCHAR(4)) + '-' + '01' + '-' + CAST(MesPres AS VARCHAR(2)), 104) 
											WHEN Adjudicada = 'S' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN CONVERT (DATETIME, CAST(AñoAd AS VARCHAR(4)) + '-' + '01' + '-' + CAST(MesAd AS VARCHAR(2)), 104) 
											WHEN Adjudicada = ''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN CONVERT (DATETIME, CAST(AñoPres AS VARCHAR(4)) + '-' + '01' + '-' + CAST(MesPres AS VARCHAR(2)), 104) 
										END AS FechaPresentacion, 
										LTRIM(RTRIM([Sumarigrama].NombreDirNegocio)) as Intervinientes, 
										CASE 
											WHEN Ofertar = '' THEN 'Asunto' 
											WHEN Ofertar = 'NO' THEN 'Abandonada' 
											WHEN Ofertar = 'SI' AND (AÑOPRES IS NULL AND MESPRES IS NULL) THEN 'Preparación' 
											WHEN Adjudicada = 'N' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN 'Denegada' 
											WHEN Adjudicada = 'S' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN 'Adjudicada' 
											WHEN Adjudicada = ''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN 'Presentada'
										END as Nombrefase, 
										CAST(CodOfer AS VARCHAR(10)) AS CodOferta, 
										LTRIM(RTRIM(DesOfer)) AS Proyecto,
										LTRIM(RTRIM(NomProvincia)) as NombrePais,
										CodProvincia as Pais,
										LTRIM(RTRIM(ClienAgrupado)) as Cliente, 
										Responsable as CodResponsableDeNegocio, 
										CodResponsableComercial,
										CASE 
											WHEN Ofertar = '' THEN ImpAprox 
											WHEN Ofertar = 'NO' THEN ImpAprox 
											WHEN (AÑOPRES IS NULL AND MESPRES IS NULL) THEN ImpAprox 
											WHEN Adjudicada = 'N' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ImpPres 
											WHEN Adjudicada = 'S' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ImpAdj 
											WHEN Adjudicada = ''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) THEN ImpPres 
										END AS ImporteEstimadoEnEuros,
										ImpAprox, ImpAdj, ImpPres 
						FROM	[RP_SIC].[dbo].[@@@Ofertas2005] as Ofertas LEFT JOIN  [RP_SIC].[dbo].[Sumarigrama] ON Ofertas.CT = [RP_SIC].[dbo].[Sumarigrama].CodCentro LEFT JOIN [RP_SIC].[dbo].[GCIPaises] P ON Ofertas.CodProvincia = P.IdPais LEFT JOIN [RP_SIC].[DBO].[GCIZonas] Z ON P.IdZona = Z.IdZona LEFT JOIN [RP_SIC].[DBO].[GCIZonasComerciales] ZC ON Z.IdZonacomercial = ZC.IdZonaComercial LEFT JOIN ResponsablesComercialesPorPais RCP on RCP.CodPais = Ofertas.CodProvincia 
										WHERE	
											Mercado = 'Internacional'
											AND BAJA <> 'B' 
											AND (  
												   (ImpAprox >= 10000000 AND Ofertar =''    AND  (CONVERT (DATETIME, CAST(AñoGra  AS VARCHAR(4)) + '-' + '01' + '-' + CAST(RIGHT ('00'+LTRIM(STR(MesGra)),2 ) AS VARCHAR(2)), 104) >= '2014-01-01') 
												OR (ImpAprox >= 10000000 AND Ofertar = 'NO' AND  (CONVERT (DATETIME, CAST(AñoGra  AS VARCHAR(4)) + '-' + '01' + '-' + CAST(RIGHT ('00'+LTRIM(STR(MesGra)),2 ) AS VARCHAR(2)), 104) >= '2014-01-01')) 
												OR (ImpAprox >= 10000000 AND Ofertar = 'SI' AND AÑOPRES IS NULL AND MESPRES IS NULL AND (CONVERT (DATETIME, CAST(AñoGra  AS VARCHAR(4)) + '-' + '01' + '-' + CAST(RIGHT ('00'+LTRIM(STR(MesGra)),2 ) AS VARCHAR(2)), 104) >= '2013-01-01')) 
												OR (ImPPres  >= 10000000 AND Adjudicada = 'N' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL)	AND (CONVERT (DATETIME, CAST(AñoPres AS VARCHAR(4)) + '-' + '01' + '-' + CAST(RIGHT ('00'+LTRIM(STR(MESPRES)),2 ) AS VARCHAR(2)), 104) >= '2013-01-01')) 
												OR (ImPPres  >= 10000000 AND Adjudicada = ''  AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL)	AND (CONVERT (DATETIME, CAST(AñoPres AS VARCHAR(4)) + '-' + '01' + '-' + CAST(RIGHT ('00'+LTRIM(STR(MESPRES)),2 ) AS VARCHAR(2)), 104) >= '2013-01-01')) 
												OR (ImpAdj   >= 10000000 AND Adjudicada = 'S' AND (AÑOPRES IS NOT NULL AND MESPRES IS NOT NULL) AND (CONVERT (DATETIME, CAST(AÑOAD   AS VARCHAR(4)) + '-' + '01' + '-' + CAST(RIGHT ('00'+LTRIM(STR(MESAD)),2 )   AS VARCHAR(2)), 104) >= '2013-01-01'))
												)
											) AND (NombreDirNegocio = '' OR NombreDirNegocio IS NULL)
											and (codprovincia = 'AR'
												or codprovincia = 'BR'
												or codprovincia = 'CL'
												or codprovincia = 'DO'
												or codprovincia = 'HN'
												or codprovincia = 'IT'
												or codprovincia = 'PT'
												or codprovincia = 'US'
												or codprovincia = 'UY'
												or codprovincia = 'UK'
												)
											
											 ORDER BY DesOfer
											
END








