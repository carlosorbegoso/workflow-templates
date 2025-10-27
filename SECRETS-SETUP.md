# Configuración de Secrets para Yape Hub

Este documento lista todos los secrets necesarios para el pipeline CI/CD de Yape Hub.

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