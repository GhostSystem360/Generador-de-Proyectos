#!/bin/bash

echo "🚀 Instalando Project Generator..."

# =========================
# VALIDAR curl
# =========================
if ! command -v curl &> /dev/null; then
  echo "❌ curl no está instalado"
  exit 1
fi

# =========================
# CREAR BIN
# =========================
mkdir -p "$HOME/bin"

# =========================
# DESCARGAR SCRIPT
# =========================
curl -fLo "$HOME/bin/project-generator" \
https://raw.githubusercontent.com/GhostSystem360/Generador-de-Proyectos/main/ProjectGenerator.sh

if [ $? -ne 0 ]; then
  echo "❌ Error descargando el script"
  exit 1
fi

# =========================
# PERMISOS
# =========================
chmod +x "$HOME/bin/projectgenerator"

# =========================
# PATH (solo si no existe)
# =========================
if ! echo "$PATH" | grep -q "$HOME/bin"; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi

# =========================
# RECARGAR (sin romper shell)
# =========================
if [ -n "$BASH_VERSION" ]; then
  source "$HOME/.bashrc"
fi

echo ""
echo "✅ Instalado correctamente"
echo "👉 Usa: project-generator NombreProyecto"