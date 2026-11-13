param([string]$Ghdl="ghdl",[string]$QuartusRoot="C:/altera/13.1/quartus")
$ErrorActionPreference="Continue" # Los avisos nativos de GHDL no son fallos de la prueba.
$raizPaquete=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../.."))
$trabajoSim=Join-Path $raizPaquete "simulacion_ghdl"
New-Item -ItemType Directory -Path $trabajoSim -Force -ErrorAction Stop | Out-Null
$flagsVhdl=@("--std=93","-fsynopsys","-frelaxed-rules")
Push-Location $trabajoSim
try {
    foreach($modelo in @("220pack.vhd","220model.vhd")) {
        & $Ghdl -a @flagsVhdl --work=lpm (Join-Path $QuartusRoot "eda/sim_lib/$modelo")
        if($LASTEXITCODE -ne 0){throw "Fallo de biblioteca LPM"}
    }
    foreach($fuente in Get-Content -LiteralPath (Join-Path $raizPaquete "ORDEN_COMPILACION.txt")) {
        & $Ghdl -a @flagsVhdl (Join-Path $raizPaquete $fuente)
        if($LASTEXITCODE -ne 0){throw "Fallo al analizar $fuente"}
    }
    $pruebas=Get-Content -Raw -LiteralPath (Join-Path $raizPaquete "validacion/simulaciones.json") | ConvertFrom-Json
    foreach($prueba in $pruebas) {
        $duracion="500ms"
        if($prueba -eq "SystemAlfa_Hardware_TB"){$duracion="21sec"}
        elseif($prueba.StartsWith("lector_")){$duracion="3sec"}
        $texto=& $Ghdl -r @flagsVhdl $prueba --assert-level=error "--stop-time=$duracion" 2>&1
        $codigo=$LASTEXITCODE
        $texto | Out-File -LiteralPath (Join-Path $trabajoSim "$prueba.log") -Encoding utf8
        if($codigo -ne 0 -or (($texto -join "`n") -notmatch "OK:")){throw "Prueba fallida: $prueba"}
        Write-Output "$prueba OK"
    }
} finally {Pop-Location}
