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

**Opción A: Con registry (GHCR o Docker Hub)**
```yaml
name: Build and Deploy Quarkus Native

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-and-deploy:
    if: github.event_name == 'push'
    uses: carlosorbegoso/workflow-templates/.github/workflows/quarkus-native-build-deploy.yml@main
    with:
      use_ghcr: true
      push_to_registry: true
    secrets:
      SSH_HOST: ${{ secrets.SSH_HOST }}
      SSH_USER: ${{ secrets.SSH_USER }}
      SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
      DEPLOY_PATH: ${{ secrets.DEPLOY_PATH }}
      GHCR_USERNAME: ${{ secrets.GHCR_USERNAME }}
      GHCR_PAT: ${{ secrets.GHCR_PAT }}
      DB_USERNAME: ${{ secrets.DB_USERNAME }}
      DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
```

**Opción B: Sin registry (transferencia directa)**
```yaml
name: Build and Deploy Quarkus Native

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-and-deploy:
    if: github.event_name == 'push'
    uses: carlosorbegoso/workflow-templates/.github/workflows/quarkus-native-build-deploy.yml@main
    with:
      use_ghcr: true
      push_to_registry: false  # No sube al registry, transfiere directamente
    secrets:
      SSH_HOST: ${{ secrets.SSH_HOST }}
      SSH_USER: ${{ secrets.SSH_USER }}
      SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
      DEPLOY_PATH: ${{ secrets.DEPLOY_PATH }}
      DB_USERNAME: ${{ secrets.DB_USERNAME }}
      DB_PASSWORD: ${{ secrets.DB_PASSWORD }}
```

## 📋 Secrets requeridos en tu proyecto

### Secrets obligatorios para deployment:
| Secret | Descripción | Ejemplo |
|--------|------------|---------|
| `SSH_HOST` | IP o dominio del servidor | `192.168.1.100` |
| `SSH_USER` | Usuario SSH | `ubuntu` |
| `SSH_PRIVATE_KEY` | Clave privada SSH (multiline) | `-----BEGIN...` |
| `DEPLOY_PATH` | Ruta en servidor | `/opt/apps/mi-app` |

### Secrets para registry (elige uno):
**Opción A: GitHub Container Registry (GHCR) - Recomendado**
| Secret | Descripción | Ejemplo |
|--------|------------|---------|
| `GHCR_USERNAME` | Tu usuario de GitHub | `migueldocker` |
| `GHCR_PAT` | Personal Access Token con permisos de packages | `ghp_xxxx` |

**Opción B: Docker Hub**
| Secret | Descripción | Ejemplo |
|--------|------------|---------|
| `DOCKER_USERNAME` | Usuario Docker Hub | `migueldocker` |
| `DOCKER_PASSWORD` | Token Docker Hub | `dckr_pat_xxxx` |

### Secrets opcionales:
| Secret | Descripción | Ejemplo |
|--------|------------|---------|
| `DB_USERNAME` | Usuario de base de datos | `app_user` |
| `DB_PASSWORD` | Contraseña de base de datos | `secure_password` |

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

## 🔧 Troubleshooting

### ❌ Error: "docker-compose.yml not found"
```bash
# Copia el archivo de ejemplo y personalízalo
cp docker-compose.example.yml docker-compose.yml
# Edita los puertos y configuración según tu app
```

### ❌ Error: "Failed to authenticate with GHCR"
1. Verifica que `GHCR_USERNAME` sea tu usuario de GitHub
2. Crea un Personal Access Token con permisos `write:packages`
3. Guárdalo en `GHCR_PAT`

### ❌ Error: "No se pudo descargar la imagen"
1. Verifica que la imagen existe en el registry
2. Confirma que los secrets de autenticación están configurados
3. Revisa que el workflow de build se ejecutó correctamente

### ❌ Error: "SSH connection failed"
```bash
# Genera una nueva SSH key
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -N ""

# Copia la clave pública al servidor
ssh-copy-id -i ~/.ssh/deploy_key.pub user@server

# Usa la clave privada en SSH_PRIVATE_KEY
cat ~/.ssh/deploy_key
```

### 🔍 Verificar deployment
```bash
# En el servidor, ve al directorio del proyecto
cd /opt/apps/tu-proyecto

# Ver estado de contenedores
docker-compose ps

# Ver logs
docker-compose logs -f

# Reiniciar si es necesario
docker-compose restart
```

## 📁 Estructura en el servidor