CREATE PROCEDURE [dbo].[spSincronizar_Sumarigrama]	 	
		AS
BEGIN

		DELETE FROM Sumarigrama
		
		INSERT INTO Sumarigrama (Año,CodDirGeneral, NombreDirGeneral, CodSubDirGeneral, NombreSubDirGeneral, CodDDirNegocio, NombreDirNegocio, CodSubDirNegocioArea,NombreSubDirNegocioArea, CodDelegacion, NombreDelegacion, CodCentro, NombreCentro, OrdenSubDirGeneral)
		SELECT year(getdate()),CodDirGeneral, NombreDirGeneral, CodSubDirGeneral, NombreSubDirGeneral, CodDDirNegocio, NombreDirNegocio, CodSubDirNegocioArea,NombreSubDirNegocioArea, CodDelegacion, NombreDelegacion, CodCentro, NombreCentro, OrdenSubDirGeneral
                FROM   dbo.SumarigramaDB2
		
		-----------------------------------
		-- Paco 26/03/2026. Para sincronizar SumarigramaHistorico

        DECLARE @Año as int
        -- Determina el año del Sumarigrama
        SELECT @Año = MAX(Año) From Sumarigrama

		-- Actualiza SumarigramaHistorico con los datos del Sumarigrama recien importado
        -- Borra los datos del año a importar
		DELETE FROM SumarigramaHistorico WHERE Año=@Año

		-- Inserta los datos que hay en Sumarigrama que son los recien importados
		INSERT INTO SumarigramaHistorico (Año,CodDirGeneral, NombreDirGeneral, CodSubDirGeneral, NombreSubDirGeneral, CodDDirNegocio, NombreDirNegocio, CodSubDirNegocioArea,NombreSubDirNegocioArea, CodDelegacion, NombreDelegacion, CodCentro, NombreCentro, OrdenSubDirGeneral)
		SELECT * FROM Sumarigrama


		select 0
    
END