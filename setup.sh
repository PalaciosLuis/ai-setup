#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# ai-setup — OpenCode + Gentle AI bootstrap
# Linux / macOS / Git Bash (Windows)
# ──────────────────────────────────────────────

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

# ── Detectar plataforma ──
IS_WINDOWS=false
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=true; OS="windows" ;;
  Darwin) OS="macos" ;;
  *) OS="linux" ;;
esac

# ── Detectar agente ──
detect_agent() {
  if command -v cursor &>/dev/null || [[ -d "$USERPROFILE/AppData/Local/Programs/Cursor" ]]; then
    echo "cursor"
  elif command -v code &>/dev/null || [[ -d "$USERPROFILE/AppData/Local/Programs/Microsoft VS Code" ]]; then
    echo "vscode"
  elif command -v antigravity &>/dev/null; then
    echo "antigravity"
  else
    echo "opencode"
  fi
}
AGENT=$(detect_agent)

echo -e "${CYAN}================================================${NC}"
echo -e "${CYAN}  Setup de asistente de desarrollo${NC}"
echo -e "${CYAN}================================================${NC}"
echo ""
echo -e "  Sistema: ${GREEN}${OS}${NC}"
echo -e "  Agente: ${GREEN}${AGENT}${NC}"

# ── Helper: instalar con scoop (solo Windows) ──
install_via_scoop() {
  local app="$1"   # "opencode" o "gentle-ai"
  local bucket="$2" # ej: "opencode" o "gentleman"
  local repo="$3"   # ej: "https://github.com/opencode-ai/scoop-bucket"

  if ! command -v scoop &>/dev/null; then
    return 1
  fi

  if scoop list "$app" 2>/dev/null | grep -q "$app"; then
    echo -e "  ${GREEN}OK${NC} $app ya instalado via scoop"
    return 0
  fi

  echo -e "  Instalando $app via scoop..." >&2
  scoop bucket add "$bucket" "$repo" 2>/dev/null || true
  scoop install "$app" 2>/dev/null || return 1
  return 0
}

# ── Helper: descargar binario directo (fallback) ──
download_bin() {
  local url="$1"; local dest="$2"; local name="$3"
  echo -e "  Descargando ${name} (fallback)..." >&2
  if curl -fsSL "$url" -o "$dest"; then
    echo -e "  ${GREEN}OK${NC} ${name} descargado" >&2
    return 0
  fi
  echo -e "  ${RED}ERROR${NC} No se pudo descargar ${name}" >&2
  return 1
}

# ═══════════════════════════════════════
#  1. OpenCode
# ═══════════════════════════════════════
echo ""
echo -e "${YELLOW}[1/3]${NC} Instalando OpenCode..."

if command -v opencode &>/dev/null; then
  echo -e "  ${GREEN}OK${NC} OpenCode ya esta instalado"
else
  INSTALLED=false

  if $IS_WINDOWS; then
    install_via_scoop "opencode" "opencode" "https://github.com/opencode-ai/scoop-bucket" && INSTALLED=true
  fi

  if ! $INSTALLED && [[ "$OS" == "macos" ]] && command -v brew &>/dev/null; then
    brew install opencode-ai/tap/opencode && INSTALLED=true
  fi

  if ! $INSTALLED; then
    if $IS_WINDOWS; then
      # Fallback: descargar binario directo
      BIN_DIR="$USERPROFILE/.opencode/bin"
      mkdir -p "$BIN_DIR"
      ZIP="$BIN_DIR/opencode.zip"
      download_bin "https://github.com/opencode-ai/opencode/releases/latest/download/opencode-windows-amd64.zip" "$ZIP" "OpenCode"
      unzip -o "$ZIP" -d "$BIN_DIR" 2>/dev/null && rm -f "$ZIP"
      WIN_PATH="$(cygpath -w "$BIN_DIR")"
      powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path','User') + ';$WIN_PATH', 'User')" 2>/dev/null || true
      export PATH="$PATH:$BIN_DIR"
      INSTALLED=true
    else
      curl -fsSL https://opencode.ai/install | bash 2>/dev/null || true
      command -v opencode &>/dev/null && INSTALLED=true
    fi
  fi

  if $INSTALLED; then
    echo -e "  ${GREEN}OK${NC} OpenCode instalado"
  else
    echo -e "  ${YELLOW}AVISO${NC} OpenCode no encontrado todavia."
  fi
