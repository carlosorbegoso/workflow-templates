#!/bin/bash
set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOCKER_IMAGE=${DOCKER_IMAGE:-}
APP_NAME=$(basename $DEPLOY_PATH)

if [ -z "$DOCKER_IMAGE" ]; then
  echo -e "${RED}❌ Error: DOCKER_IMAGE no definida${NC}"
  exit 1
fi

cd ${DEPLOY_PATH:-.}

echo -e "${YELLOW}📥 Descargando imagen: $DOCKER_IMAGE${NC}"
docker pull $DOCKER_IMAGE

echo -e "${YELLOW}🛑 Deteniendo contenedor anterior...${NC}"
docker-compose down || true

echo -e "${YELLOW}🚀 Iniciando nuevo contenedor...${NC}"
docker-compose up -d

# Verificar que está corriendo
echo -e "${YELLOW}⏳ Verificando estado...${NC}"
sleep 5

if docker-compose ps | grep -q "Up"; then
  echo -e "${GREEN}✅ $APP_NAME deployado correctamente${NC}"
else
  echo -e "${RED}❌ Error: $APP_NAME no está corriendo${NC}"
  docker-compose logs
  exit 1
fi

# Limpiar imágenes antiguas
docker image prune -f --filter "dangling=true" || true

echo -e "${GREEN}✅ Deploy completado exitosamente${NC}"