
CREATE PROCEDURE [spContratacionHistorico2019_Excel]

AS
BEGIN

/*
select sum(Importe), count(*)-- * 
from HistoricoContratacionGrupoSQL
where Año=2019


select Año, Mes, Mercado, ISNULL(P.NOMBREPAIS, 'España') Pais, 
	RIGHT('000'+cast(S.CodDDirNegocio as varchar(3)),3) [DN-], S.NombreDirNegocio Descrip_DN, RIGHT('000'+cast(HCGS.CodCentro as varchar(3)),3) CodCentro, 
	HCGS.CodOferta CodOfer, O.CDOFT, O_Atersa.CodOferta,
	O.CDCLI CodCliente, O.DESPRO NomCliente, O.DCOF DesOfer, 
	HCGS.Importe, '' Reg, O.WS10 [Tipo Oferta], CAST(O.CDAC1+O.CDAC2 as int) Actividad, '' CodObra, O.PROOF [Pro/Pais], 
	CASE WHEN CM.CodOferta Is null THEN 'N' ELSE 'S' END CM--, * 
from HistoricoContratacionGrupoSQL HCGS 
	LEFT JOIN Ofertas O ON HCGS.CodOferta=O.CDOFT
	LEFT JOIN (select * from OfertasSQL where Reparto=0) O_Atersa on HCGS.CodOferta=O_Atersa.CodOferta
	LEFT JOIN (select CodCentro, CodDDirNegocio, NombreDirNegocio from Sumarigrama2019) S ON HCGS.CodCentro=S.CodCentro
	LEFT JOIN GCIPaises P ON O.PROOF=P.IDPAIS
	LEFT JOIN (select distinct CDOC2016.CodOferta, CDCS.Tipo--, * 
from Cart_DiferidaOfertasContratos_2016SQL CDOC2016 inner join Cart_DiferidaContratosSQL CDCS on CDOC2016.ID=CDCS.ID
where CDCS.Tipo='T') CM on HCGS.CodOferta=CM.CodOferta
where Año=2019
--and O.CDOFT is null
--and O.CDOFT is not null and O_Atersa.CodOferta is not null
ORDER BY Año, Mes, Mercado, ISNULL(P.NOMBREPAIS, 'España')
*/


	SELECT Año, Mes, Mercado, ISNULL(P.NOMBREPAIS, 'España') Pais, 
		RIGHT('000'+cast(S.CodDDirNegocio as varchar(3)),3) [DN-], S.NombreDirNegocio Descrip_DN, RIGHT('000'+cast(HCGS.CodCentro as varchar(3)),3) CodCentro, 
		HCGS.CodOferta CodOfer, 
		O.CodCliente, O.NombreCliente, O.DescripcionOferta, 
		HCGS.Importe, '' Reg, O.Tipo [Tipo Oferta], O.Actividad, '' CodObra, O.PaisProv [Pro/Pais], 
		CASE WHEN CM.CodOferta Is null THEN 'N' ELSE 'S' END CM--, * 
	FROM HistoricoContratacionGrupoSQL HCGS 
		LEFT JOIN (
					SELECT PROOF PaisProv, CDCEN CodCentro, CDOFT CodOferta, CDCLI CodCliente, DESPRO NombreCliente, DCOF DescripcionOferta, WS10 Tipo, CAST(CDAC1+CDAC2 as int) Actividad--,* 
					FROM Ofertas
					
					UNION
					
					SELECT MIN(CodProv) PaisProv, Min(CodCentro) CodCentro, CodOferta, MIN(CodCliente) CodCliente, '' NombreCliente, MIN(DescripcionOferta) DescripcionOferta, '' Tipo, MIN(CAST(CodAct1+CodAct2 as int)) Actividad --,* 
					FROM OfertasSQL 
					WHERE Reparto=0
					GROUP BY CodOferta
					) O ON HCGS.CodOferta=O.CodOferta
		LEFT JOIN (
					SELECT CodCentro, CodDDirNegocio, NombreDirNegocio FROM Sumarigrama2019
					) S ON HCGS.CodCentro=S.CodCentro
		LEFT JOIN GCIPaises P ON O.PaisProv=P.IDPAIS
		LEFT JOIN (
					SELECT DISTINCT CDOC2016.CodOferta, CDCS.Tipo 
					FROM Cart_DiferidaOfertasContratos_2016SQL CDOC2016 inner join Cart_DiferidaContratosSQL CDCS on CDOC2016.ID=CDCS.ID
					WHERE CDCS.Tipo='T'
					) CM ON HCGS.CodOferta=CM.CodOferta
	WHERE Año=2019
	ORDER BY Año, Mes, Mercado, ISNULL(P.NOMBREPAIS, 'España')
END
