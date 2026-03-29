
CREATE PROCEDURE sp_CambiarTiposColumnas_Claude
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Declaración de variables
    DECLARE @sql NVARCHAR(MAX);
    DECLARE @tabla NVARCHAR(128);
    DECLARE @campo NVARCHAR(128);
    DECLARE @nuevo_tipo NVARCHAR(20);
    DECLARE @nuevo_valor NVARCHAR(100);
    DECLARE @pk_name NVARCHAR(128);
    DECLARE @pk_columns NVARCHAR(MAX);
    DECLARE @pk_clustered BIT;
    DECLARE @index_name NVARCHAR(128);
    DECLARE @index_columns NVARCHAR(MAX);
    DECLARE @index_included NVARCHAR(MAX);
    DECLARE @index_unique BIT;
    DECLARE @index_clustered BIT;
    DECLARE @error_msg NVARCHAR(500);
 
 -------------- Excepciones (borrar campos)
 ALTER TABLE WEB_CarteraDiferidaPdteEjecutarUsuarioCentro DROP COLUMN MarcaCodCentro

 ALTER TABLE WEB_ContratacionActividadUsuarioCentro DROP COLUMN Objetivos
 ---------------------------------------------------

BEGIN
    -- Tabla temporal con todos los pares tabla-campo
    CREATE TABLE #TablasColumnas (
        Tabla NVARCHAR(128),
        Campo NVARCHAR(128)
    );
    
    -- Insertar todos los pares tabla-campo
    INSERT INTO #TablasColumnas VALUES
    ('Cart_DiferidaOfertasContratos_2016SQL', 'CodOferta'),
    ('Cart_DiferidaOfertasContratosSQL', 'CodOferta'),
    ('CarteraDiferidaSQL', 'CodOferta'),
    ('CarteraDiferidaSQLContratado', 'CodOferta'),
    ('CarteraPdteProducirSQL', 'CodCentro'),
    ('CarterasContratacionSQL', 'CodOferta'),
    ('CentroCarteraAjustadaSQL', 'CodCentro'),
    ('CentrosGerentesSQL', 'CodCentro'),
    ('CentrosGerentesSQL_2021', 'CodCentro'),
    ('ContratacionesReguladasSQL', 'CodCentro'),
    ('ContratacionesReguladasSQL', 'CodOferta'),
    ('ContratosMarcoenCRM', 'CodOferta'),
    ('ContratProyecSingulares', 'CodOferta'),
    ('DirGeneral', 'CodDirGeneral'),
    ('Enlace_SubDirGeneral_DirNegocio', 'CodDirGeneral'),
    ('Enlace_SubDirGeneral_DirNegocio', 'CodSubDirGeneral'),
    ('Enlace_SubDirNegocioArea_Delegaciones', 'CodDelegacion'),
    ('Enlace_SubDirNegocioArea_Delegaciones', 'CodSubDirNegocioArea'),
    ('FilialesSQL', 'CodCentro'),
    ('HistoricoContratacionGrupoSQL', 'CodCentro'),
    ('HistoricoContratacionGrupoSQL', 'CodOferta'),
    ('NomOfertas_CM', 'CodOferta'),
    ('NomOfertasAdjudicadasSQL', 'CodOferta'),
    ('NomOfertasSQL', 'CodOferta'),
    ('ObjetivosActividadSQL', 'CodCentro'),
    ('ObjetivosDelegacionSQL', 'CodDelegacion'),
    ('ObjetivosSQL', 'CodSubDirGeneral'),
    ('ObrasParaClasificacion', 'CodCentro'),
    ('OfertasBajasSQL', 'CodCentro'),
    ('OfertasBajasSQL', 'CodOferta'),
    ('OfertasSQL', 'CodCentro'),
    ('OfertasSQL', 'CodOferta'),
    ('OfertasSQL_Ajustes', 'CodCentro'),
    ('OfertasSQL_Ajustes', 'CodOferta'),
    ('ProyectosSingularesSQL', 'CodOferta'),
    ('Reparto', 'CodCentro'),
    ('RestoOfertas', 'CodCentro'),
    ('RestoOfertas', 'CodOferta'),
    ('rptPrincipalesContratacion', 'CodCentro'),
    ('rptPrincipalesContratacion', 'CodOferta'),
    ('rptPrincipalesContratacion_TMP', 'CodCentro'),
    ('rptPrincipalesContratacion_TMP', 'CodOferta'),
    ('rptPrincipalesObras', 'CodCentro'),
    ('rptPrincipalesObras', 'CodOferta'),
    ('rptPrincipalesObrasAI', 'CodOferta'),
    ('SubDirGeneral', 'CodDirGeneral'),
    ('SubDirGeneral', 'CodSubDirGeneral'),
    ('SubDirNegocioArea', 'CodSubDirNegocioArea'),
    ('Sumarigrama', 'CodCentro'),
    ('Sumarigrama', 'CodDDirNegocio'),
    ('Sumarigrama', 'CodDelegacion'),
    ('Sumarigrama', 'CodDirGeneral'),
    ('Sumarigrama', 'CodSubDirGeneral'),
    ('Sumarigrama', 'CodSubDirNegocioArea'),
    ('Sumarigrama_Centros_Certificaciones', 'CodCentro'),
    ('Sumarigrama_Centros_Certificaciones', 'CodDelegacion'),
    ('Sumarigrama_TEST', 'CodCentro'),
    ('Sumarigrama_TEST', 'CodDDirNegocio'),
    ('Sumarigrama_TEST', 'CodDelegacion'),
    ('Sumarigrama_TEST', 'CodDirGeneral'),
    ('Sumarigrama_TEST', 'CodSubDirGeneral'),
    ('Sumarigrama_TEST', 'CodSubDirNegocioArea'),
    ('Sumarigrama2014', 'CodCentro'),
    ('Sumarigrama2014', 'CodDDirNegocio'),
    ('Sumarigrama2014', 'CodDelegacion'),
    ('Sumarigrama2014', 'CodDirGeneral'),
    ('Sumarigrama2014', 'CodSubDirGeneral'),
    ('Sumarigrama2014', 'CodSubDirNegocioArea'),
    ('Sumarigrama2015', 'CodCentro'),
    ('Sumarigrama2015', 'CodDDirNegocio'),
    ('Sumarigrama2015', 'CodDelegacion'),
    ('Sumarigrama2015', 'CodDirGeneral'),
    ('Sumarigrama2015', 'CodSubDirGeneral'),
    ('Sumarigrama2015', 'CodSubDirNegocioArea'),
    ('Sumarigrama2016', 'CodCentro'),
    ('Sumarigrama2016', 'CodDDirNegocio'),
    ('Sumarigrama2016', 'CodDelegacion'),
    ('Sumarigrama2016', 'CodDirGeneral'),
    ('Sumarigrama2016', 'CodSubDirGeneral'),
    ('Sumarigrama2016', 'CodSubDirNegocioArea'),
    ('Sumarigrama2017', 'CodCentro'),
    ('Sumarigrama2017', 'CodDDirNegocio'),
    ('Sumarigrama2017', 'CodDelegacion'),
    ('Sumarigrama2017', 'CodDirGeneral'),
    ('Sumarigrama2017', 'CodSubDirGeneral'),
    ('Sumarigrama2017', 'CodSubDirNegocioArea'),
    ('Sumarigrama2018', 'CodCentro'),
    ('Sumarigrama2018', 'CodDDirNegocio'),
    ('Sumarigrama2018', 'CodDelegacion'),
    ('Sumarigrama2018', 'CodDirGeneral'),
    ('Sumarigrama2018', 'CodSubDirGeneral'),
    ('Sumarigrama2018', 'CodSubDirNegocioArea'),
    ('Sumarigrama2019', 'CodCentro'),
    ('Sumarigrama2019', 'CodDDirNegocio'),
    ('Sumarigrama2019', 'CodDelegacion'),
    ('Sumarigrama2019', 'CodDirGeneral'),
    ('Sumarigrama2019', 'CodSubDirGeneral'),
    ('Sumarigrama2019', 'CodSubDirNegocioArea'),
    ('Sumarigrama2020', 'CodCentro'),
    ('Sumarigrama2020', 'CodDDirNegocio'),
    ('Sumarigrama2020', 'CodDelegacion'),
    ('Sumarigrama2020', 'CodDirGeneral'),
    ('Sumarigrama2020', 'CodSubDirGeneral'),
    ('Sumarigrama2020', 'CodSubDirNegocioArea'),
    ('Sumarigrama2021', 'CodCentro'),
    ('Sumarigrama2021', 'CodDDirNegocio'),
    ('Sumarigrama2021', 'CodDelegacion'),
    ('Sumarigrama2021', 'CodDirGeneral'),
    ('Sumarigrama2021', 'CodSubDirGeneral'),
    ('Sumarigrama2021', 'CodSubDirNegocioArea'),
    ('Sumarigrama2022', 'CodCentro'),
    ('Sumarigrama2022', 'CodDDirNegocio'),
    ('Sumarigrama2022', 'CodDelegacion'),
    ('Sumarigrama2022', 'CodDirGeneral'),
    ('Sumarigrama2022', 'CodSubDirGeneral'),
    ('Sumarigrama2022', 'CodSubDirNegocioArea'),
    ('Sumarigrama2023', 'CodCentro'),
    ('Sumarigrama2023', 'CodDDirNegocio'),
    ('Sumarigrama2023', 'CodDelegacion'),
    ('Sumarigrama2023', 'CodDirGeneral'),
    ('Sumarigrama2023', 'CodSubDirGeneral'),
    ('Sumarigrama2023', 'CodSubDirNegocioArea'),
    ('Sumarigrama2024', 'CodCentro'),
    ('Sumarigrama2024', 'CodDDirNegocio'),
    ('Sumarigrama2024', 'CodDelegacion'),
    ('Sumarigrama2024', 'CodDirGeneral'),
    ('Sumarigrama2024', 'CodSubDirGeneral'),
    ('Sumarigrama2024', 'CodSubDirNegocioArea'),
    ('Tendencias', 'CodCentro'),
    ('WEB_CarteraDetalladaUsuarioCentro', 'CodOferta'),
	-- Tiene campo calculado con CodCentro (MarcaCodCentro)
	('WEB_CarteraDiferidaPdteEjecutarUsuarioCentro', 'CodCentro'),
	('WEB_CarteraDiferidaPdteEjecutarUsuarioCentro', 'CodDDirNegocio'),
	('WEB_CarteraDiferidaPdteEjecutarUsuarioCentro', 'CodDelegacion'),
	('WEB_CarteraDiferidaPdteEjecutarUsuarioCentro', 'CodDirGeneral'),
	('WEB_CarteraDiferidaPdteEjecutarUsuarioCentro', 'CodOferta'),
	('WEB_CarteraDiferidaPdteEjecutarUsuarioCentro', 'CodSubDirGeneral'),
	('WEB_CarteraDiferidaPdteEjecutarUsuarioCentro', 'CodSubDirNegocioArea'),
    ('WEB_CarteraUsuarioCentro', 'CodCentro'),
    ('WEB_CarteraUsuarioCentro', 'CodDDirNegocio'),
    ('WEB_CarteraUsuarioCentro', 'CodDelegacion'),
    ('WEB_CarteraUsuarioCentro', 'CodDirGeneral'),
    ('WEB_CarteraUsuarioCentro', 'CodSubDirGeneral'),
    ('WEB_CarteraUsuarioCentro', 'CodSubDirNegocioArea'),
    ('WEB_CarteraUsuarioCentro_TMP', 'CodCentro'),
    ('WEB_CertificacionesUsuarioCentro', 'CodCentro'),
    ('WEB_CertificacionesUsuarioCentro', 'CodDDirNegocio'),
    ('WEB_CertificacionesUsuarioCentro', 'CodDelegacion'),
    ('WEB_CertificacionesUsuarioCentro', 'CodDirGeneral'),
    ('WEB_CertificacionesUsuarioCentro', 'CodSubDirGeneral'),
    ('WEB_CertificacionesUsuarioCentro', 'CodSubDirNegocioArea'),
    ('WEB_ContratacionActividadesUsuarioCentro_TMP', 'CodCentro'),
	-- WEB_ContratacionActividadUsuarioCentro tiene campo calculado con CodCentro
    ('WEB_ContratacionActividadUsuarioCentro', 'CodCentro'),
    ('WEB_ContratacionActividadUsuarioCentro', 'CodDDirNegocio'),
    ('WEB_ContratacionActividadUsuarioCentro', 'CodDelegacion'),
    ('WEB_ContratacionActividadUsuarioCentro', 'CodDirGeneral'),
    ('WEB_ContratacionActividadUsuarioCentro', 'CodSubDirGeneral'),
    ('WEB_ContratacionActividadUsuarioCentro', 'CodSubDirNegocioArea'),
    ('WEB_ContratacionDetalladaUsuarioCentro', 'CodCentro'),
    ('WEB_ContratacionDetalladaUsuarioCentro', 'CodOferta'),
    ('WEB_ContratacionUsuarioCentro', 'CodCentro'),
    ('WEB_ContratacionUsuarioCentro', 'CodDDirNegocio'),
    ('WEB_ContratacionUsuarioCentro', 'CodDelegacion'),
    ('WEB_ContratacionUsuarioCentro', 'CodDirGeneral'),
    ('WEB_ContratacionUsuarioCentro', 'CodSubDirGeneral'),
    ('WEB_ContratacionUsuarioCentro', 'CodSubDirNegocioArea'),
    ('WEB_ContratacionUsuarioCentro_TMP', 'CodCentro'),
    ('WEB_OfertacionDetalladaUsuarioCentro', 'CodCentro'),
    ('WEB_OfertacionDetalladaUsuarioCentro', 'CodOferta'),
    ('WEB_OfertacionUsuarioCentro', 'CodCentro'),
    ('WEB_OfertacionUsuarioCentro', 'CodDDirNegocio'),
    ('WEB_OfertacionUsuarioCentro', 'CodDelegacion'),
    ('WEB_OfertacionUsuarioCentro', 'CodDirGeneral'),
    ('WEB_OfertacionUsuarioCentro', 'CodSubDirGeneral'),
    ('WEB_OfertacionUsuarioCentro', 'CodSubDirNegocioArea'),
    ('WEB_OfertacionUsuarioCentro_TMP', 'CodCentro'),
    ('WEB_TMP_ContratacionAS400', 'CodCentro'),
    ('WEB_TMP_ContratacionAS400', 'CodOferta');
    
    -- Tablas temporales para almacenar información de PK e índices a recrear
    CREATE TABLE #PKsARecuperar (
        Tabla NVARCHAR(128),
        NombrePK NVARCHAR(128),
        Columnas NVARCHAR(MAX),
        EsClustered BIT
    );
    
    CREATE TABLE #IndicesARecuperar (
        Tabla NVARCHAR(128),
        NombreIndice NVARCHAR(128),
        Columnas NVARCHAR(MAX),
        ColumnasIncluidas NVARCHAR(MAX),
        EsUnico BIT,
        EsClustered BIT
    );
    
    -- Cursor para procesar cada tabla
    DECLARE tabla_cursor CURSOR FOR
    SELECT DISTINCT Tabla FROM #TablasColumnas ORDER BY Tabla;
    
    OPEN tabla_cursor;
    FETCH NEXT FROM tabla_cursor INTO @tabla;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            PRINT 'Procesando tabla: ' + @tabla;
            
            -- Verificar si la tabla existe
            IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @tabla)
            BEGIN
                PRINT 'ADVERTENCIA: La tabla ' + @tabla + ' no existe. Saltando...';
                FETCH NEXT FROM tabla_cursor INTO @tabla;
                CONTINUE;
            END
            
            -- Limpiar tablas temporales para esta tabla
            DELETE FROM #PKsARecuperar WHERE Tabla = @tabla;
            DELETE FROM #IndicesARecuperar WHERE Tabla = @tabla;
            
            -- PASO 1: Identificar y guardar información de PK que contengan campos a modificar
            SELECT @pk_name = NULL, @pk_columns = NULL, @pk_clustered = NULL;
            
            SELECT 
                @pk_name = kc.CONSTRAINT_NAME,
                @pk_clustered = CASE WHEN i.type = 1 THEN 1 ELSE 0 END
            FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
            INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kc ON tc.CONSTRAINT_NAME = kc.CONSTRAINT_NAME
            INNER JOIN sys.indexes i ON i.object_id = OBJECT_ID(@tabla) AND i.name = kc.CONSTRAINT_NAME
            WHERE tc.TABLE_NAME = @tabla 
                AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                AND kc.COLUMN_NAME IN (SELECT Campo FROM #TablasColumnas WHERE Tabla = @tabla);
            
            IF @pk_name IS NOT NULL
            BEGIN
                -- Obtener columnas de la PK usando cursor
                DECLARE @pk_col NVARCHAR(128);
                SET @pk_columns = '';
                
                DECLARE pk_cursor CURSOR FOR
                SELECT COLUMN_NAME
                FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
                WHERE CONSTRAINT_NAME = @pk_name
                ORDER BY ORDINAL_POSITION;
                
                OPEN pk_cursor;
                FETCH NEXT FROM pk_cursor INTO @pk_col;
                
                WHILE @@FETCH_STATUS = 0
                BEGIN
                    SET @pk_columns = @pk_columns + CASE WHEN @pk_columns = '' THEN '' ELSE ', ' END + QUOTENAME(@pk_col);
                    FETCH NEXT FROM pk_cursor INTO @pk_col;
                END
                
                CLOSE pk_cursor;
                DEALLOCATE pk_cursor;
                
                INSERT INTO #PKsARecuperar VALUES (@tabla, @pk_name, @pk_columns, @pk_clustered);
                PRINT 'PK identificada para eliminar: ' + @pk_name;
            END
            
            -- PASO 2: Identificar índices que contengan campos a modificar
            DECLARE index_cursor CURSOR FOR
            SELECT DISTINCT i.name
            FROM sys.indexes i
            INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
            INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
            WHERE i.object_id = OBJECT_ID(@tabla)
                AND i.type > 0  -- Excluir heap
                AND i.is_primary_key = 0  -- Excluir PK (ya manejada arriba)
                AND c.name IN (SELECT Campo FROM #TablasColumnas WHERE Tabla = @tabla);
            
            OPEN index_cursor;
            FETCH NEXT FROM index_cursor INTO @index_name;
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Obtener información del índice
                SELECT 
                    @index_unique = i.is_unique,
                    @index_clustered = CASE WHEN i.type = 1 THEN 1 ELSE 0 END
                FROM sys.indexes i
                WHERE i.object_id = OBJECT_ID(@tabla) AND i.name = @index_name;
                
                -- Obtener columnas del índice
                SET @index_columns = '';
                SET @index_included = '';
                
                DECLARE @col_name NVARCHAR(128);
                DECLARE @is_included BIT;
                
                DECLARE col_cursor CURSOR FOR
                SELECT c.name, ic.is_included_column
                FROM sys.index_columns ic
                INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
                WHERE ic.object_id = OBJECT_ID(@tabla) 
                    AND ic.index_id = (SELECT index_id FROM sys.indexes WHERE object_id = OBJECT_ID(@tabla) AND name = @index_name)
                ORDER BY ic.key_ordinal, ic.index_column_id;
                
                OPEN col_cursor;
                FETCH NEXT FROM col_cursor INTO @col_name, @is_included;
                
                WHILE @@FETCH_STATUS = 0
                BEGIN
                    IF @is_included = 0
                        SET @index_columns = @index_columns + CASE WHEN @index_columns = '' THEN '' ELSE ', ' END + QUOTENAME(@col_name);
                    ELSE
                        SET @index_included = @index_included + CASE WHEN @index_included = '' THEN '' ELSE ', ' END + QUOTENAME(@col_name);
                    
                    FETCH NEXT FROM col_cursor INTO @col_name, @is_included;
                END
                
                CLOSE col_cursor;
                DEALLOCATE col_cursor;
                
                INSERT INTO #IndicesARecuperar VALUES (@tabla, @index_name, @index_columns, @index_included, @index_unique, @index_clustered);
                PRINT 'Índice identificado para eliminar: ' + @index_name;
                
                FETCH NEXT FROM index_cursor INTO @index_name;
            END
            
            CLOSE index_cursor;
            DEALLOCATE index_cursor;
            
            -- PASO 3: Eliminar PK si existe
            IF EXISTS (SELECT 1 FROM #PKsARecuperar WHERE Tabla = @tabla)
            BEGIN
                SELECT @pk_name = NombrePK FROM #PKsARecuperar WHERE Tabla = @tabla;
                SET @sql = 'ALTER TABLE ' + QUOTENAME(@tabla) + ' DROP CONSTRAINT ' + QUOTENAME(@pk_name);
                PRINT 'Eliminando PK: ' + @sql;
                EXEC sp_executesql @sql;
            END
            
            -- PASO 4: Eliminar índices
            DECLARE drop_index_cursor CURSOR FOR
            SELECT NombreIndice FROM #IndicesARecuperar WHERE Tabla = @tabla;
            
            OPEN drop_index_cursor;
            FETCH NEXT FROM drop_index_cursor INTO @index_name;
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @sql = 'DROP INDEX ' + QUOTENAME(@index_name) + ' ON ' + QUOTENAME(@tabla);
                PRINT 'Eliminando índice: ' + @sql;
                EXEC sp_executesql @sql;
                
                FETCH NEXT FROM drop_index_cursor INTO @index_name;
            END
            
            CLOSE drop_index_cursor;
            DEALLOCATE drop_index_cursor;
            
            -- PASO 5: Modificar columnas
            DECLARE campo_cursor CURSOR FOR
            SELECT Campo FROM #TablasColumnas WHERE Tabla = @tabla;
            
            OPEN campo_cursor;
            FETCH NEXT FROM campo_cursor INTO @campo;
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Verificar si la columna existe
                IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(@tabla) AND name = @campo)
                BEGIN
                    -- Determinar el nuevo tipo
                    SET @nuevo_tipo = CASE WHEN @campo = 'CodOferta' THEN 'VARCHAR(10)' ELSE 'VARCHAR(3)' END;
                    
                    SET @sql = 'ALTER TABLE ' + QUOTENAME(@tabla) + ' ALTER COLUMN ' + QUOTENAME(@campo) + ' ' + @nuevo_tipo + ' ' ;
                    PRINT 'Modificando columna: ' + @sql;
                    EXEC sp_executesql @sql;
                END
                ELSE
                BEGIN
                    PRINT 'ADVERTENCIA: La columna ' + @campo + ' no existe en la tabla ' + @tabla;
                END
                
                FETCH NEXT FROM campo_cursor INTO @campo;
            END
            
            CLOSE campo_cursor;
            DEALLOCATE campo_cursor;
 ---------------------------------------------------------------------------------
             -- PASO 5: Modificar valor de las columnas
            DECLARE valor_cursor CURSOR FOR
            SELECT Campo FROM #TablasColumnas WHERE Tabla = @tabla;
            
            OPEN valor_cursor;
            FETCH NEXT FROM valor_cursor INTO @campo;
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Verificar si la columna existe
                IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(@tabla) AND name = @campo)
                BEGIN
                    -- Determinar el nuevo tipo
                    SET @nuevo_valor = CASE WHEN @campo = 'CodOferta' THEN 'RIGHT(''0000000000'' + CodOferta, 10)' ELSE 'RIGHT(''000'' + ' + @campo+ ' , 3)' END;
                    
                    SET @sql = 'UPDATE ' + QUOTENAME(@tabla) + ' SET ' + QUOTENAME(@campo) + ' = ' + @nuevo_valor  ;
                    PRINT 'Modificando valor de las columna: ' + @sql;
                    EXEC sp_executesql @sql;
                END
                ELSE
                BEGIN
                    PRINT 'ADVERTENCIA: La columna ' + @campo + ' no existe en la tabla ' + @tabla;
                END
                
                FETCH NEXT FROM valor_cursor INTO @campo;
            END
            
            CLOSE valor_cursor;
            DEALLOCATE valor_cursor;
 
 ---------------------------------------------------------------------------------
            -- PASO 6: Recrear índices
            DECLARE create_index_cursor CURSOR FOR
            SELECT NombreIndice, Columnas, ColumnasIncluidas, EsUnico, EsClustered 
            FROM #IndicesARecuperar WHERE Tabla = @tabla;
            
            OPEN create_index_cursor;
            FETCH NEXT FROM create_index_cursor INTO @index_name, @index_columns, @index_included, @index_unique, @index_clustered;
            
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @sql = 'CREATE ' + 
                          CASE WHEN @index_unique = 1 THEN 'UNIQUE ' ELSE '' END +
                          CASE WHEN @index_clustered = 1 THEN 'CLUSTERED ' ELSE 'NONCLUSTERED ' END +
                          'INDEX ' + QUOTENAME(@index_name) + ' ON ' + QUOTENAME(@tabla) + 
                          ' (' + @index_columns + ')';
                
                IF @index_included IS NOT NULL AND @index_included <> ''
                    SET @sql = @sql + ' INCLUDE (' + @index_included + ')';
                
                PRINT 'Recreando índice: ' + @sql;
                EXEC sp_executesql @sql;
                
                FETCH NEXT FROM create_index_cursor INTO @index_name, @index_columns, @index_included, @index_unique, @index_clustered;
            END
            
            CLOSE create_index_cursor;
            DEALLOCATE create_index_cursor;
            
            -- PASO 7: Recrear PK si existía
            IF EXISTS (SELECT 1 FROM #PKsARecuperar WHERE Tabla = @tabla)
            BEGIN
                SELECT @pk_name = NombrePK, @pk_columns = Columnas, @pk_clustered = EsClustered 
                FROM #PKsARecuperar WHERE Tabla = @tabla;
                
                SET @sql = 'ALTER TABLE ' + QUOTENAME(@tabla) + ' ADD CONSTRAINT ' + QUOTENAME(@pk_name) + 
                          ' PRIMARY KEY ' + CASE WHEN @pk_clustered = 1 THEN 'CLUSTERED' ELSE 'NONCLUSTERED' END +
                          ' (' + @pk_columns + ')';
                
                PRINT 'Recreando PK: ' + @sql;
                EXEC sp_executesql @sql;
            END
            
            PRINT 'Tabla ' + @tabla + ' procesada correctamente.';
            PRINT '----------------------------------------';
            
        END TRY
        BEGIN CATCH
            SET @error_msg = 'Error procesando tabla ' + @tabla + ': ' + ERROR_MESSAGE();
            PRINT @error_msg;
            PRINT '----------------------------------------';
        END CATCH
        
        FETCH NEXT FROM tabla_cursor INTO @tabla;
    END
    
    CLOSE tabla_cursor;
    DEALLOCATE tabla_cursor;
    
    -- Limpiar tablas temporales
    DROP TABLE #TablasColumnas;
    DROP TABLE #PKsARecuperar;
    DROP TABLE #IndicesARecuperar;
    
END

 -------------- Excepciones (añadir campos)
 ALTER TABLE WEB_CarteraDiferidaPdteEjecutarUsuarioCentro ADD [MarcaCodCentro] AS ([dbo].[fnGerentesMarca_CodCentro]([CodCentro]))

 ALTER TABLE WEB_ContratacionActividadUsuarioCentro ADD Objetivos  AS ([dbo].[fnObjetivos_CT]([año],[Codcentro]))
 ---------------------------------------------------

    PRINT 'Proceso completado.';
END