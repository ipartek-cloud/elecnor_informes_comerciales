# Script para desplegar los Stored Procedures RLS en SQL Server
$server = "172.24.16.51"
$database = "RP_SIC"
$user = "certificaciones"
$password = "ipartek1"

function Desplegar-SP ($patronArchivoLocal, $nombreSP, $nombreBuscarLike) {
    Write-Host "Buscando archivo con patrón: $patronArchivoLocal..." -ForegroundColor Cyan
    
    $archivos = Get-Item -Path $patronArchivoLocal -ErrorAction SilentlyContinue
    if ($archivos -eq $null -or $archivos.Count -eq 0) {
        Write-Error "No se encuentra ningún archivo que coincida con: $patronArchivoLocal"
        return
    }
    
    $rutaArchivoLocal = $archivos[0].FullName
    Write-Host "Archivo real encontrado en disco: $rutaArchivoLocal" -ForegroundColor Green

    # Leer el archivo local como UTF-8
    $sqlContent = [System.IO.File]::ReadAllText($rutaArchivoLocal, [System.Text.Encoding]::UTF8)

    # Crear el script de despliegue con DROP dinámico integrado al principio
    # Buscamos el nombre del SP en la base de datos usando LIKE para evitar fallos por codificación de la eñe
    $dropPrefix = @"
DECLARE @spRealName nvarchar(256);
SELECT @spRealName = name 
FROM sys.procedures 
WHERE name LIKE '${nombreBuscarLike}';

IF @spRealName IS NOT NULL
BEGIN
    DECLARE @dropSql nvarchar(max) = 'DROP PROCEDURE dbo.' + QUOTENAME(@spRealName);
    EXEC sp_executesql @dropSql;
    PRINT 'Procedimiento ' + @spRealName + ' eliminado con éxito de forma dinámica.';
END
ELSE
BEGIN
    PRINT 'No se encontró ningún procedimiento para eliminar con patrón: ${nombreBuscarLike}';
END
GO

"@
    $fullSqlContent = $dropPrefix + $sqlContent

    # Escribir el script temporal en UTF-8 con BOM
    $tempFile = "scratch\temp_deploy.sql"
    [System.IO.File]::WriteAllText($tempFile, $fullSqlContent, [System.Text.Encoding]::UTF8)

    try {
        # Crear el SP usando sqlcmd leyendo el archivo temporal en UTF-8 (-f 65001)
        Write-Host "Desplegando SP '$nombreSP' en SQL Server..." -ForegroundColor Yellow
        & sqlcmd -S $server -d $database -U $user -P $password -i $tempFile -f 65001 -I
        
        Write-Host "SP '$nombreSP' desplegado con éxito en SQL Server." -ForegroundColor Green
    }
    catch {
        Write-Error "Error ejecutando sqlcmd: $_"
    }
    finally {
        # Eliminar archivo temporal si existe
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }
    }
}

# Desplegar los dos SPs modificados del Grupo 1
Desplegar-SP `
    -patronArchivoLocal "c:\TrabajoVBNet\Elecnor\elecnor_informes_comerciales\BD\RP_SIC\dbo\Stored Procedures\spContratacion_DG_SDG_DN_SDNA.sql" `
    -nombreSP "spContratacion_DG_SDG_DN_SDNA" `
    -nombreBuscarLike "spContratacion_DG_SDG_DN_SDNA"

Desplegar-SP `
    -patronArchivoLocal "c:\TrabajoVBNet\Elecnor\elecnor_informes_comerciales\BD\RP_SIC\dbo\Stored Procedures\spContratacion_Mensual_Acumulada_*_SG_Mercado.sql" `
    -nombreSP "spContratacion_Mensual_Acumulada_AñoAnterior_SG_Mercado" `
    -nombreBuscarLike "spContratacion_Mensual_Acumulada_%_SG_Mercado"
