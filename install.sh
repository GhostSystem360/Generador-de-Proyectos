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
# DESCARGAR SCRIPT REAL
# =========================
curl -fLo "$HOME/bin/projectgenerator" \
https://raw.githubusercontent.com/GhostSystem360/Generador-de-Proyectos/main/ProjectGenerator.sh

if [ $? -ne 0 ]; then
  echo "❌ Error descargando ProjectGenerator.sh"
  exit 1
fi

# =========================
# PERMISOS
# =========================
chmod +x "$HOME/bin/projectgenerator"

# =========================
# AGREGAR AL PATH
# =========================
if ! echo "$PATH" | grep -q "$HOME/bin"; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi

# =========================
# RECARGAR SHELL
# =========================
source "$HOME/.bashrc"

echo ""
echo "✅ Instalado correctamente"
echo "👉 Usa: projectgenerator NombreProyecto"