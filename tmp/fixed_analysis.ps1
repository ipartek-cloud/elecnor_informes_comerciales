param (
    [string]$DatabasePath = "C:\TrabajoVBNet\Elecnor\elecnor_informes_comerciales\Access\Comision_Ejecutiva_Consejo.accdb",
    [string]$ReportName   = "Sub_Ventas2021",
    [string]$OutputPath   = "C:\TrabajoVBNet\Elecnor\elecnor_informes_comerciales\tmp\Sub_Ventas2021.json"
)

function SafeGet($block) {
    try { return & $block } catch { return $null }
}

$sectionNameMap = @{
    0 = "Detalle"; 1 = "EncabezadoInforme"; 2 = "PieInforme"
    3 = "EncabezadoPagina"; 4 = "PiePagina"
}

$access = $null
try {
    Write-Host "Iniciando Automatización de Access..."
    $access = New-Object -ComObject "Access.Application"
    $access.Visible = $false
    $access.AutomationSecurity = 1
    $access.OpenCurrentDatabase($DatabasePath, $true)

    # 1. ANALISIS DEL DISEÑO DEL INFORME
    # ==================================
    $access.DoCmd.OpenReport($ReportName, 1) # acDesign
    $rpt = $access.Reports.Item($ReportName)

    $recordSource = SafeGet { $rpt.RecordSource }
    $orderBy      = SafeGet { $rpt.OrderBy }
    $filterStr    = SafeGet { $rpt.Filter }

    # Niveles de Agrupación (FIXED: Iterar hasta que falle)
    $groupLevels = @()
    for ($i = 0; $i -lt 10; $i++) {
        try {
            $gl = $rpt.GroupLevel($i)
            $groupLevels += [PSCustomObject]@{
                Index         = $i
                ControlSource = (SafeGet { $gl.ControlSource })
                SortOrder     = (SafeGet { if ($gl.SortOrder -eq 0) { "ASC" } else { "DESC" } })
            }
        } catch {
            break
        }
    }

    # Secciones y Controles
    $sections = @()
    for ($sIdx = 0; $sIdx -le 25; $sIdx++) {
        $sec = $null
        try { $sec = $rpt.Section($sIdx) } catch { continue }
        if (-not $sec) { continue }

        $secLabel = if ($sectionNameMap.ContainsKey($sIdx)) {
            $sectionNameMap[$sIdx]
        } elseif (($sIdx % 2) -eq 1) {
            "EncabezadoGrupo$(( ($sIdx - 5) / 2 ))"
        } else {
            "PieGrupo$(( ($sIdx - 6) / 2 ))"
        }

        $controls = @()
        $ctrlCount = 0
        try { $ctrlCount = $sec.Controls.Count } catch {}
        if ($ctrlCount) {
            for ($cIdx = 0; $cIdx -lt $ctrlCount; $cIdx++) {
                $ctrl = $null
                try { $ctrl = $sec.Controls.Item($cIdx) } catch { continue }
                if (-not $ctrl) { continue }

                $controls += [PSCustomObject]@{
                    Name          = (SafeGet { $ctrl.Name })
                    ControlType   = (SafeGet { $ctrl.ControlType })
                    ControlSource = (SafeGet { $ctrl.ControlSource })
                    Caption       = (SafeGet { $ctrl.Caption })
                    Format        = (SafeGet { $ctrl.Format })
                    Left          = (SafeGet { $ctrl.Left })
                    Top           = (SafeGet { $ctrl.Top })
                    Width         = (SafeGet { $ctrl.Width })
                    Height        = (SafeGet { $ctrl.Height })
                    TextAlign     = (SafeGet { $ctrl.TextAlign })
                    FontBold      = (SafeGet { $ctrl.FontBold })
                    FontItalic    = (SafeGet { $ctrl.FontItalic })
                    FontUnderline = (SafeGet { $ctrl.FontUnderline })
                    FontSize      = (SafeGet { $ctrl.FontSize })
                    FontName      = (SafeGet { $ctrl.FontName })
                    ForeColor     = (SafeGet { $ctrl.ForeColor })
                    BackColor     = (SafeGet { $ctrl.BackColor })
                    Visible       = (SafeGet { $ctrl.Visible })
                    HideDuplicates= (SafeGet { $ctrl.HideDuplicates })
                    SourceObject     = (SafeGet { $ctrl.SourceObject })
                    LinkMasterFields = (SafeGet { $ctrl.LinkMasterFields })
                    LinkChildFields  = (SafeGet { $ctrl.LinkChildFields })
                    RunningSum    = (SafeGet { $ctrl.RunningSum })
                }
            }
        }

        $sections += [PSCustomObject]@{
            Label    = $secLabel
            Controls = $controls
        }
    }
    $access.DoCmd.Close(3, $ReportName)

    # 2. ANALISIS DE LA SQL (RECORDSOURCE)
    # ===================================
    $sqlDef = ""
    if ($recordSource) {
        try {
            $db = $access.CurrentDb()
            $qdf = $db.QueryDefs.Item($recordSource)
            $sqlDef = $qdf.SQL
        } catch {
             # Si es una SQL directa en lugar de una consulta guardada
             $sqlDef = $recordSource
        }
    }

    # 3. ANALISIS DEL CODIGO VBA
    # ==========================
    $vbaComps = @()
    try {
        $vbe = $access.VBE
        $project = $vbe.ActiveVBProject
        foreach ($comp in $project.VBComponents) {
            $lines = $comp.CodeModule.CountOfLines
            if ($lines -gt 0) {
                $content = $comp.CodeModule.Lines(1, $lines)
                $vbaComps += [PSCustomObject]@{
                    Name    = $comp.Name
                    Content = $content
                }
            }
        }
    } catch {}

    # ENSAMBLAR RESULTADO
    $result = [PSCustomObject]@{
        ReportInfo   = [PSCustomObject]@{
            Name         = $ReportName
            RecordSource = $recordSource
            SQL          = $sqlDef
            OrderBy      = $orderBy
            Filter       = $filterStr
            GroupLevels  = $groupLevels
        }
        Design       = $sections
        VBA          = $vbaComps
    }

    $result | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding utf8
    Write-Host "Analisis completado exitosamente."

} catch {
    Write-Error $_.Exception.Message
} finally {
    if ($access) {
        try { $access.CloseCurrentDatabase() } catch {}
        try { $access.Quit() } catch {}
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($access) | Out-Null
    }
}
