#!/bin/bash

# Script para diagnosticar problemas de deployment
# Ejecutar en el servidor para verificar el estado

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_NAME=${1:-}
DEPLOY_PATH=${2:-/opt/apps}

if [ -z "$PROJECT_NAME" ]; then
    echo "Uso: ./debug-deployment.sh <nombre-proyecto> [ruta-deploy]"
    echo "Ejemplo: ./debug-deployment.sh mi-microservicio /opt/apps"
    exit 1
fi

echo -e "${BLUE}=== DIAGNÓSTICO DE DEPLOYMENT ===${NC}"
echo -e "${BLUE}Proyecto: $PROJECT_NAME${NC}"
echo -e "${BLUE}Ruta base: $DEPLOY_PATH${NC}"
echo ""

PROJECT_PATH="$DEPLOY_PATH/$PROJECT_NAME"

# 1. Verificar estructura de directorios
echo -e "${YELLOW}1. Verificando estructura de directorios...${NC}"
if [ -d "$DEPLOY_PATH" ]; then
    echo -e "${GREEN}OK: Directorio base existe: $DEPLOY_PATH${NC}"
    ls -la "$DEPLOY_PATH"
else
    echo -e "${RED}ERROR: Directorio base no existe: $DEPLOY_PATH${NC}"
    exit 1
fi

echo ""

if [ -d "$PROJECT_PATH" ]; then
    echo -e "${GREEN}OK: Directorio del proyecto existe: $PROJECT_PATH${NC}"
    echo "Contenido:"
    ls -la "$PROJECT_PATH"
else
    echo -e "${RED}ERROR: Directorio del proyecto no existe: $PROJECT_PATH${NC}"
    echo "Proyectos disponibles:"
    ls -la "$DEPLOY_PATH"
    exit 1
fi

echo ""

# 2. Verificar docker-compose.yml
echo -e "${YELLOW}2. Verificando docker-compose.yml...${NC}"
if [ -f "$PROJECT_PATH/docker-compose.yml" ]; then
    echo -e "${GREEN}OK: docker-compose.yml existe${NC}"
    echo "Contenido:"
    cat "$PROJECT_PATH/docker-compose.yml"
else
    echo -e "${RED}ERROR: docker-compose.yml no encontrado${NC}"
fi

echo ""

# 3. Verificar estado de contenedores
echo -e "${YELLOW}3. Verificando estado de contenedores...${NC}"
cd "$PROJECT_PATH"

if docker-compose ps 2>/dev/null; then
    echo -e "${GREEN}Estado de contenedores:${NC}"
    docker-compose ps
else
    echo -e "${RED}ERROR: No se puede obtener estado de contenedores${NC}"
fi

echo ""

# 4. Verificar logs recientes
echo -e "${YELLOW}4. Verificando logs recientes...${NC}"
if docker-compose logs --tail=20 2>/dev/null; then
    echo -e "${GREEN}Logs recientes obtenidos${NC}"
else
    echo -e "${RED}ERROR: No se pueden obtener logs${NC}"
fi

echo ""

# 5. Verificar imágenes Docker
echo -e "${YELLOW}5. Verificando imágenes Docker...${NC}"
echo "Imágenes relacionadas con $PROJECT_NAME:"
docker images | grep -i "$PROJECT_NAME" || echo "No se encontraron imágenes"

echo ""
echo "Todas las imágenes GHCR:"
docker images | grep ghcr.io || echo "No se encontraron imágenes de GHCR"

echo ""

# 6. Verificar variables de entorno
echo -e "${YELLOW}6. Verificando variables de entorno...${NC}"
if [ -f "$PROJECT_PATH/.env" ]; then
    echo -e "${GREEN}Archivo .env encontrado:${NC}"
    cat "$PROJECT_PATH/.env" | sed 's/=.*/=***/' # Ocultar valores
else
    echo -e "${YELLOW}WARNING: No se encontró archivo .env${NC}"
fi

echo ""

# 7. Verificar conectividad de red
echo -e "${YELLOW}7. Verificando conectividad...${NC}"
CONTAINER_NAME=$(docker-compose ps -q app 2>/dev/null)
if [ -n "$CONTAINER_NAME" ]; then
    echo "Probando conectividad al contenedor..."
    if docker exec "$CONTAINER_NAME" curl -f http://localhost:8080/q/health 2>/dev/null; then
        echo -e "${GREEN}OK: Aplicación responde en health check${NC}"
    else
        echo -e "${RED}ERROR: Aplicación no responde en health check${NC}"
    fi
else
    echo -e "${RED}ERROR: No se encontró contenedor activo${NC}"
fi

echo ""

# 8. Verificar puertos
echo -e "${YELLOW}8. Verificando puertos expuestos...${NC}"
if command -v netstat >/dev/null 2>&1; then
    echo "Puertos en uso:"
    netstat -tlnp | grep :8080 || echo "Puerto 8080 no está en uso"
else
    echo "netstat no disponible, usando docker-compose port:"
    docker-compose port app 8080 2>/dev/null || echo "Puerto no expuesto"
fi

echo ""

# 9. Resumen y recomendaciones
echo -e "${BLUE}=== RESUMEN Y RECOMENDACIONES ===${NC}"
echo ""

if docker-compose ps 2>/dev/null | grep -q "Up"; then
    echo -e "${GREEN}✓ El contenedor está corriendo${NC}"
    
    # Verificar si responde
    CONTAINER_NAME=$(docker-compose ps -q app 2>/dev/null)
    if [ -n "$CONTAINER_NAME" ] && docker exec "$CONTAINER_NAME" curl -f http://localhost:8080/q/health >/dev/null 2>&1; then
        echo -e "${GREEN}✓ La aplicación responde correctamente${NC}"
        echo ""
        echo "Tu aplicación está funcionando. Verifica:"
        echo "1. ¿Estás accediendo a la URL correcta?"
        echo "2. ¿El puerto está correctamente expuesto?"
        echo "3. ¿Hay un proxy/load balancer en el medio?"
    else
        echo -e "${RED}✗ La aplicación no responde${NC}"
        echo ""
        echo "Posibles problemas:"
        echo "1. La aplicación no inició correctamente"
        echo "2. Puerto incorrecto en el health check"
        echo "3. Problema de configuración"
        echo ""
        echo "Revisa los logs con:"
        echo "docker-compose logs -f"
    fi
else
    echo -e "${RED}✗ El contenedor no está corriendo${NC}"
    echo ""
    echo "Posibles problemas:"
    echo "1. Error en el docker-compose.yml"
    echo "2. Imagen no encontrada o corrupta"
    echo "3. Variables de entorno faltantes"
    echo "4. Problemas de permisos"
    echo ""
    echo "Para solucionarlo:"
    echo "1. docker-compose up -d"
    echo "2. docker-compose logs"
    echo "3. Verificar variables de entorno"
fi

echo ""
echo -e "${BLUE}=== FIN DEL DIAGNÓSTICO ===${NC}"