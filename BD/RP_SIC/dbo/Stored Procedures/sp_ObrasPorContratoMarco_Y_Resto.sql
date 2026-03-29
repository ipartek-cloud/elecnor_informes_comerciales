CREATE PROCEDURE sp_ObrasPorContratoMarco_Y_Resto (
@pGerencia as varchar(100)='Gas', 
@pAño as int=2020,
@pMes as int=8
) AS

BEGIN

	--DECLARE @E as TABLE (CTRO varchar(3), OBRA varchar(5), CDOFT varchar(35), AAMMA varchar(4), AAMMC varchar(4)) 

	--INSERT INTO @E
	--SELECT *
	--FROM OPENQUERY(SIC, '
	--SELECT     *
	--FROM         S44DD901.FICOSCO.CO005BP AS Enlaces
	--')
	--SELECT * from @E
	/*------------------------
	SELECT *
	FROM OPENQUERY(SIC, '
	SELECT     *
	FROM         S44DD901.FICOSCO.CO005BP AS Enlaces
	')
	------------------------
	*/

	select --G.*, E.*, CM.*, O.*
		G.NombreGerente,
		CM.Cliente, CM.NombreContrato Contrato, CM.Estado EstadoContrato,
		E.CTRO CTR, E.CDOFT, LEFT(E.OBRA, 3) + '-' + RIGHT(E.OBRA, 2) CodObra,
		O.DSOBR NomObra,
		O.SAF FactAño, O.SAP ProdAño, 
		[SAP]-([SAMO]+[SAMA]+[SAE]+[SAT]+[SAS]+[SAV])-[SAI]-[SAPR] MgTajo,
		SOF-SOl FAT,
		SOP-SOL PPF,
		O.CDCLI, Cli.NombreCliente,
		O.CDACT, O.STOBR EstadoObra, Año, Mes
	from ObrasActualesSQL O WITH (NOLOCK)
		LEFT JOIN (
					select RIGHT('000' + RTRIM(CodCentro),3) CTR, NombreGerente 
					from CentrosGerentesSQL WITH (NOLOCK)
					WHERE Año = @pAño
					) G ON O.CTR=G.CTR
		LEFT JOIN Enlaces E  ON O.CTR=E.CTRO AND O.OBRA+O.OBRAL=E.OBRA
		LEFT JOIN (SELECT CAST(CodOferta as varchar(10)) CodOferta, Estado, NombreContrato, Cliente FROM ContratosMarcoenCRM) CM ON E.CDOFT=CodOferta
		LEFT JOIN ClientesSQL Cli WITH (NOLOCK) ON O.CDCLI=Cli.CodCliente
	WHERE Año=@pAño AND Mes=@pMes AND 
	G.NombreGerente=@pGerencia
	AND ISNULL(E.CDOFT,0)<>0
	-- AND O.CTR='343' 
	--AND E.OBRA='07700' AND O.CDCLI='99999999'
	ORDER BY G.NombreGerente, E.CDOFT, O.OBRA

	--select TOP 5 * from ContratosMarcoenCRM
	--select TOP 5 * from Enlaces where CDOFT='1034300027' --Vista
	--where OBRA='93000'

	--select TOP 5 * from ObrasActualesSQL where OBRA='777'
	--select * from ClientesSQL where NombreCliente like 'COMPENSAC%'
	--select * from ContratosMarcoenCRM where CodOferta='1034300027'
END