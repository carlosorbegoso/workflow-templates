#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Validación de Setup de Deployment ===${NC}"
echo ""

# Función para verificar archivos
check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}OK: $description: $file${NC}"
        return 0
    else
        echo -e "${RED}MISSING: $description: $file (no encontrado)${NC}"
        return 1
    fi
}

# Función para verificar directorios
check_dir() {
    local dir=$1
    local description=$2
    
    if [ -d "$dir" ]; then
        echo -e "${GREEN}OK: $description: $dir${NC}"
        return 0
    else
        echo -e "${RED}MISSING: $description: $dir (no encontrado)${NC}"
        return 1
    fi
}

# Verificar estructura del proyecto
echo -e "${YELLOW}Verificando estructura del proyecto...${NC}"
check_file "docker-compose.yml" "Docker Compose"
check_file ".github/workflows/build-and-deploy.yml" "Workflow principal" || \
check_file ".github/workflows/deploy.yml" "Workflow de deploy"

if [ -f "pom.xml" ]; then
    echo -e "${GREEN}OK: Build tool: Maven (pom.xml)${NC}"
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    echo -e "${GREEN}OK: Build tool: Gradle${NC}"
else
    echo -e "${RED}MISSING: Build tool: No se encontró pom.xml o build.gradle${NC}"
fi

check_file "src/main/docker/Dockerfile.native" "Dockerfile nativo"

echo ""

# Verificar secrets (simulado - no podemos acceder a los secrets reales)
echo -e "${YELLOW}Secrets que debes configurar en GitHub:${NC}"
echo -e "${BLUE}Obligatorios:${NC}"
echo "  - SSH_HOST (IP o dominio del servidor)"
echo "  - SSH_USER (usuario SSH)"
echo "  - SSH_PRIVATE_KEY (clave privada SSH)"
echo "  - DEPLOY_PATH (ruta en el servidor, ej: /opt/apps/mi-app)"

echo -e "${BLUE}Registry (elige uno):${NC}"
echo "  - GHCR_USERNAME + GHCR_PAT (GitHub Container Registry)"
echo "  - DOCKER_USERNAME + DOCKER_PASSWORD (Docker Hub)"

echo -e "${BLUE}Opcionales:${NC}"
echo "  - DB_USERNAME (usuario de base de datos)"
echo "  - DB_PASSWORD (contraseña de base de datos)"

echo ""

# Verificar docker-compose.yml
if [ -f "docker-compose.yml" ]; then
    echo -e "${YELLOW}Verificando docker-compose.yml...${NC}"
    
    if grep -q '${DOCKER_IMAGE}' docker-compose.yml; then
        echo -e "${GREEN}OK: Variable DOCKER_IMAGE configurada${NC}"
    else
        echo -e "${RED}MISSING: Variable DOCKER_IMAGE no encontrada${NC}"
        echo -e "${YELLOW}TIP: Asegúrate de usar: image: \${DOCKER_IMAGE}${NC}"
    fi
    
    if grep -q '${PROJECT_NAME}' docker-compose.yml; then
        echo -e "${GREEN}OK: Variable PROJECT_NAME configurada${NC}"
    else
        echo -e "${YELLOW}WARNING: Variable PROJECT_NAME no encontrada (opcional)${NC}"
    fi
    
    if grep -q 'healthcheck:' docker-compose.yml; then
        echo -e "${GREEN}OK: Healthcheck configurado${NC}"
    else
        echo -e "${YELLOW}WARNING: Healthcheck no configurado (recomendado)${NC}"
    fi
fi

echo ""

# Verificar conectividad (si estamos en el servidor)
if command -v docker &> /dev/null; then
    echo -e "${YELLOW}Verificando Docker...${NC}"
    if docker --version &> /dev/null; then
        echo -e "${GREEN}OK: Docker instalado: $(docker --version)${NC}"
    else
        echo -e "${RED}ERROR: Docker no funciona correctamente${NC}"
    fi
    
    if docker-compose --version &> /dev/null; then
        echo -e "${GREEN}OK: Docker Compose instalado: $(docker-compose --version)${NC}"
    else
        echo -e "${RED}ERROR: Docker Compose no instalado${NC}"
    fi
else
    echo -e "${YELLOW}INFO: Docker no detectado (normal si ejecutas desde GitHub Actions)${NC}"
fi

echo ""
echo -e "${BLUE}=== Validación completada ===${NC}"
echo ""
echo -e "${YELLOW}Próximos pasos:${NC}"
echo "1. Configura todos los secrets en GitHub → Settings → Secrets and variables → Actions"
echo "2. Asegúrate de que docker-compose.yml existe y está configurado"
echo "3. Verifica que el servidor tiene Docker y Docker Compose instalados"
echo "4. Ejecuta un push a main/develop para activar el deployment"