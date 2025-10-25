# 🔄 Guía de Migración para Microservicios

## ❌ WORKFLOW ACTUAL (lo que tienes):

```yaml
name: Build and Deploy Quarkus Native

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build-and-deploy:
    if: github.event_name == 'push'  # ← Problema: no funciona para PRs
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

## ✅ NUEVO WORKFLOW (dinámico e inteligente):

**Copia el contenido de `examples/microservice-workflow.yml`**

## 🎯 PRINCIPALES DIFERENCIAS:

| Aspecto | Antes | Ahora |
|---------|-------|-------|
| **Workflow usado** | `quarkus-native-build-deploy.yml` | `smart-pipeline.yml` |
| **Configuración** | Manual (`with: use_ghcr: true`) | Automática |
| **Pull Requests** | No funcionan (`if: push`) | Funcionan (tests rápidos) |
| **Ramas** | Solo `main, develop` | `main, develop, feature/*` |
| **Comportamiento** | Igual para todas las ramas | Inteligente según rama |

## 🚀 NUEVO COMPORTAMIENTO:

### 📋 Pull Request → Tests rápidos (3-5 min)
- Solo unit tests
- Sin integration tests
- Sin build, sin deploy
- Feedback rápido para desarrolladores

### 🎯 Push a `main` → Producción (5-8 min)
- Build + Push + Deploy
- Sin tests (máxima velocidad)
- Directo a producción

### 🔧 Push a `develop`/`feature/*` → Desarrollo (15-20 min)
- Tests completos
- Quality checks
- Security scan
- Build + Push + Deploy
- Pipeline completo con validaciones

## 📋 SECRETS NECESARIOS:

### Obligatorios (los que ya tienes):
```
SSH_HOST=192.168.1.100
SSH_USER=ubuntu
SSH_PRIVATE_KEY=-----BEGIN OPENSSH PRIVATE KEY-----...
DEPLOY_PATH=/opt/apps/mi-microservicio
DB_USERNAME=app_user
DB_PASSWORD=secure_password
GHCR_USERNAME=tu-usuario-github
GHCR_PAT=ghp_xxxxxxxxxxxx
```

### Opcionales (para entornos separados):
```
DEV_SSH_HOST=192.168.1.101
DEV_SSH_USER=ubuntu
DEV_SSH_PRIVATE_KEY=-----BEGIN OPENSSH PRIVATE KEY-----...
DEV_DEPLOY_PATH=/opt/apps-dev/mi-microservicio
DEV_DB_USERNAME=dev_user
DEV_DB_PASSWORD=dev_password
SONAR_TOKEN=squ_xxxxxxxxxxxx
```

## 🔧 PASOS PARA MIGRAR:

1. **Abre tu microservicio**
2. **Edita** `.github/workflows/build-and-deploy.yml` (o como se llame)
3. **Borra** todo el contenido actual
4. **Copia** el contenido de `examples/microservice-workflow.yml`
5. **Guarda** y haz commit
6. **Listo!** - El workflow funcionará inmediatamente

## ⚡ BENEFICIOS INMEDIATOS:

- ✅ Pull requests funcionarán (antes no)
- ✅ Deploy a producción más rápido (sin tests)
- ✅ Pipeline completo en desarrollo
- ✅ Detección automática de entorno
- ✅ Fallback inteligente si no tienes secrets de dev