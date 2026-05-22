#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# ai-setup — OpenCode + Gentle AI bootstrap
# Linux / macOS
# ──────────────────────────────────────────────

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Configuración de asistente de desarrollo${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ── Detectar OS ──
OS="linux"
if [[ "$(uname)" == "Darwin" ]]; then
  OS="macos"
fi
echo -e "  Sistema: ${GREEN}${OS}${NC}"

# ── Detectar agente ──
AGENT="opencode"
if command -v cursor &>/dev/null; then
  AGENT="cursor"
  echo -e "  Agente detectado: ${GREEN}Cursor${NC}"
elif command -v code &>/dev/null && [[ -d "$HOME/.vscode" || -d "$HOME/.vscode-server" ]]; then
  AGENT="vscode"
  echo -e "  Agente detectado: ${GREEN}VS Code${NC}"
elif command -v antigravity &>/dev/null; then
  AGENT="antigravity"
  echo -e "  Agente detectado: ${GREEN}Antigravity${NC}"
else
  echo -e "  Agente: ${GREEN}OpenCode (terminal)${NC}"
fi

# ── 1. Instalar OpenCode ──
echo ""
echo -e "${YELLOW}[1/3]${NC} Instalando OpenCode..."
if command -v opencode &>/dev/null; then
  echo -e "  ${GREEN}✓${NC} OpenCode ya está instalado ($(opencode --version 2>/dev/null || echo "?"))"
else
  if [[ "$OS" == "macos" ]] && command -v brew &>/dev/null; then
    brew install opencode-ai/tap/opencode
  else
    curl -fsSL https://opencode.ai/install | bash
  fi
  echo -e "  ${GREEN}✓${NC} OpenCode instalado"
fi

# ── 2. Instalar Gentle AI ──
echo ""
echo -e "${YELLOW}[2/3]${NC} Instalando Gentle AI..."
if command -v gentle-ai &>/dev/null; then
  echo -e "  ${GREEN}✓${NC} Gentle AI ya está instalado"
else
  curl -fsSL https://gentle-ai.run/install | bash
  echo -e "  ${GREEN}✓${NC} Gentle AI instalado"
fi

# ── 3. Configurar ──
echo ""
echo -e "${YELLOW}[3/3]${NC} Configurando..."

# Crear directorio de configuración si no existe
mkdir -p "$HOME/.config/opencode"

# Copiar configuración estándar
if [[ -f "$REPO_DIR/opencode.json" ]]; then
  cp "$REPO_DIR/opencode.json" "$HOME/.config/opencode/opencode.json"
  echo -e "  ${GREEN}✓${NC} Configuración estándar copiada a ~/.config/opencode/opencode.json"
else
  echo -e "  ${RED}✗${NC} opencode.json no encontrado en $REPO_DIR"
  exit 1
fi

# Ejecutar Gentle AI install para el agente detectado
echo ""
echo -e "  Ejecutando gentle-ai install --agent ${AGENT}..."
gentle-ai install --agent "$AGENT" 2>/dev/null || true

# ── Mensaje final ──
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ¡Listo! Ya podés empezar a usar el asistente.${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Para empezar:"
echo ""
case "$AGENT" in
  cursor)
    echo -e "    • Abrí ${CYAN}Cursor${NC}"
    echo -e "    • En el chat escribí:${CYAN} /sdd-new \"lo que quieras hacer\"${NC}"
    echo -e "    • También directamente:${CYAN} haz X${NC} (sin SDD si es chico)"
    ;;
  vscode)
    echo -e "    • Abrí ${CYAN}VS Code${NC}"
    echo -e "    • Abrí la paleta con ${CYAN}Ctrl+Shift+P${NC}"
    echo -e "    • Buscá ${CYAN}OpenCode: Start Session${NC}"
    echo -e "    • En el chat escribí:${CYAN} /sdd-new \"lo que quieras hacer\"${NC}"
    ;;
  antigravity)
    echo -e "    • Abrí ${CYAN}Antigravity${NC}"
    echo -e "    • En el chat escribí:${CYAN} /sdd-new \"lo que quieras hacer\"${NC}"
    echo -e "    • O simplemente describí qué necesitás en lenguaje natural"
    ;;
  opencode)
    echo -e "    • En la terminal ejecutá:${CYAN} opencode${NC}"
    echo -e "    • Se va a abrir la interfaz interactiva"
    echo -e "    • Escribí:${CYAN} /sdd-new \"lo que quieras hacer\"${NC}"
    ;;
esac
echo ""
echo -e "  📖  Más info: https://github.com/Gentleman-Programming/gentle-ai"
echo ""
