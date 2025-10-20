# Workflow Templates - Quarkus Native

Repositorio central con plantillas reutilizables para construir y deployar aplicaciones Quarkus nativas con GitHub Actions.

## 📦 Contenido

- **`.github/workflows/quarkus-native-build-deploy.yml`** - Workflow principal (orquestador)
- **`.github/workflows/build.yml`** - Paso 1: Build de imagen nativa
- **`.github/workflows/push.yml`** - Paso 2: Push a Docker Hub
- **`.github/workflows/deploy.yml`** - Paso 3: Deploy al servidor
- **`scripts/deploy.sh`** - Script de deployment
- **`scripts/healthcheck.sh`** - Verificación de salud
- **`scripts/status.sh`** - Ver estado de apps

## 🚀 Uso en tu proyecto

En tu repositorio de proyecto, crea el archivo:

### `.github/workflows/build-and-deploy.yml`
```yaml
name: Build and Deploy Quarkus Native

on:
  push:
    branches: [main, develop]

jobs:
  build-and-deploy:
    uses: ${{ github.repository_owner }}/workflow-templates/.github/workflows/quarkus-native-build-deploy.yml@main
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
      SSH_HOST: ${{ secrets.SSH_HOST }}
      SSH_USER: ${{ secrets.SSH_USER }}
      SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
      DEPLOY_PATH: ${{ secrets.DEPLOY_PATH }}
```

## 📋 Secrets requeridos en tu proyecto

| Secret | Descripción | Ejemplo |
|--------|------------|---------|
| `DOCKER_USERNAME` | Usuario Docker Hub | `migueldocker` |
| `DOCKER_PASSWORD` | Token Docker Hub | `dckr_pat_xxxx` |
| `SSH_HOST` | IP o dominio del servidor | `192.168.1.100` |
| `SSH_USER` | Usuario SSH | `ubuntu` |
| `SSH_PRIVATE_KEY` | Clave privada SSH (multiline) | `-----BEGIN...` |
| `DEPLOY_PATH` | Ruta en servidor | `/opt/apps/mi-app` |

## 📝 Archivo requerido en tu proyecto

### `docker-compose.yml`

Cada proyecto debe tener su propio `docker-compose.yml` en la raíz:
```yaml
version: '3.8'

services:
  app:
    image: ${DOCKER_IMAGE}
    container_name: ${APP_NAME}
    ports:
      - "8080:8080"  # Cambia el primer puerto según tu necesidad
    environment:
      - QUARKUS_HTTP_HOST=0.0.0.0
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

## 🔄 Flujo de ejecución

1. **Build** - Detecta Maven o Gradle, construye imagen nativa
2. **Push** - Sube la imagen a Docker Hub
3. **Deploy** - SSH al servidor, copia archivos y ejecuta deploy

## 🛠️ Usar los scripts en el servidor
```bash
# Ver estado de todas las apps
bash /tmp/deploy-scripts/status.sh

# Verificar salud de una app
bash /tmp/deploy-scripts/healthcheck.sh app1 quarkus-app1

# Reiniciar una app manualmente
cd /opt/apps/quarkus-app1
docker-compose restart

# Ver logs
docker-compose logs -f

# Limpiar contenedores parados
docker container prune -f
```

## 🔐 Generar credenciales

### Docker Hub Token
1. Ve a https://hub.docker.com/settings/security
2. Click en "New Access Token"
3. Dale un nombre: "github-actions"
4. Copia el token completo en `DOCKER_PASSWORD`

### SSH Key
```bash
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -N ""
cat ~/.ssh/deploy_key  # Copia en SSH_PRIVATE_KEY
cat ~/.ssh/deploy_key.pub  # Agrega a ~/.ssh/authorized_keys en servidor
```

## 📦 Soporta Maven y Gradle

El workflow detecta automáticamente:
- `pom.xml` → Maven
- `build.gradle` o `build.gradle.kts` → Gradle

## 📁 Estructura en el servidor