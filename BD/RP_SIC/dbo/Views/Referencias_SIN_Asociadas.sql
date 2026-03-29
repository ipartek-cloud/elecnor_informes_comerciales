

/*AND (dbo.fnNumReferencia_Montos(idReferencia) > 0)*/
CREATE VIEW [dbo].[Referencias_SIN_Asociadas]
AS
SELECT        idReferencia, CodOferta, Proyecto, Memoria, ClienteFinal, NombreUTE, PorcentajeUTE, MesInicio, AñoInicio, Plazo, 
                         MesFinPrevista, AñoFinPrevista, Fecha, ImporteCertificado, SinReferencia, Facturacion, idReferenciasSectores, CCTV, CCAA, Intrusion, LecturaMatriculas, Megafonia, 
                         AudioVisual, Redes, Telefonia, Wifi, SmartCities, Parking, Aguas, PCI, Automatizacion, Mantenimientos, CodCPV
FROM            Certificaciones.dbo.Referencias AS Referencias
WHERE        (SinReferencia = 0)
AND CodOferta<>''

