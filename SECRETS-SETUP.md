# Configuración de Secrets para Yape Hub

Este documento lista todos los secrets necesarios para el pipeline CI/CD de Yape Hub.

## 🚀 Pipelines Disponibles

### 1. **Adaptive Pipeline** (Recomendado) 🎯
- **Desarrollo**: Tests + Calidad + Build JVM + Deploy (~15 min)
- **Producción**: Build Nativo Optimizado + Deploy (~30 min)
- **PR**: Solo tests rápidos (~5 min)
- **Inteligente**: Se adapta automáticamente al entorno

### 2. **Express Deploy** (Ultra-rápido) 🚀
- **Solo main**: Build Nativo + Deploy directo (~25 min)
- **Optimizado**: Cache avanzado + optimizaciones
- **Ideal para**: Hotfixes y deploys urgentes

### 3. **Turbo Deploy** (Más rápido) ⚡
- **Solo main**: Build Nativo + Deploy en paralelo (~15-20 min)
- **Paralelización**: 6 jobs ejecutándose simultáneamente
- **Ideal para**: Producción con máxima velocidad

## Secrets Obligatorios

### 🏗️ Infraestructura (Producción)
```
SSH_HOST=tu-servidor-produccion.com
SSH_USER=deploy
SSH_PRIVATE_KEY=-----BEGIN OPENSSH PRIVATE KEY-----...
DEPLOY_PATH=/opt/yape-hub
```

### 🗄️ Base de Datos
```
DB_USERNAME=yape_user
DB_PASSWORD=tu_password_seguro
DATABASE_URL=postgresql://usuario:password@host:5432/yape_hub?sslmode=require
```

### 🔐 JWT/Autenticación
```
JWT_SECRET=tu_jwt_secret_muy_largo_y_seguro_minimo_256_bits
JWT_ISSUER=https://api.yape-hub.com
```

### 📧 Email/SMTP
```
MAILER_FROM=noreply@yape-hub.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
EMAIL_USERNAME=tu-email@gmail.com
EMAIL_PASSWORD=tu_app_password
```

### 🌐 CORS
```
CORS_ORIGINS=https://yape-hub.com,https://www.yape-hub.com
```

## Secrets Opcionales

### 📦 Registry (GitHub Container Registry)
```
GHCR_USERNAME=tu-usuario-github
GHCR_PAT=ghp_tu_personal_access_token
```

### 🧪 Desarrollo (Opcional - usa producción si no existen)
```
DEV_SSH_HOST=dev.yape-hub.com
DEV_SSH_USER=deploy
DEV_SSH_PRIVATE_KEY=-----BEGIN OPENSSH PRIVATE KEY-----...
DEV_DEPLOY_PATH=/opt/yape-hub-dev
DEV_DB_USERNAME=yape_dev_user
DEV_DB_PASSWORD=dev_password
DEV_DATABASE_URL=postgresql://dev_user:dev_pass@dev-host:5432/yape_hub_dev
```

### 🔍 Calidad de Código
```
SONAR_TOKEN=tu_sonar_token
```

## Cómo configurar los secrets

### En GitHub:
1. Ve a tu repositorio → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Agrega cada secret con su nombre y valor

### Ejemplo de configuración local (.env):
```bash
# NO SUBIR ESTE ARCHIVO A GIT
# Usar solo para desarrollo local

# Infraestructura
SSH_HOST=localhost
SSH_USER=developer
DEPLOY_PATH=/tmp/yape-hub

# Base de datos
DB_USERNAME=postgres
DB_PASSWORD=postgres
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/yape_hub

# JWT
JWT_SECRET=desarrollo_jwt_secret_no_usar_en_produccion
JWT_ISSUER=http://localhost:8080

# Email (usar mailtrap o similar para desarrollo)
MAILER_FROM=dev@localhost
SMTP_HOST=smtp.mailtrap.io
SMTP_PORT=587
EMAIL_USERNAME=tu_mailtrap_user
EMAIL_PASSWORD=tu_mailtrap_pass

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
```

## Validación de Secrets

Para validar que todos los secrets están configurados correctamente, ejecuta:

```bash
./scripts/validate-setup.sh
```

## Notas de Seguridad

- ✅ Usa passwords fuertes (mínimo 32 caracteres)
- ✅ JWT_SECRET debe ser mínimo 256 bits
- ✅ Usa SSL/TLS en producción (sslmode=require)
- ✅ Rota los secrets regularmente
- ❌ NUNCA hardcodees secrets en el código
- ❌ NUNCA subas archivos .env al repositorio
## 🚀 Op
timizaciones de Producción

