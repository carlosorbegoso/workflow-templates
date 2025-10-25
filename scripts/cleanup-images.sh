#!/bin/bash

# Script para limpiar imágenes Docker viejas
# Uso: ./cleanup-images.sh [proyecto] [días]

PROJECT_NAME=${1:-yape-hub}
DAYS_OLD=${2:-7}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== LIMPIEZA DE IMÁGENES DOCKER ===${NC}"
echo -e "${BLUE}Proyecto: $PROJECT_NAME${NC}"
echo -e "${BLUE}Eliminar imágenes de más de: $DAYS_OLD días${NC}"
echo ""

# Mostrar espacio actual
echo -e "${YELLOW}Espacio actual usado por Docker:${NC}"
docker system df

echo ""

# Obtener imagen actual en uso
CURRENT_IMAGE=""
if [ -f "/opt/apps/$PROJECT_NAME/docker-compose.yml" ]; then
    cd "/opt/apps/$PROJECT_NAME"
    CURRENT_IMAGE=$(docker-compose config | grep "image:" | awk '{print $2}' | head -1)
    echo -e "${GREEN}Imagen actual en uso: $CURRENT_IMAGE${NC}"
else
    echo -e "${YELLOW}No se encontró docker-compose.yml, no se puede determinar imagen actual${NC}"
fi

echo ""

# Listar imágenes del proyecto
echo -e "${YELLOW}Imágenes del proyecto $PROJECT_NAME:${NC}"
IMAGES_TO_CHECK=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}} {{.CreatedAt}}" | grep "$PROJECT_NAME")

if [ -z "$IMAGES_TO_CHECK" ]; then
    echo "No se encontraron imágenes del proyecto $PROJECT_NAME"
    exit 0
fi

echo "$IMAGES_TO_CHECK"
echo ""

# Función para verificar si una imagen está en uso
is_image_in_use() {
    local image_id=$1
    # Verificar si hay contenedores usando esta imagen
    docker ps -a --format "{{.Image}} {{.ID}}" | grep -q "$image_id"
}

# Función para calcular días desde creación
days_since_created() {
    local created_date=$1
    local current_date=$(date +%s)
    local created_timestamp
    
    # Convertir fecha de Docker a timestamp
    if command -v gdate >/dev/null 2>&1; then
        # macOS
        created_timestamp=$(gdate -d "$created_date" +%s 2>/dev/null || echo "0")
    else
        # Linux
        created_timestamp=$(date -d "$created_date" +%s 2>/dev/null || echo "0")
    fi
    
    if [ "$created_timestamp" = "0" ]; then
        echo "999" # Si no se puede parsear, asumir que es muy vieja
    else
        echo $(( (current_date - created_timestamp) / 86400 ))
    fi
}

# Procesar cada imagen
DELETED_COUNT=0
KEPT_COUNT=0

echo -e "${YELLOW}Analizando imágenes...${NC}"
echo "$IMAGES_TO_CHECK" | while read line; do
    if [ -z "$line" ]; then continue; fi
    
    IMAGE_FULL=$(echo "$line" | awk '{print $1}')
    IMAGE_ID=$(echo "$line" | awk '{print $2}')
    CREATED_DATE=$(echo "$line" | awk '{$1=$2=""; print $0}' | sed 's/^ *//')
    
    echo ""
    echo -e "${BLUE}Procesando: $IMAGE_FULL${NC}"
    echo "  ID: $IMAGE_ID"
    echo "  Creado: $CREATED_DATE"
    
    # Verificar si es la imagen actual
    if [ "$IMAGE_FULL" = "$CURRENT_IMAGE" ]; then
        echo -e "  ${GREEN}✓ Imagen actual en uso - MANTENER${NC}"
        KEPT_COUNT=$((KEPT_COUNT + 1))
        continue
    fi
    
    # Verificar si está en uso por algún contenedor
    if is_image_in_use "$IMAGE_ID"; then
        echo -e "  ${GREEN}✓ En uso por contenedor - MANTENER${NC}"
        KEPT_COUNT=$((KEPT_COUNT + 1))
        continue
    fi
    
    # Calcular días desde creación
    DAYS_OLD_IMAGE=$(days_since_created "$CREATED_DATE")
    echo "  Días desde creación: $DAYS_OLD_IMAGE"
    
    if [ "$DAYS_OLD_IMAGE" -gt "$DAYS_OLD" ]; then
        echo -e "  ${RED}✗ Imagen vieja (>$DAYS_OLD días) - ELIMINAR${NC}"
        
        if docker rmi "$IMAGE_FULL" 2>/dev/null; then
            echo -e "  ${GREEN}✓ Eliminada exitosamente${NC}"
            DELETED_COUNT=$((DELETED_COUNT + 1))
        else
            echo -e "  ${YELLOW}⚠ No se pudo eliminar (puede estar en uso)${NC}"
            KEPT_COUNT=$((KEPT_COUNT + 1))
        fi
    else
        echo -e "  ${GREEN}✓ Imagen reciente - MANTENER${NC}"
        KEPT_COUNT=$((KEPT_COUNT + 1))
    fi
done

echo ""
echo -e "${BLUE}=== LIMPIEZA ADICIONAL ===${NC}"

# Limpiar imágenes colgantes
echo "Limpiando imágenes colgantes..."
DANGLING_CLEANED=$(docker image prune -f --filter "dangling=true" 2>/dev/null | grep "Total reclaimed space" || echo "0B")
echo "Espacio liberado de imágenes colgantes: $DANGLING_CLEANED"

# Limpiar contenedores parados
echo "Limpiando contenedores parados..."
CONTAINERS_CLEANED=$(docker container prune -f 2>/dev/null | grep "Total reclaimed space" || echo "0B")
echo "Espacio liberado de contenedores: $CONTAINERS_CLEANED"

echo ""
echo -e "${BLUE}=== RESUMEN ===${NC}"
echo "Imágenes eliminadas: $DELETED_COUNT"
echo "Imágenes mantenidas: $KEPT_COUNT"

echo ""
echo -e "${YELLOW}Espacio después de limpieza:${NC}"
docker system df

echo ""
echo -e "${GREEN}Limpieza completada${NC}"