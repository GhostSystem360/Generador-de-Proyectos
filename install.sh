#!/bin/bash

echo "🚀 Instalando Project Generator..."

# =========================
# VALIDAR CURL
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
# DESCARGAR GENERADOR REAL
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
# ASEGURAR .bashrc
# =========================
if [ ! -f "$HOME/.bashrc" ]; then
  echo "📁 Creando .bashrc..."
  touch "$HOME/.bashrc"
fi

# =========================
# AGREGAR PATH (SI NO EXISTE)
# =========================
if ! grep -q 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc"; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi

# =========================
# RECARGAR
# =========================
source "$HOME/.bashrc"

echo ""
echo "✅ Instalado correctamente"
echo "👉 Reinicia la terminal o ejecuta: source ~/.bashrc"
echo "👉 Usa: projectgenerator NombreProyecto"