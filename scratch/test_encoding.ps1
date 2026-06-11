$f = Get-ChildItem -Path "c:\TrabajoVBNet\Elecnor\elecnor_informes_comerciales\BD\RP_SIC\dbo\Stored Procedures\" -Filter "*_SG_Mercado.sql"
$path = $f[0].FullName

# Leer los bytes crudos del archivo para ver el formato exacto en el disco
$bytes = [System.IO.File]::ReadAllBytes($path)

# Buscar la secuencia 'spContratacion_Mensual_Acumulada_'
# 'A' = 65, '' / 'ñ' / 'o' = ?
# Imprimir los bytes del archivo en la sección del nombre del SP
# Buscamos la secuencia 'CREATE PROCEDURE' en los bytes
$patternBytes = [System.Text.Encoding]::ASCII.GetBytes("CREATE PROCEDURE")
$foundOffset = -1
for ($i = 0; $i -lt $bytes.Length - $patternBytes.Length; $i++) {
    $match = $true
    for ($j = 0; $j -lt $patternBytes.Length; $j++) {
        if ($bytes[$i + $j] -ne $patternBytes[$j]) {
            $match = $false
            break
        }
    }
    if ($match) {
        $foundOffset = $i
        break
    }
}

if ($foundOffset -ne -1) {
    Write-Host "Encontrada firma en el byte offset: $foundOffset"
    # Imprimir los siguientes 120 bytes
    $segment = New-Object byte[] 120
    [System.Array]::Copy($bytes, $foundOffset, $segment, 0, 120)
    
    Write-Host "Bytes crudos:"
    $bytesStr = $segment | ForEach-Object { "{0:X2}" -f $_ }
    Write-Host ($bytesStr -join " ")
    
    # Intentar decodificar con UTF-8
    Write-Host "Decodificado UTF-8: $([System.Text.Encoding]::UTF8.GetString($segment))"
    # Intentar decodificar con Windows-1252
    Write-Host "Decodificado 1252: $([System.Text.Encoding]::GetEncoding(1252).GetString($segment))"
}
