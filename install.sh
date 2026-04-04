#!/bin/bash

echo "🚀 Instalando Project Generator..."

# validar curl
if ! command -v curl &> /dev/null; then
  echo "❌ curl no está instalado"
  exit 1
fi

# crear bin
mkdir -p "$HOME/bin"

# descargar script real
curl -fLo "$HOME/bin/projectgenerator" \
https://raw.githubusercontent.com/GhostSystem360/Generador-de-Proyectos/main/ProjectGenerator.sh

if [ $? -ne 0 ]; then
  echo "❌ Error descargando script"
  exit 1
fi

# permisos
chmod +x "$HOME/bin/projectgenerator"

# asegurar bashrc
[ ! -f "$HOME/.bashrc" ] && touch "$HOME/.bashrc"

# agregar PATH si no existe
grep -qxF 'export PATH="$HOME/bin:$PATH"' "$HOME/.bashrc" || \
echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"

# recargar
source "$HOME/.bashrc"

echo ""
echo "✅ Instalado correctamente"