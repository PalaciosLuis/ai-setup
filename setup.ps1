# ──────────────────────────────────────────────
# ai-setup — OpenCode + Gentle AI bootstrap
# Windows PowerShell
# ──────────────────────────────────────────────

$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HomeDir = $env:USERPROFILE
$ConfigDir = "$HomeDir\.config\opencode"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Configuracion de asistente de desarrollo" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

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
if ($opencode) {
    Write-Host "  OpenCode ya esta instalado" -ForegroundColor Green
} else {
    Write-Host "  Instalando via winget..." -ForegroundColor Yellow
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        & winget install OpenCode --silent 2>$null
    } else {
        Write-Host "  Instalando via npm..." -ForegroundColor Yellow
        & npm install -g opencode
    }
    Write-Host "  OpenCode instalado" -ForegroundColor Green
}

# ── 2. Instalar Gentle AI ──
Write-Host ""
Write-Host "[2/3] Instalando Gentle AI..." -ForegroundColor Yellow
$gentle = Get-Command gentle-ai -ErrorAction SilentlyContinue
if ($gentle) {
    Write-Host "  Gentle AI ya esta instalado" -ForegroundColor Green
} else {
    $TempDir = "$env:TEMP\gentle-install"
    New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
    $Installer = "$TempDir\gentle-install.exe"
    Write-Host "  Descargando instalador..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://gentle-ai.run/install-win" -OutFile $Installer -ErrorAction Stop
        Start-Process -FilePath $Installer -Wait
        Write-Host "  Gentle AI instalado" -ForegroundColor Green
    } catch {
        Write-Host "  No se pudo descargar Gentle AI. Hacelo manual desde https://github.com/Gentleman-Programming/gentle-ai" -ForegroundColor Red
    }
}

# ── 3. Configurar ──
Write-Host ""
Write-Host "[3/3] Configurando..." -ForegroundColor Yellow

New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

$ConfigSource = Join-Path $RepoDir "opencode.json"
if (Test-Path $ConfigSource) {
    Copy-Item -Path $ConfigSource -Destination "$ConfigDir\opencode.json" -Force
    Write-Host "  Configuracion copiada a $ConfigDir\opencode.json" -ForegroundColor Green
} else {
    Write-Host "  ERROR: opencode.json no encontrado en $RepoDir" -ForegroundColor Red
    exit 1
}

# ── 4. Gentle AI install ──
Write-Host ""
Write-Host "  Ejecutando gentle-ai install --agent $Agent..."
try {
    & gentle-ai install --agent $Agent 2>$null
} catch {
    Write-Host "  (gentle-ai install se puede ejecutar manual despues)" -ForegroundColor Yellow
}

# ── Mensaje final ──
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Listo! Ya podes empezar a usar el asistente." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

switch ($Agent) {
    "cursor" {
        Write-Host "  - Abri Cursor"
        Write-Host "  - En el chat escribi: /sdd-new ""lo que quieras hacer""" -ForegroundColor Cyan
    }
    "vscode" {
        Write-Host "  - Abri VS Code"
        Write-Host "  - Abri la paleta con Ctrl+Shift+P" -ForegroundColor Cyan
        Write-Host "  - Busca OpenCode: Start Session" -ForegroundColor Cyan
        Write-Host "  - En el chat escribi: /sdd-new ""lo que quieras hacer""" -ForegroundColor Cyan
    }
    default {
        Write-Host "  - En la terminal ejecuta: opencode" -ForegroundColor Cyan
        Write-Host "  - En el chat escribi: /sdd-new ""lo que quieras hacer""" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "  Mas info: https://github.com/Gentleman-Programming/gentle-ai"
Write-Host ""
