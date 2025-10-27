# 🐳 Guía de Docker Compose

Esta carpeta contiene diferentes versiones de docker-compose optimizadas para diferentes tipos de servidores.

## 📁 Archivos disponibles

### **yape-hub-docker-compose.yml** (Estándar)
Para servidores medianos con recursos limitados.
- **CPU**: 0.8 cores (80% de 1 CPU)
- **RAM**: 1GB límite, 512MB reservado
- **Ideal para**: VPS básicos, servidores compartidos

### **yape-hub-docker-compose-small.yml** (Servidor pequeño)
Para servidores muy limitados o desarrollo.
- **CPU**: 0.8 cores (80% de 1 CPU)
- **RAM**: 768MB límite, 256MB reservado
- **Ideal para**: VPS mínimos, desarrollo local

### **yape-hub-docker-compose-large.yml** (Servidor potente)
Para servidores dedicados con buenos recursos.
- **CPU**: 3 cores
- **RAM**: 4GB límite, 1GB reservado
- **Ideal para**: Servidores dedicados, producción alta carga

## 🎯 Cómo elegir

### **Revisa los recursos de tu servidor:**
```bash
# Ver CPUs disponibles
nproc

# Ver RAM disponible
free -h

# Ver uso actual
htop
```

### **Según tus recursos:**

| Servidor | CPUs | RAM | Archivo recomendado |
|----------|------|-----|-------------------|
| **Mínimo** | 1 CPU | 1GB | `yape-hub-docker-compose-small.yml` |
| **Estándar** | 1-2 CPUs | 2GB | `yape-hub-docker-compose.yml` |
| **Potente** | 4+ CPUs | 4GB+ | `yape-hub-docker-compose-large.yml` |

## 🔧 Cómo usar

### **1. Configura el .env en la raíz:**
```bash
# Copia el ejemplo a la raíz del usuario
cp root-env-example.txt ~/.env

# Edita con tus valores reales
nano ~/.env
```

### **2. Copia el archivo apropiado:**
```bash
# Para servidor pequeño
cp yape-hub-docker-compose-small.yml docker-compose.yml

# Para servidor estándar
cp yape-hub-docker-compose.yml docker-compose.yml

# Para servidor potente
cp yape-hub-docker-compose-large.yml docker-compose.yml
```

### **2. Personaliza si es necesario:**
```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'    # Ajusta según tu servidor
      memory: 512M   # Ajusta según tu RAM
```

## ⚠️ Errores comunes

### **Error: "range of CPUs is from 0.01 to 1.00"**
**Causa**: Tu servidor tiene 1 CPU pero el docker-compose pide más.
**Solución**: Usa `yape-hub-docker-compose-small.yml`

### **Error: "Cannot allocate memory"**
**Causa**: No hay suficiente RAM disponible.
**Solución**: Reduce el límite de memoria o usa la versión small.

### **Aplicación muy lenta**
**Causa**: Recursos insuficientes asignados.
**Solución**: Aumenta los límites o usa un servidor más potente.

## 🚀 Optimizaciones por tipo

### **Servidor pequeño:**
- Logging reducido (WARN level)
- Healthcheck menos frecuente
- Menos memoria reservada
- SSL mode: allow (más flexible)

### **Servidor estándar:**
- Logging normal (INFO level)
- Healthcheck estándar
- Recursos balanceados
- SSL mode: allow

### **Servidor potente:**
- Logging completo (INFO level)
- Healthcheck frecuente
- Más recursos disponibles
- SSL mode: require (más seguro)

## 📊 Monitoreo

### **Ver uso de recursos:**
```bash
# Ver contenedores y su uso
docker stats

# Ver logs de la aplicación
docker logs yape-hub

# Ver estado del healthcheck
docker inspect yape-hub | grep Health -A 10
```

### **Ajustar en tiempo real:**
```bash
# Actualizar límites sin reiniciar
docker update --cpus="0.5" --memory="512m" yape-hub
```

## 🔄 Migración entre versiones

### **De small a estándar:**
1. Para la aplicación: `docker-compose down`
2. Copia el nuevo archivo: `cp yape-hub-docker-compose.yml docker-compose.yml`
3. Inicia: `docker-compose up -d`

### **Rollback si hay problemas:**
1. Para: `docker-compose down`
2. Vuelve al anterior: `cp yape-hub-docker-compose-small.yml docker-compose.yml`
3. Inicia: `docker-compose up -d`