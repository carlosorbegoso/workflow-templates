# Workflow Templates - Quarkus Native

Repositorio central con plantillas reutilizables para construir y deployar aplicaciones Quarkus nativas con GitHub Actions.

## 📦 Contenido

### 🔧 Workflows principales:
- **`.github/workflows/smart-pipeline.yml`** - Pipeline dinámico inteligente
- **`.github/workflows/build.yml`** - Build de imagen nativa
- **`.github/workflows/push.yml`** - Push a registry (GHCR/Docker Hub)
- **`.github/workflows/deploy.yml`** - Deploy al servidor
- **`.github/workflows/test.yml`** - Tests unitarios e integración
- **`.github/workflows/quality-check.yml`** - Análisis de calidad
- **`.github/workflows/security-scan.yml`** - Escaneo de seguridad

### 📁 Ejemplos y guías:
- **`examples/microservice-workflow.yml`** - Workflow listo para copiar
- **`examples/migration-guide.md`** - Guía de migración paso a paso
- **`examples/README.md`** - Documentación de ejemplos

### 🛠️ Scripts de utilidad:
- **`scripts/deploy.sh`** - Script de deployment
- **`scripts/healthcheck.sh`** - Verificación de salud
- **`scripts/status.sh`** - Ver estado de apps
- **`scripts/validate-setup.sh`** - Validar configuración

## 🚀 Workflow Dinámico Inteligente

### Un solo archivo que se adapta automáticamente:

- **PULL REQUEST** → Tests rápidos (3-5 min)
- **MAIN** → Deploy a producción (5-8 min)  
- **DEVELOP/FEATURE** → Pipeline completo (15-20 min)

### 🧠 Detección automática:
- Detecta la rama y evento automáticamente
- Ejecuta solo lo necesario para cada entorno
- Usa secrets de desarrollo o producción según corresponda
- Fallback inteligente si no tienes entornos separados

## 📁 Uso en tu proyecto

### 🔄 Si ya tienes un workflow:
👉 **Ve a `examples/migration-guide.md`** para migración paso a paso

### 🆕 Si es un proyecto nuevo:
👉 **Copia `examples/microservice-workflow.yml`** a tu proyecto

### ⚡ Uso rápido:

### `.github/workflows/build-and-deploy.yml`

1. **Copia** `examples/microservice-workflow.yml`
2. **Pégalo** como `.github/workflows/ci-cd.yml` en tu microservicio
3. **Configura** los secrets necesarios
4. **Haz push** y listo

**Ejemplo completo en:** `examples/microservice-workflow.yml`

## 🎯 Comportamiento automático:

| Evento | Rama | Pipeline | Tiempo | Acciones |
|--------|------|----------|--------|----------|
| **Pull Request** | cualquiera | Tests básicos | 3-5 min | Solo unit tests |
| **Push** | `main` | Producción | 5-8 min | Build → Push → Deploy |
| **Push** | `develop`, `feature/*` | Desarrollo | 15-20 min | Tests → Quality → Security → Build → Deploy |

## 🔒 Seguridad mejorada:

- ✅ **Secrets protegidos** - No se exponen como outputs
- ✅ **Fallback inteligente** - Usa secrets de producción si no hay de desarrollo
- ✅ **Detección automática** - Identifica qué secrets están disponibles

## 📋 Secrets requeridos en tu proyecto

### Secrets obligatorios (mínimo para funcionar):
| Secret | Descripción | Ejemplo |
|--------|------------|---------|
| `SSH_HOST` | IP o dominio del servidor de producción | `192.168.1.100` |
| `SSH_USER` | Usuario SSH de producción | `ubuntu` |
| `SSH_PRIVATE_KEY` | Clave privada SSH | `-----BEGIN...` |
| `DEPLOY_PATH` | Ruta en servidor de producción | `/opt/apps/mi-app` |

### Secrets opcionales para entornos separados:
| Secret | Descripción | Ejemplo |
|--------|------------|---------|
| `DEV_SSH_HOST` | Servidor de desarrollo | `192.168.1.101` |
| `DEV_SSH_USER` | Usuario SSH de desarrollo | `ubuntu` |
| `DEV_SSH_PRIVATE_KEY` | Clave SSH de desarrollo | `-----BEGIN...` |
| `DEV_DEPLOY_PATH` | Ruta en servidor de desarrollo | `/opt/apps-dev/mi-app` |
| `DEV_DB_USERNAME` | Usuario BD de desarrollo | `dev_user` |
| `DEV_DB_PASSWORD` | Password BD de desarrollo | `dev_pass` |

### Secrets para GitHub Container Registry (GHCR):
**Opción A: Automático (recomendado)**
- No necesitas configurar secrets adicionales
- Usa automáticamente `GITHUB_TOKEN` y `github.actor`
- Funciona out-of-the-box

**Opción B: Con Personal Access Token (para más control)**
| Secret | Descripción | Ejemplo |
|--------|------------|---------|
| `GHCR_USERNAME` | Tu usuario de GitHub | `carlosorbegoso` |
| `GHCR_PAT` | Personal Access Token con permisos `write:packages` | `ghp_xxxx` |

### Secrets para Docker Hub (alternativo):
| Secret | Descripción | Ejemplo |
|--------|------------|---------|
| `DOCKER_USERNAME` | Usuario Docker Hub | `migueldocker` |
| `DOCKER_PASSWORD` | Token Docker Hub | `dckr_pat_xxxx` |

### Secrets opcionales:
| Secret | Descripción | Ejemplo |
|--------|------------|---------|
| `DB_USERNAME` | Usuario de base de datos | `app_user` |
| `DB_PASSWORD` | Contraseña de base de datos | `secure_password` |

### Variables disponibles en docker-compose.yml:
| Variable | Descripción | Valor por defecto |
|----------|-------------|-------------------|
| `${DOCKER_IMAGE}` | Imagen Docker a deployar | Generada automáticamente |
| `${PROJECT_NAME}` | Nombre del proyecto | Nombre del repositorio |
| `${APP_NAME}` | Nombre de la aplicación | Igual que PROJECT_NAME |
| `${DB_USERNAME}` | Usuario de base de datos | Del secret |
| `${DB_PASSWORD}` | Contraseña de base de datos | Del secret |
| `${DB_JDBC_URL}` | URL de conexión a BD | `jdbc:postgresql://localhost:5432/${PROJECT_NAME}` |

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

## Troubleshooting

### Error: "docker-compose.yml not found"
```bash
# Copia el archivo de ejemplo y personalízalo
cp docker-compose.example.yml docker-compose.yml
# Edita los puertos y configuración según tu app
```

### Error: "Failed to authenticate with GHCR"
1. Verifica que `GHCR_USERNAME` sea tu usuario de GitHub
2. Crea un Personal Access Token con permisos `write:packages`
3. Guárdalo en `GHCR_PAT`

### Error: "No se pudo descargar la imagen"
1. Verifica que la imagen existe en el registry
2. Confirma que los secrets de autenticación están configurados
3. Revisa que el workflow de build se ejecutó correctamente

### Error: "SSH connection failed"
```bash
# Genera una nueva SSH key
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -N ""

# Copia la clave pública al servidor
ssh-copy-id -i ~/.ssh/deploy_key.pub user@server

# Usa la clave privada en SSH_PRIVATE_KEY
cat ~/.ssh/deploy_key
```

### Verificar deployment
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