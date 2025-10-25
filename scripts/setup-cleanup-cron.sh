#!/bin/bash

# Script para configurar limpieza automática con cron
# Ejecutar como: sudo ./setup-cleanup-cron.sh

echo "Configurando limpieza automática de imágenes Docker..."

# Crear script de limpieza en /usr/local/bin
cat > /usr/local/bin/docker-cleanup << 'EOF'
#!/bin/bash
# Limpieza automática de imágenes Docker

LOG_FILE="/var/log/docker-cleanup.log"
echo "$(date): Iniciando limpieza automática" >> $LOG_FILE

# Limpiar imágenes colgantes
docker image prune -f --filter "dangling=true" >> $LOG_FILE 2>&1

# Limpiar imágenes de más de 7 días (excepto las que están en uso)
docker images --format "{{.Repository}}:{{.Tag}} {{.ID}} {{.CreatedAt}}" | while read line; do
    if [[ "$line" == *"yape-hub"* ]]; then
        IMAGE=$(echo "$line" | awk '{print $1}')
        IMAGE_ID=$(echo "$line" | awk '{print $2}')
        
        # Verificar si está en uso
        if ! docker ps -a --format "{{.Image}}" | grep -q "$IMAGE_ID"; then
            # Verificar si es vieja (más de 7 días)
            CREATED=$(echo "$line" | awk '{$1=$2=""; print $0}' | sed 's/^ *//')
            if [[ "$CREATED" == *"days ago"* ]] || [[ "$CREATED" == *"weeks ago"* ]] || [[ "$CREATED" == *"months ago"* ]]; then
                echo "$(date): Eliminando imagen vieja: $IMAGE" >> $LOG_FILE
                docker rmi "$IMAGE" >> $LOG_FILE 2>&1
            fi
        fi
    fi
done

# Limpiar contenedores parados
docker container prune -f >> $LOG_FILE 2>&1

echo "$(date): Limpieza completada" >> $LOG_FILE
echo "---" >> $LOG_FILE
EOF

# Dar permisos de ejecución
chmod +x /usr/local/bin/docker-cleanup

# Agregar al cron (ejecutar cada día a las 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/docker-cleanup") | crontab -

echo "✅ Limpieza automática configurada"
echo "   - Script: /usr/local/bin/docker-cleanup"
echo "   - Cron: Todos los días a las 2:00 AM"
echo "   - Log: /var/log/docker-cleanup.log"
echo ""
echo "Para probar manualmente:"
echo "   sudo /usr/local/bin/docker-cleanup"
echo ""
echo "Para ver el log:"
echo "   tail -f /var/log/docker-cleanup.log"