### Build Nativo Optimizado
- **Runners**: ubuntu-latest optimizado
- **Cache**: GraalVM + Maven/Gradle + Docker layers
- **Flags**: `-O2`, `--no-fallback`, `--gc=serial`
- **Tiempo**: 25-30 min (vs 45-60 min estándar)

### Docker Optimizado
- **Platform**: Solo linux/amd64 en producción
- **Cache**: GitHub Actions cache para layers
- **Build args**: Optimizaciones específicas de producción

### Deploy Express
- **SSH**: Conexión directa sin artifacts
- **Compose**: Detección automática de versión
- **Cleanup**: Limpieza automática de imágenes viejas

## 📊 Comparación de Tiempos

| Pipeline | Desarrollo | Producción | PR | Jobs Paralelos |
|----------|------------|------------|-----|----------------|
| **Adaptive** 🎯 | ~15 min | ~30 min | ~5 min | 2-3 |
| **Express** 🚀 | N/A | ~25 min | N/A | 1 |
| **Turbo** ⚡ | N/A | ~15-20 min | N/A | 6 |
| **Estándar** | ~25 min | ~45 min | ~10 min | 1-2 |

## 🎯 Cuándo usar cada pipeline

### Adaptive Pipeline 🎯
```yaml
# Para desarrollo normal y producción estable (recomendado)
uses: carlosorbegoso/workflow-templates/.github/workflows/smart-pipeline.yml@main
```

### Express Deploy 🚀
```yaml
# Para hotfixes y deploys urgentes (solo main)
uses: carlosorbegoso/workflow-templates/.github/workflows/production-express.yml@main
```

### Turbo Deploy ⚡
```yaml
# Para producción con máxima velocidad (solo main)
uses: carlosorbegoso/workflow-templates/.github/workflows/production-parallel.yml@main
```
#
# ⚡ Paralelización en Producción

### Turbo Deploy Pipeline

El pipeline paralelo divide el proceso en **6 jobs simultáneos**:

#### **Fase 1: Preparación (Paralelo)**
- **Job 1**: Setup & Cache - Prepara entorno y cache
- **Job 2**: Validate Config - Valida configuración del proyecto

#### **Fase 2: Build**
- **Job 3**: Native Build - Build nativo optimizado (25 min)

#### **Fase 3: Docker & Deploy Prep (Paralelo)**
- **Job 4**: Docker Build & Push - Construye imagen (8 min)
- **Job 5**: Prepare Deploy - Prepara servidor (3 min)

#### **Fase 4: Deploy Final**
- **Job 6**: Deploy - Deploy final (5 min)

### Optimizaciones Aplicadas

#### **Cache Inteligente**
```yaml
# Cache multi-layer
~/.m2/repository      # Maven dependencies
~/.gradle/caches      # Gradle dependencies  
~/.cache/native-image # GraalVM cache
```

#### **Build Nativo Ultra-optimizado**
```bash
# Flags de máximo rendimiento
-J-Xmx6g                    # 6GB RAM para GraalVM
--gc=serial                 # GC más rápido
-O2                         # Optimización máxima
--no-fallback              # Sin fallback JVM
-H:+UseSerialGC            # GC serial nativo
```

#### **Docker Optimizado**
```yaml
# Build con cache de GitHub Actions
--cache-from type=gha
--cache-to type=gha,mode=max
--platform linux/amd64     # Solo AMD64 para velocidad
```

### Comparación de Tiempos

| Etapa | Secuencial | Paralelo | Ahorro |
|-------|------------|----------|--------|
| Setup + Validación | 8 min | 5 min | 3 min |
| Build Nativo | 25 min | 25 min | 0 min |
| Docker + Prep | 11 min | 8 min | 3 min |
| Deploy | 5 min | 5 min | 0 min |
| **TOTAL** | **49 min** | **20 min** | **29 min** |

### Cuándo Usar Cada Pipeline

#### **Smart Pipeline** 👍
- Desarrollo diario
- Branches de feature
- Cuando necesitas tests y calidad

#### **Production Express** 🚀
- Hotfixes urgentes
- Deploys simples
- Cuando tienes un solo runner

#### **Production Parallel** ⚡
- Producción regular
- Cuando tienes múltiples runners disponibles
- Máxima velocidad de deploy

### Requisitos para Paralelización

- **GitHub Actions**: Plan que permita jobs concurrentes
- **Runners**: Al menos 3-4 runners disponibles simultáneamente
- **Memoria**: Suficiente para builds nativos (6GB recomendado)