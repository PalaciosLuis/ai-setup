# ──────────────────────────────────────────────
# ai-setup — OpenCode + Gentle AI bootstrap
# Windows PowerShell
# ──────────────────────────────────────────────

$ErrorActionPreference = "Continue"
$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HomeDir = $env:USERPROFILE
$ConfigDir = "$HomeDir\.config\opencode"

# ── Helper: instalar OpenCode ──
function Install-OpenCode {
    # 1. winget
    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        Write-Host "  Intentando con winget..." -ForegroundColor Yellow
        try {
            & winget install OpenCode --silent --accept-package-agreements 2>$null
            if ($LASTEXITCODE -eq 0) { return $true }
        } catch { }
    }

    # 2. pnpm
    $pnpm = Get-Command pnpm -ErrorAction SilentlyContinue
    if ($pnpm) {
        Write-Host "  Intentando con pnpm..." -ForegroundColor Yellow
        try {
            & pnpm add -g opencode 2>$null
            if ($LASTEXITCODE -eq 0) { return $true }
        } catch { }
    }

    # 3. npm
    $npm = Get-Command npm -ErrorAction SilentlyContinue
    if ($npm) {
        Write-Host "  Intentando con npm..." -ForegroundColor Yellow
        try {
            & npm install -g opencode 2>$null
            if ($LASTEXITCODE -eq 0) { return $true }
        } catch { }
    }

    # 4. Scoop
    $scoop = Get-Command scoop -ErrorAction SilentlyContinue
    if ($scoop) {
        Write-Host "  Intentando con scoop..." -ForegroundColor Yellow
        try {
            & scoop bucket add opencode https://github.com/opencode-ai/scoop-bucket 2>$null
            & scoop install opencode 2>$null
            if ($LASTEXITCODE -eq 0) { return $true }
        } catch { }
    }

    return $false
}

# ── Helper: instalar Gentle AI ──
function Install-GentleAI {
    $TempDir = "$env:TEMP\gentle-install"
    New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
    $Installer = "$TempDir\gentle-install.exe"
    Write-Host "  Descargando instalador de Gentle AI..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://gentle-ai.run/install-win" -OutFile $Installer -ErrorAction Stop
        Start-Process -FilePath $Installer -Wait
        return $true
    } catch {
        return $false
    }
}

# ═══════════════════════════════════════
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Setup de asistente de desarrollo" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# ── 0. Detectar agente ──
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
    $ok = Install-OpenCode
    $opencode = Get-Command opencode -ErrorAction SilentlyContinue
    if ($opencode) {
        Write-Host "  OpenCode instalado correctamente" -ForegroundColor Green
    } else {
        Write-Host "  No se pudo instalar OpenCode automaticamente." -ForegroundColor Red
        Write-Host "  Descargalo manual desde: https://opencode.ai/download" -ForegroundColor Yellow
        Write-Host "  O ejecuta: npm install -g opencode" -ForegroundColor Yellow
    }
}

# ── 2. Instalar Gentle AI ──
Write-Host ""
Write-Host "[2/3] Instalando Gentle AI..." -ForegroundColor Yellow
$gentle = Get-Command gentle-ai -ErrorAction SilentlyContinue
if ($gentle) {
    Write-Host "  Gentle AI ya esta instalado" -ForegroundColor Green
} else {
    $ok = Install-GentleAI
    $gentle = Get-Command gentle-ai -ErrorAction SilentlyContinue
    if ($gentle) {
        Write-Host "  Gentle AI instalado correctamente" -ForegroundColor Green
    } else {
        Write-Host "  No se pudo instalar Gentle AI." -ForegroundColor Red
        Write-Host "  Hacelo manual desde: https://github.com/Gentleman-Programming/gentle-ai/releases" -ForegroundColor Yellow
    }
}

# ── 3. Configurar ──
Write-Host ""
Write-Host "[3/3] Configurando..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null

$ConfigSource = Join-Path $RepoDir "opencode.json"
if (Test-Path $ConfigSource) {
    Copy-Item -Path $ConfigSource -Destination "$ConfigDir\opencode.json" -Force
    Write-Host "  Config estandar copiada a $ConfigDir\opencode.json" -ForegroundColor Green
} else {
    Write-Host "  AVISO: opencode.json no encontrado en $RepoDir" -ForegroundColor Yellow
    Write-Host "  Podes copiarlo manualmente cuando lo tengas." -ForegroundColor Yellow
}

# ── 4. Gentle AI install ──
if ($gentle) {
    Write-Host ""
    Write-Host "  Configurando Gentle AI para $Agent..."
    try {
        & gentle-ai install --agent $Agent 2>$null
    } catch {
        Write-Host "  (ejecuta 'gentle-ai install --agent $Agent' manualmente si hace falta)" -ForegroundColor Yellow
    }
}

# ── Mensaje final ──
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  Listo!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

switch ($Agent) {
    "cursor" { Write-Host "  En Cursor, usa /sdd-new en el chat" -ForegroundColor Cyan }
    "vscode" { Write-Host "  En VS Code, abri la paleta (Ctrl+Shift+P) y busca OpenCode: Start Session" -ForegroundColor Cyan }
    default  { Write-Host "  En la terminal ejecuta: opencode" -ForegroundColor Cyan }
}
Write-Host ""
Write-Host "  Mas info: https://github.com/Gentleman-Programming/gentle-ai"
Write-Host ""
