#!/bin/bash

# Script para verificar imágenes disponibles en GHCR
# Uso: ./check-ghcr-images.sh [project-name] [owner]

PROJECT_NAME=${1:-yape-hub}
OWNER=${2:-carlosorbegoso}

echo "=== Verificando imágenes en GHCR ==="
echo "Proyecto: $PROJECT_NAME"
echo "Owner: $OWNER"
echo "Registry: ghcr.io"
echo ""

# Verificar si Docker está disponible
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker no está instalado o no está en el PATH"
    exit 1
fi

# Autenticarse con GHCR si hay credenciales en variables de entorno
if [ -n "$GHCR_PAT" ] && [ -n "$GHCR_USERNAME" ]; then
    echo "🔐 Autenticando con GHCR usando variables de entorno..."
    echo "$GHCR_PAT" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin
elif [ -n "$GITHUB_TOKEN" ]; then
    echo "🔐 Autenticando con GHCR usando GITHUB_TOKEN..."
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$USER" --password-stdin
else
    echo "⚠️  No se encontraron credenciales de GHCR"
    echo "   Puedes exportar GHCR_USERNAME y GHCR_PAT para autenticarte"
    echo "   O usar GITHUB_TOKEN si tienes permisos"
fi

# Tags comunes a verificar
COMMON_TAGS=(
    "latest"
    "main"
    "v1.0.0"
    "v0.0.1"
)

# Obtener hash actual si estamos en un repo git
if git rev-parse --git-dir > /dev/null 2>&1; then
    SHORT_HASH=$(git rev-parse --short HEAD)
    BRANCH=$(git branch --show-current)
    COMMON_TAGS+=("main-${SHORT_HASH}" "${BRANCH}-${SHORT_HASH}")
fi

echo "Verificando tags comunes:"
for tag in "${COMMON_TAGS[@]}"; do
    IMAGE="ghcr.io/${OWNER}/${PROJECT_NAME}:${tag}"
    echo -n "Checking $IMAGE ... "
    
    if docker manifest inspect "$IMAGE" >/dev/null 2>&1; then
        echo "✅ EXISTS"
        
        # Obtener información adicional
        SIZE=$(docker manifest inspect "$IMAGE" | jq -r '.config.size // "unknown"' 2>/dev/null || echo "unknown")
        echo "   Size: $SIZE bytes"
    else
        echo "❌ NOT FOUND"
    fi
done

echo ""
echo "=== Imágenes locales relacionadas ==="
docker images | grep "$PROJECT_NAME" || echo "No hay imágenes locales"

echo ""
echo "=== Recomendaciones ==="
echo "1. Si no hay imágenes, ejecuta el workflow de build primero"
echo "2. Verifica que GHCR_USERNAME y GHCR_PAT estén configurados"
echo "3. Asegúrate de que el repositorio tenga permisos para packages"
echo "4. Usa el tag que aparece como ✅ EXISTS en tu docker-compose.yml"