#!/bin/bash

echo "=== Docker Apps Status ==="
echo ""

if [ ! -d "/opt/apps" ]; then
  echo "❌ Directorio /opt/apps no existe"
  exit 1
fi

for dir in /opt/apps/*/; do
  app_name=$(basename "$dir")
  cd "$dir" 2>/dev/null || continue
  
  if [ -f "docker-compose.yml" ]; then
    if docker-compose ps 2>/dev/null | grep -q "Up"; then
      status="✅ Running"
      port=$(grep -oP "^\s*-\s*\"\K[0-9]+(?=:8080)" docker-compose.yml | head -1)
      echo "$app_name: $status (puerto: ${port:-8080})"
    else
      status="❌ Stopped"
      echo "$app_name: $status"
    fi
  else
    echo "$app_name: ⚠️  Sin docker-compose.yml"
  fi
done

echo ""
echo "=== Resumen ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"