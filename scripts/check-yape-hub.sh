#!/bin/bash

# Script específico para verificar yape-hub
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== VERIFICACIÓN YAPE-HUB ===${NC}"
echo ""

# 1. Verificar en el servidor
echo -e "${YELLOW}1. Verificando en el servidor...${NC}"
DEPLOY_PATH="/opt/apps/yape-hub"  # Ajusta si es diferente

if [ -d "$DEPLOY_PATH" ]; then
    echo -e "${GREEN}✓ Directorio existe: $DEPLOY_PATH${NC}"
    echo "Contenido:"
    ls -la "$DEPLOY_PATH"
else
    echo -e "${RED}✗ Directorio no existe: $DEPLOY_PATH${NC}"
    echo "Directorios disponibles en /opt/apps:"
    ls -la /opt/apps/ 2>/dev/null || echo "No se puede acceder a /opt/apps"
    exit 1
fi

echo ""

# 2. Verificar docker-compose.yml
echo -e "${YELLOW}2. Verificando docker-compose.yml...${NC}"
if [ -f "$DEPLOY_PATH/docker-compose.yml" ]; then
    echo -e "${GREEN}✓ docker-compose.yml existe${NC}"
    echo "Variables utilizadas:"
    grep -E '\$\{[^}]+\}' "$DEPLOY_PATH/docker-compose.yml" || echo "No se encontraron variables"
else
    echo -e "${RED}✗ docker-compose.yml NO EXISTE${NC}"
    echo "Este es probablemente el problema principal"
fi

echo ""

# 3. Verificar imagen Docker
echo -e "${YELLOW}3. Verificando imagen Docker...${NC}"
echo "Buscando imágenes de yape-hub:"
docker images | grep yape-hub || echo "No se encontraron imágenes locales"

echo ""
echo "Intentando pull manual de la imagen:"
if docker pull ghcr.io/carlosorbegoso/yape-hub:v1.0.0; then
    echo -e "${GREEN}✓ Pull manual exitoso${NC}"
else
    echo -e "${RED}✗ Pull manual falló${NC}"
    echo "Verifica:"
    echo "1. ¿La imagen existe en GHCR?"
    echo "2. ¿Tienes permisos para acceder?"
    echo "3. ¿Estás autenticado con GHCR?"
fi

echo ""

# 4. Verificar estado actual
echo -e "${YELLOW}4. Verificando estado actual...${NC}"
cd "$DEPLOY_PATH" 2>/dev/null || exit 1

if docker-compose ps 2>/dev/null; then
    echo -e "${GREEN}Estado de contenedores:${NC}"
    docker-compose ps
else
    echo -e "${RED}✗ No se puede obtener estado de contenedores${NC}"
fi

echo ""

# 5. Intentar deployment manual
echo -e "${YELLOW}5. ¿Quieres intentar deployment manual? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Configurando variables de entorno..."
    export DOCKER_IMAGE="ghcr.io/carlosorbegoso/yape-hub:v1.0.0"
    export APP_NAME="yape-hub"
    export PROJECT_NAME="yape-hub"
    
    echo "Variables configuradas:"
    echo "DOCKER_IMAGE=$DOCKER_IMAGE"
    echo "APP_NAME=$APP_NAME"
    echo "PROJECT_NAME=$PROJECT_NAME"
    
    echo ""
    echo "Intentando docker-compose pull..."
    if docker-compose pull; then
        echo -e "${GREEN}✓ Pull exitoso${NC}"
        echo ""
        echo "Intentando docker-compose up..."
        if docker-compose up -d; then
            echo -e "${GREEN}✓ Deployment manual exitoso${NC}"
            echo "Verificando estado:"
            docker-compose ps
        else
            echo -e "${RED}✗ Deployment manual falló${NC}"
            echo "Logs:"
            docker-compose logs
        fi
    else
        echo -e "${RED}✗ Pull manual falló${NC}"
        echo "Revisa el docker-compose.yml y las variables"
    fi
fi

echo ""
echo -e "${BLUE}=== FIN DE VERIFICACIÓN ===${NC}"