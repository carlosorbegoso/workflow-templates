#!/bin/bash

# Script to check available images on GHCR
# Usage: ./check-ghcr-images.sh [project-name] [owner]

PROJECT_NAME=${1:-yape-hub}
OWNER=${2:-carlosorbegoso}

echo "=== Checking images on GHCR ==="
echo "Project: $PROJECT_NAME"
echo "Owner: $OWNER"
echo "Registry: ghcr.io"
echo ""

# Verificar si Docker está disponible
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not on PATH"
    exit 1
fi

# Autenticarse con GHCR si hay credenciales en variables de entorno
if [ -n "$GHCR_PAT" ] && [ -n "$GHCR_USERNAME" ]; then
    echo "🔐 Authenticating with GHCR using environment variables..."
    echo "$GHCR_PAT" | docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin
elif [ -n "$GITHUB_TOKEN" ]; then
    echo "🔐 Authenticating with GHCR using GITHUB_TOKEN..."
    echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$USER" --password-stdin
else
    echo "⚠️  No GHCR credentials found"
    echo "   You can export GHCR_USERNAME and GHCR_PAT to authenticate"
    echo "   Or use GITHUB_TOKEN if you have permissions"
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

echo "Checking common tags:"
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
echo "=== Related local images ==="
docker images | grep "$PROJECT_NAME" || echo "No local images found"

echo ""
echo "=== Recommendations ==="
echo "1. If no images are found, run the build workflow first"
echo "2. Ensure GHCR_USERNAME and GHCR_PAT are set"
echo "3. Ensure the repository has permission to access packages"
echo "4. Use the tag marked as ✅ EXISTS in your docker-compose.yml"