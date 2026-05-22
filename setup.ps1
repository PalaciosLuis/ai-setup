# ──────────────────────────────────────────────
# ai-setup — OpenCode + Gentle AI bootstrap
# Windows PowerShell
# ──────────────────────────────────────────────

$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HomeDir = $env:USERPROFILE
$ConfigDir = "$HomeDir\.config\opencode"

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  Configuración de asistente de desarrollo" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# ── Detectar agente ──
$Agent = "opencode"
$CursorPath = "$HomeDir\AppData\Local\Programs\Cursor\resources\app\bin"
$VSCodePath = "$HomeDir\AppData\Local\Programs\Microsoft VS Code\bin"

if (Test-Path "$CursorPath\cursor.cmd") {
    $Agent = "cursor"
    Write-Host "  Agente detectado: Cursor" -ForegroundColor Green
}
elseif (Test-Path "$VSCodePath\code.cmd") {
    $Agent = "vscode"
    Write-Host "  Agente detectado: VS Code" -ForegroundColor Green
}
else {
    Write-Host "  Agente: OpenCode (terminal)" -ForegroundColor Green
}

# ── 1. Instalar OpenCode ──
Write-Host ""
Write-Host "[1/3] Instalando OpenCode..." -ForegroundColor Yellow
try {
    $opencodeVersion = & opencode --version 2>$null
    Write-Host "  ✓ OpenCode ya está instalado ($opencodeVersion)" -ForegroundColor Green
}
catch {
    Write-Host "  Instalando via winget..." -ForegroundColor Yellow
    try {
        & winget install OpenCode 2>$null
    }
    catch {
        Write-Host "  winget no disponible, instalando via npm..." -ForegroundColor Yellow
        & npm install -g opencode
    }
    Write-Host "  ✓ OpenCode instalado" -ForegroundColor Green
}

# ── 2. Instalar Gentle AI ──
Write-Host ""
Write-Host "[2/3] Instalando Gentle AI..." -ForegroundColor Yellow
try {
    & gentle-ai --version 2>$null
    Write-Host "  ✓ Gentle AI ya está instalado" -ForegroundColor Green
}
catch {
    $TempDir = "$env:TEMP\gentle-install"
    New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
    $Installer = "$TempDir\gentle-install.exe"
    Write-Host "  Descargando instalador..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://gentle-ai.run/install-win" -OutFile $Installer
    Start-Process -FilePath $Installer -Wait
    Write-Host "  ✓ Gentle AI instalado" -ForegroundColor Green
}

# ── 3. Configurar ──
Write-Host ""
Write-Host "[3/3] Configurando..." -ForegroundColor Yellow

# Crear directorio de configuración si no existe
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

# Copiar configuración estándar
$ConfigSource = Join-Path $RepoDir "opencode.json"
if (Test-Path $ConfigSource) {
    Copy-Item -Path $ConfigSource -Destination "$ConfigDir\opencode.json" -Force
    Write-Host "  ✓ Configuración estándar copiada a $ConfigDir\opencode.json" -ForegroundColor Green
}
else {
    Write-Host "  ✗ opencode.json no encontrado en $RepoDir" -ForegroundColor Red
    exit 1
}

# Ejecutar Gentle AI install
Write-Host ""
Write-Host "  Ejecutando gentle-ai install --agent $Agent..."
try {
    & gentle-ai install --agent $Agent 2>$null
}
catch {
    Write-Host "  (gentle-ai install requiere ejecución manual adicional)" -ForegroundColor Yellow
}

# ── Mensaje final ──
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "  ¡Listo! Ya podés empezar a usar el asistente." -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""

switch ($Agent) {
    "cursor" {
        Write-Host "  • Abrí Cursor"
        Write-Host "  • En el chat escribí: /sdd-new ""lo que quieras hacer""" -ForegroundColor Cyan
    }
    "vscode" {
        Write-Host "  • Abrí VS Code"
        Write-Host "  • Abrí la paleta con Ctrl+Shift+P" -ForegroundColor Cyan
        Write-Host "  • Buscá OpenCode: Start Session" -ForegroundColor Cyan
        Write-Host "  • En el chat escribí: /sdd-new ""lo que quieras hacer""" -ForegroundColor Cyan
    }
    default {
        Write-Host "  • En la terminal ejecutá: opencode" -ForegroundColor Cyan
        Write-Host "  • Se va a abrir la interfaz interactiva"
        Write-Host "  • Escribí: /sdd-new ""lo que quieras hacer""" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "  📖  Más info: https://github.com/Gentleman-Programming/gentle-ai"
Write-Host ""
