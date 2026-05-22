# ──────────────────────────────────────────────
# ai-setup — OpenCode + Gentle AI bootstrap
# Windows PowerShell
# Descarga directa de binarios (no requiere winget/npm/pnpm)
# ──────────────────────────────────────────────

$ErrorActionPreference = "Continue"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HomeDir = $env:USERPROFILE
$BinDir = "$HomeDir\.opencode\bin"
$ConfigDir = "$HomeDir\.config\opencode"

# ── Helper: descargar y extraer ZIP ──
function Download-And-Unzip {
    param($Url, $DestDir, $Name)
    $ZipFile = "$env:TEMP\$Name.zip"
    Write-Host "  Descargando $Name..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $Url -OutFile $ZipFile -ErrorAction Stop
        Write-Host "  Extrayendo..." -ForegroundColor Yellow
        Expand-Archive -Path $ZipFile -DestinationPath $DestDir -Force -ErrorAction Stop
        Remove-Item $ZipFile -Force
        return $true
    } catch {
        return $false
    }
}

# ── Helper: agregar al PATH de usuario ──
function Add-ToUserPath {
    param($PathToAdd)
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$PathToAdd*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$PathToAdd", "User")
        # Actualizar PATH de la sesion actual
        $env:Path = "$env:Path;$PathToAdd"
        return $true
    }
    return $false
}

# ═══════════════════════════════════════
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Setup de asistente de desarrollo" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ── Crear carpetas ──
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

# ── Detectar agente ──
$Agent = "opencode"
$CursorPath = "$HomeDir\AppData\Local\Programs\Cursor\resources\app\bin"
$VSCodePath = "$HomeDir\AppData\Local\Programs\Microsoft VS Code\bin"

if (Test-Path "$CursorPath\cursor.cmd") {
    $Agent = "cursor"
    Write-Host "  Agente detectado: Cursor" -ForegroundColor Green
} elseif (Test-Path "$VSCodePath\code.cmd") {
    $Agent = "vscode"
    Write-Host "  Agente detectado: VS Code" -ForegroundColor Green
} else {
    Write-Host "  Agente: OpenCode (terminal)" -ForegroundColor Green
}

# ── 1. Instalar OpenCode ──
Write-Host ""
Write-Host "[1/3] Instalando OpenCode..." -ForegroundColor Yellow
$opencode = Get-Command opencode -ErrorAction SilentlyContinue
if (-not $opencode) {
    # Buscar en nuestro bin dir
    $localOpenCode = "$BinDir\opencode.exe"
    if (-not (Test-Path $localOpenCode)) {
        $ok = Download-And-Unzip `
            "https://github.com/opencode-ai/opencode/releases/latest/download/opencode-windows-amd64.zip" `
            $BinDir "opencode"
        if (-not $ok) {
            Write-Host "  ERROR: No se pudo descargar OpenCode." -ForegroundColor Red
            Write-Host "  Descargalo manual de: https://opencode.ai/download" -ForegroundColor Yellow
        }
    }
    Add-ToUserPath $BinDir | Out-Null
    $opencode = Get-Command opencode -ErrorAction SilentlyContinue
}
if ($opencode) {
    Write-Host "  OpenCode listo" -ForegroundColor Green
} else {
    Write-Host "  OpenCode no encontrado. Instalalo manualmente." -ForegroundColor Red
}

# ── 2. Instalar Gentle AI ──
Write-Host ""
Write-Host "[2/3] Instalando Gentle AI..." -ForegroundColor Yellow
$gentle = Get-Command gentle-ai -ErrorAction SilentlyContinue
if (-not $gentle) {
    $localGentle = "$BinDir\gentle-ai.exe"
    if (-not (Test-Path $localGentle)) {
        $ok = Download-And-Unzip `
            "https://github.com/Gentleman-Programming/gentle-ai/releases/latest/download/gentle-ai-windows-amd64.zip" `
            $BinDir "gentle-ai"
        if (-not $ok) {
            Write-Host "  ERROR: No se pudo descargar Gentle AI." -ForegroundColor Red
            Write-Host "  Descargalo manual de: https://github.com/Gentleman-Programming/gentle-ai/releases" -ForegroundColor Yellow
        }
    }
    Add-ToUserPath $BinDir | Out-Null
    $gentle = Get-Command gentle-ai -ErrorAction SilentlyContinue
}
if ($gentle) {
    Write-Host "  Gentle AI listo" -ForegroundColor Green
} else {
    Write-Host "  Gentle AI no encontrado. Instalalo manualmente." -ForegroundColor Red
}

# ── 3. Configurar opencode.json ──
Write-Host ""
Write-Host "[3/3] Copiando configuracion..." -ForegroundColor Yellow

$ConfigSource = Join-Path $RepoDir "opencode.json"
if (Test-Path $ConfigSource) {
    Copy-Item -Path $ConfigSource -Destination "$ConfigDir\opencode.json" -Force
    Write-Host "  Config estandar copiada a $ConfigDir\opencode.json" -ForegroundColor Green
} else {
    Write-Host "  AVISO: opencode.json no encontrado en $RepoDir" -ForegroundColor Yellow
}

# ── 4. Ejecutar gentle-ai install ──
if ($gentle) {
    Write-Host ""
    Write-Host "  Configurando Gentle AI para $Agent..."
    try {
        & gentle-ai install --agent $Agent 2>$null
        Write-Host "  Gentle AI configurado" -ForegroundColor Green
    } catch {
        Write-Host "  Ejecuta manual: gentle-ai install --agent $Agent" -ForegroundColor Yellow
    }
}

# ── Mensaje final ──
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Instalacion completada!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  IMPORTANTE: Cerra y volve a abrir la terminal" -ForegroundColor Yellow
Write-Host "  para que el PATH se actualice." -ForegroundColor Yellow
Write-Host ""

switch ($Agent) {
    "cursor" { Write-Host "  Despues, en Cursor usa /sdd-new en el chat" -ForegroundColor Cyan }
    "vscode" { Write-Host "  Despues, en VS Code busca OpenCode: Start Session (Ctrl+Shift+P)" -ForegroundColor Cyan }
    default  { Write-Host "  Despues, en la terminal ejecuta: opencode" -ForegroundColor Cyan }
}
Write-Host ""