fi

# ═══════════════════════════════════════
#  2. Gentle AI
# ═══════════════════════════════════════
echo ""
echo -e "${YELLOW}[2/3]${NC} Instalando Gentle AI..."

if command -v gentle-ai &>/dev/null; then
  echo -e "  ${GREEN}OK${NC} Gentle AI ya esta instalado"
else
  INSTALLED=false

  if $IS_WINDOWS; then
    install_via_scoop "gentle-ai" "gentleman" "https://github.com/Gentleman-Programming/scoop-bucket" && INSTALLED=true
  fi

  if ! $INSTALLED; then
    if $IS_WINDOWS; then
      BIN_DIR="${BIN_DIR:-$USERPROFILE/.opencode/bin}"
      mkdir -p "$BIN_DIR"
      ZIP="$BIN_DIR/gentle-ai.zip"
      download_bin "https://github.com/Gentleman-Programming/gentle-ai/releases/latest/download/gentle-ai-windows-amd64.zip" "$ZIP" "Gentle AI"
      unzip -o "$ZIP" -d "$BIN_DIR" 2>/dev/null && rm -f "$ZIP"
      WIN_PATH="$(cygpath -w "$BIN_DIR")"
      powershell -Command "[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path','User') + ';$WIN_PATH', 'User')" 2>/dev/null || true
      export PATH="$PATH:$BIN_DIR"
      INSTALLED=true
    else
      curl -fsSL https://gentle-ai.run/install | bash 2>/dev/null || true
      command -v gentle-ai &>/dev/null && INSTALLED=true
    fi
  fi

  if $INSTALLED; then
    echo -e "  ${GREEN}OK${NC} Gentle AI instalado"
  else
    echo -e "  ${YELLOW}AVISO${NC} Gentle AI no encontrado todavia."
  fi
fi

# ═══════════════════════════════════════
#  3. Configurar
# ═══════════════════════════════════════
echo ""
echo -e "${YELLOW}[3/3]${NC} Configurando..."

if $IS_WINDOWS; then
  CONFIG_DIR="$USERPROFILE/.config/opencode"
else
  CONFIG_DIR="$HOME/.config/opencode"
fi
mkdir -p "$CONFIG_DIR"

if [[ -f "$REPO_DIR/opencode.json" ]]; then
  cp "$REPO_DIR/opencode.json" "$CONFIG_DIR/opencode.json"
  echo -e "  ${GREEN}OK${NC} Config copiada a ${CONFIG_DIR}/opencode.json"
else
  echo -e "  ${RED}ERROR${NC} opencode.json no encontrado en $REPO_DIR"
  exit 1
fi

# ── 4. Gentle AI install ──
if command -v gentle-ai &>/dev/null; then
  echo ""
  echo -e "  Ejecutando gentle-ai install --agent ${AGENT}..."
  gentle-ai install --agent "$AGENT" 2>/dev/null || true
fi

# ── Mensaje final ──
echo ""
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}  Instalacion completada!${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

if $IS_WINDOWS; then
  echo -e "  ${YELLOW}IMPORTANTE: Cerra y volve a abrir la terminal${NC}"
  echo -e "  para que el PATH se actualice."
  echo ""
fi

case "$AGENT" in
  cursor) echo -e "  En Cursor, usa ${CYAN}/sdd-new${NC} en el chat" ;;
  vscode) echo -e "  En VS Code, busca ${CYAN}OpenCode: Start Session${NC} (Ctrl+Shift+P)" ;;
  antigravity) echo -e "  En Antigravity, usa lenguaje natural: ${CYAN}quiero hacer X con SDD${NC}" ;;
  opencode) echo -e "  En la terminal ejecuta: ${CYAN}opencode${NC}" ;;
esac
echo ""
echo -e "  Mas info: https://github.com/Gentleman-Programming/gentle-ai"
echo ""
