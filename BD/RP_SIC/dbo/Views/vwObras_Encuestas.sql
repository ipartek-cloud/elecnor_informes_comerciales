


CREATE VIEW [dbo].[vwObras_Encuestas]
AS
SELECT *
FROM OPENQUERY(SIC, 
				'SELECT DISTINCT  Obras.CTR CDCEN, Obras.OBRA, Obras.DSOBR, Obras.CDCLI, 
--						Obras.CDACT, 
						CONCAT(''0'',LEFT(Obras.CDACT,1)) CDAC1, RIGHT(Obras.CDACT,2) CDAC2, 
						Ofertas.CDOFT, Ofertas.DCOF
				FROM  S44DD901.ICOMERF.IC09AP As Ofertas INNER JOIN 
					S44DD901.FICOSCO.CO005BP AS Enlaces ON Ofertas.CDCEN=Enlaces.CTRO AND Ofertas.CDOFT=Enlaces.CDOFT INNER JOIN
					S44DD901.FICOSCO.CO250AP AS Obras ON Enlaces.CTRO=Obras.CTR AND LEFT(Enlaces.OBRA, 3)=Obras.OBRA AND RIGHT(Enlaces.OBRA, 2)=Obras.OBRAL
				WHERE (substr( digits(dec(19000000+FECHAA,8,0)), 1, 4 ) >= 2016) AND (ADELE = ''S'' )
				AND OBRAL=''00''
				')
				AS vw

WHERE CDCEN IN (
SELECT RIGHT('0' + cast(CodCentro as varchar(3)),3) CodCentro
FROM Sumarigrama)




--SELECT RIGHT('0' + cast(CodCentro as varchar(3)),3) CodCentro
--FROM Sumarigrama2019
--order by CodCentro
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[vwObras_Encuestas] TO [encuestas]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[vwObras_Encuestas] TO [encuestas]
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[vwObras_Encuestas] TO [encuestas]
    AS [dbo];

