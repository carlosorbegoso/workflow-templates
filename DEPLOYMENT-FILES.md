# 📁 Archivos Necesarios para Deployment

## ✅ Archivos REQUERIDOS en tu proyecto:

### 1. `docker-compose.yml` (OBLIGATORIO)
```yaml
version: '3.8'
services:
  app:
    image: ${DOCKER_IMAGE}
    container_name: ${APP_NAME}
    ports:
      - "8080:8080"
    environment:
      - QUARKUS_HTTP_HOST=0.0.0.0
      # ... otras variables
```

### 2. `src/main/docker/Dockerfile.native` (OBLIGATORIO)
- Necesario para el build nativo de Quarkus
- Generado automáticamente por Quarkus

### 3. `pom.xml` o `build.gradle` (OBLIGATORIO)
- Para detectar el tipo de build (Maven/Gradle)

## 📋 Archivos OPCIONALES:

### 1. `.env` (Opcional)
- Variables de entorno específicas del proyecto
- Se copia al servidor si existe

### 2. Archivos de configuración adicionales
- Solo se copian si están en la raíz del proyecto

## ❌ Archivos que NO se copian al servidor:

- `examples/` - Solo para referencia
- `README.md` - Documentación
- `.github/` - Workflows
- `docs/` - Documentación
- Archivos de prueba
- Archivos temporales

## 🔧 Estructura en el servidor:

```
/opt/apps/tu-proyecto/
├── docker-compose.yml    ← Copiado desde tu proyecto
├── .env                  ← Copiado si existe en tu proyecto
└── image.tar            ← Solo si no usas registry
```

## 🚀 Para deployment exitoso:

1. ✅ Crea `docker-compose.yml` en la raíz de tu proyecto
2. ✅ Asegúrate de tener `Dockerfile.native`
3. ✅ Configura los secrets necesarios
4. ✅ Haz push a main

## 💡 Tip:

Usa `examples/yape-hub-docker-compose.yml` como plantilla para crear tu `docker-compose.yml`.