#!/bin/bash

APP_NAME=${1:-}
CONTAINER_NAME=${2:-}

if [ -z "$CONTAINER_NAME" ]; then
  echo "Uso: healthcheck.sh <app-name> <container-name>"
  exit 1
fi

echo "Verificando salud de $CONTAINER_NAME..."

for i in {1..10}; do
  if docker exec $CONTAINER_NAME curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "$CONTAINER_NAME esta saludable"
    exit 0
  fi
  
  echo "Intento $i/10..."
  sleep 3
done

echo "$CONTAINER_NAME no esta respondiendo"
exit 1