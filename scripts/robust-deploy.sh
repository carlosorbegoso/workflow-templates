#!/bin/bash

# Script robusto para deployment que maneja problemas de docker-compose
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOCKER_IMAGE=${DOCKER_IMAGE:-}
PROJECT_NAME=${PROJECT_NAME:-}
APP_NAME=${APP_NAME:-}
DB_USERNAME=${DB_USERNAME:-}
DB_PASSWORD=${DB_PASSWORD:-}

echo -e "${BLUE}=== ROBUST DEPLOYMENT SCRIPT ===${NC}"
echo "Docker Image: $DOCKER_IMAGE"
echo "Project: $PROJECT_NAME"
echo "App Name: $APP_NAME"
echo ""

# Verificar variables requeridas
if [ -z "$DOCKER_IMAGE" ] || [ -z "$PROJECT_NAME" ] || [ -z "$APP_NAME" ]; then
    echo -e "${RED}ERROR: Variables requeridas no configuradas${NC}"
    echo "DOCKER_IMAGE=$DOCKER_IMAGE"
    echo "PROJECT_NAME=$PROJECT_NAME"
    echo "APP_NAME=$APP_NAME"
    exit 1
fi

# Determinar comando de compose
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
    echo -e "${GREEN}Using docker compose v2${NC}"
else
    COMPOSE_CMD="docker-compose"
    echo -e "${YELLOW}Using docker-compose v1${NC}"
fi

# Limpiar estado problemático
echo -e "${YELLOW}Cleaning problematic containers...${NC}"
$COMPOSE_CMD down -v 2>/dev/null || true
docker container prune -f || true

# Eliminar contenedores específicos problemáticos
docker rm -f "${APP_NAME}" 2>/dev/null || true
docker rm -f "$(docker ps -aq --filter name=${APP_NAME})" 2>/dev/null || true

# Limpiar imágenes colgantes
docker image prune -f --filter "dangling=true" || true

echo ""
echo -e "${YELLOW}Pulling image: $DOCKER_IMAGE${NC}"
if ! docker pull "$DOCKER_IMAGE"; then
    echo -e "${RED}ERROR: Failed to pull image${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Starting services...${NC}"

# Exportar variables para docker-compose
export DOCKER_IMAGE="$DOCKER_IMAGE"
export PROJECT_NAME="$PROJECT_NAME"
export APP_NAME="$APP_NAME"
export DB_USERNAME="$DB_USERNAME"
export DB_PASSWORD="$DB_PASSWORD"

# Intentar levantar servicios
if ! $COMPOSE_CMD up -d; then
    echo -e "${RED}ERROR: Failed to start containers${NC}"
    echo ""
    echo -e "${YELLOW}Attempting recovery...${NC}"
    
    # Intentar con --force-recreate
    if ! $COMPOSE_CMD up -d --force-recreate; then
        echo -e "${RED}ERROR: Recovery failed${NC}"
        echo ""
        echo -e "${YELLOW}Logs:${NC}"
        $COMPOSE_CMD logs
        exit 1
    fi
fi

echo ""
echo -e "${YELLOW}Waiting for services to be ready...${NC}"
sleep 10

echo ""
echo -e "${YELLOW}Container status:${NC}"
$COMPOSE_CMD ps

echo ""
echo -e "${YELLOW}Recent logs:${NC}"
$COMPOSE_CMD logs --tail=20

echo ""
echo -e "${GREEN}Deployment completed successfully!${NC}"