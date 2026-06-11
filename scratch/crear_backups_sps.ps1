# Script para crear procedimientos almacenados de respaldo (_BACKUP) usando sqlcmd.exe
$server = "172.24.16.51"
$database = "RP_SIC"
$user = "certificaciones"
$password = "ipartek1"

function Crear-BackupSP ($patronArchivoLocal, $regexOriginal, $nombreBackup) {
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
    
    # Reemplazar la firma usando la expresión regular
    if ($sqlContent -match $regexOriginal) {
        Write-Host "Firma de creación identificada correctamente." -ForegroundColor Green
        $sqlContentMod = $sqlContent -replace $regexOriginal, "CREATE PROCEDURE [dbo].[${nombreBackup}]"
    } else {
        Write-Error "No se pudo identificar la firma de creación usando regex: $regexOriginal"
        return
    }

    # Escribir el script temporal en UTF-8 con BOM
    $tempFile = "scratch\temp_backup.sql"
    [System.IO.File]::WriteAllText($tempFile, $sqlContentMod, [System.Text.Encoding]::UTF8)
    Write-Host "Archivo temporal escrito en scratch\temp_backup.sql." -ForegroundColor Yellow

    try {
        # 1. Eliminar el SP de backup si ya existe usando sqlcmd
        Write-Host "Eliminando SP de backup anterior si existe..." -ForegroundColor Yellow
        $dropQuery = "IF OBJECT_ID('dbo.${nombreBackup}', 'P') IS NOT NULL DROP PROCEDURE dbo.${nombreBackup};"
        & sqlcmd -S $server -d $database -U $user -P $password -Q $dropQuery -I
        
        # 2. Crear el SP de backup usando sqlcmd leyendo el archivo temporal en UTF-8 (-f 65001)
        Write-Host "Desplegando SP de backup '$nombreBackup' en SQL Server..." -ForegroundColor Yellow
        & sqlcmd -S $server -d $database -U $user -P $password -i $tempFile -f 65001 -I
        
        Write-Host "SP de backup '$nombreBackup' creado con éxito en SQL Server." -ForegroundColor Green
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

# Ejecutar backups para los dos SPs del Grupo 1
# spContratacion_DG_SDG_DN_SDNA
Crear-BackupSP `
    -patronArchivoLocal "c:\TrabajoVBNet\Elecnor\elecnor_informes_comerciales\BD\RP_SIC\dbo\Stored Procedures\spContratacion_DG_SDG_DN_SDNA.sql" `
    -regexOriginal "CREATE\s+PROCEDURE\s+\[?dbo\]?\.\[?spContratacion_DG_SDG_DN_SDNA\]?" `
    -nombreBackup "spContratacion_DG_SDG_DN_SDNA_BACKUP"

# spContratacion_Mensual_Acumulada_AñoAnterior_SG_Mercado
Crear-BackupSP `
    -patronArchivoLocal "c:\TrabajoVBNet\Elecnor\elecnor_informes_comerciales\BD\RP_SIC\dbo\Stored Procedures\spContratacion_Mensual_Acumulada_*_SG_Mercado.sql" `
    -regexOriginal "CREATE\s+PROCEDURE\s+\[?dbo\]?\.\[?spContratacion_Mensual_Acumulada_.*?_SG_Mercado\]?" `
    -nombreBackup "spContratacion_Mensual_Acumulada_AñoAnterior_SG_Mercado_BACKUP"
