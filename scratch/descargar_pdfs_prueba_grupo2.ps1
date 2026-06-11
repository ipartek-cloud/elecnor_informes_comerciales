# Script de descarga y verificación de PDFs de prueba con renombrado único (Grupo 2)
$descargasDir = "c:\TrabajoVBNet\Elecnor\elecnor_informes_comerciales\descargas"
if (-not (Test-Path $descargasDir)) {
    New-Item -ItemType Directory -Path $descargasDir | Out-Null
}

# Limpiar archivos de pruebas anteriores en la carpeta descargas
Get-ChildItem -Path $descargasDir -Filter "5_contrataciones_2026_5_*.pdf" | Remove-Item -Force -ErrorAction SilentlyContinue

# Seleccionar una muestra representativa de 12 usuarios de pruebas (2 por cada puesto jerárquico RLS)
$usuariosPrueba = @(
    # DG (Visión Global)
    "Ipartek_DG_218",
    
    # SDG (Subdirección General)
    "Ipartek_SDG_221",
    "Ipartek_SDG_286",
    
    # DN (Dirección de Negocio)
    "Ipartek_DN_090",
    "Ipartek_DN_700",
    
    # AREA (Subdirección de Negocio)
    "Ipartek_AREA_026",
    "Ipartek_AREA_090",
    
    # DEL (Delegación)
    "Ipartek_DEL_126",
    "Ipartek_DEL_142",
    
    # CT (Centro de Coste)
    "Ipartek_CT_020",
    "Ipartek_CT_024",
    "Ipartek_CT_031"
)

$tipoInforme = "contrataciones"
$anio = 2026
$mes = 5
$nroPagina = 5

Write-Host "Iniciando descarga de muestra de PDFs para 12 usuarios representativos (RLS)..." -ForegroundColor Green
Write-Host "Informe: $tipoInforme, Año: $anio, Mes: $mes" -ForegroundColor Green

$count = 0
foreach ($usuario in $usuariosPrueba) {
    $count++
    Write-Host "[$count/12] Generando PDF para: $usuario..." -ForegroundColor Cyan
    
    # Archivo temporal original que descarga el skill
    $tempPdf = Join-Path $descargasDir "${nroPagina}_${tipoInforme}_${anio}_${mes}.pdf"
    if (Test-Path $tempPdf) {
        Remove-Item $tempPdf -Force
    }
    
    # Ejecutar descargapdf
    .agents/skills/descargapdf/scripts/descargapdf.ps1 -tipoInforme $tipoInforme -anio $anio -mes $mes -usuario $usuario
    
    # Renombrar a un archivo único para este usuario
    if (Test-Path $tempPdf) {
        $finalPdf = Join-Path $descargasDir "${nroPagina}_${tipoInforme}_${anio}_${mes}_${usuario}.pdf"
        Move-Item -Path $tempPdf -Destination $finalPdf -Force
        $sizeKB = [Math]::Round((Get-Item $finalPdf).Length / 1KB, 1)
        Write-Host "  => Guardado como: $(Split-Path $finalPdf -Leaf) ($sizeKB KB)" -ForegroundColor LightGreen
    } else {
        Write-Host "  => [FALLO] No se generó el archivo temporal para $usuario" -ForegroundColor Red
    }
}

Write-Host "`nVerificación final de tamaños:" -ForegroundColor Yellow
$archivos = Get-ChildItem -Path $descargasDir -Filter "5_contrataciones_2026_5_*.pdf"
$archivos | Select-Object Name, @{Name="Tamaño (KB)"; Expression={[Math]::Round($_.Length / 1KB, 1)}} | Format-Table -AutoSize
