#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOCKER_IMAGE=${DOCKER_IMAGE:-}
PROJECT_NAME=${PROJECT_NAME:-$(basename ${DEPLOY_PATH:-$(pwd)})}
DEPLOY_PATH=${DEPLOY_PATH:-$(pwd)}

echo -e "${BLUE}=== Deploy Script Started ===${NC}"
echo -e "${BLUE}Docker Image: ${DOCKER_IMAGE}${NC}"
echo -e "${BLUE}Project Name: ${PROJECT_NAME}${NC}"
echo -e "${BLUE}Deploy Path: ${DEPLOY_PATH}${NC}"

if [ -z "$DOCKER_IMAGE" ]; then
  echo -e "${RED}❌ Error: DOCKER_IMAGE no definida${NC}"
  echo -e "${YELLOW}Uso: DOCKER_IMAGE=imagen:tag PROJECT_NAME=nombre ./deploy.sh${NC}"
  exit 1
fi

if [ ! -d "$DEPLOY_PATH" ]; then
  echo -e "${RED}❌ Error: DEPLOY_PATH no existe: $DEPLOY_PATH${NC}"
  exit 1
fi

cd "$DEPLOY_PATH"

if [ ! -f "docker-compose.yml" ]; then
  echo -e "${RED}❌ Error: docker-compose.yml no encontrado en $DEPLOY_PATH${NC}"
  echo -e "${YELLOW}💡 Crea un docker-compose.yml basado en docker-compose.example.yml${NC}"
  exit 1
fi

# Exportar variables para docker-compose
export DOCKER_IMAGE="$DOCKER_IMAGE"
export PROJECT_NAME="$PROJECT_NAME"
export COMPOSE_PROJECT_NAME="$PROJECT_NAME"

echo -e "${YELLOW}📥 Descargando imagen: $DOCKER_IMAGE${NC}"
if ! docker pull "$DOCKER_IMAGE"; then
  echo -e "${RED}❌ Error: No se pudo descargar la imagen $DOCKER_IMAGE${NC}"
  echo -e "${YELLOW}💡 Verifica que la imagen existe y tienes permisos${NC}"
  exit 1
fi

echo -e "${YELLOW}🛑 Deteniendo contenedor anterior...${NC}"
docker-compose down || true

echo -e "${YELLOW}🚀 Iniciando nuevo contenedor...${NC}"
if ! docker-compose up -d; then
  echo -e "${RED}❌ Error: No se pudo iniciar el contenedor${NC}"
  echo -e "${YELLOW}📋 Logs del contenedor:${NC}"
  docker-compose logs
  exit 1
fi

echo -e "${YELLOW}⏳ Esperando que el contenedor esté listo...${NC}"
sleep 10

echo -e "${YELLOW}🔍 Verificando estado...${NC}"
if docker-compose ps | grep -q "Up"; then
  echo -e "${GREEN}✅ $PROJECT_NAME deployado correctamente${NC}"
  
  # Mostrar información del contenedor
  echo -e "${BLUE}📊 Estado del contenedor:${NC}"
  docker-compose ps
  
  # Mostrar puertos expuestos
  echo -e "${BLUE}🌐 Puertos expuestos:${NC}"
  docker-compose port app 8080 2>/dev/null || echo "Puerto 8080 no expuesto"
  
else
  echo -e "${RED}❌ Error: $PROJECT_NAME no está corriendo${NC}"
  echo -e "${YELLOW}📋 Logs del contenedor:${NC}"
  docker-compose logs
  exit 1
fi

echo -e "${YELLOW}🧹 Limpiando imágenes no utilizadas...${NC}"
docker image prune -f --filter "dangling=true" || true

echo -e "${GREEN}🎉 Deploy completado exitosamente${NC}"
echo -e "${BLUE}=== Deploy Script Finished ===${NC}"