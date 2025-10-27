# 📁 Estructura de Workflows

Esta carpeta contiene todos los workflows organizados por nomenclatura de prefijos.

## 🗂️ Organización por Prefijos

```
.github/workflows/
├── 🎯 [Workflows principales]           # Workflows de entrada
│   ├── smart-pipeline.yml              # Pipeline adaptativo principal
│   ├── build-and-push.yml              # Build y push original
│   └── build-and-push-modular.yml      # Build y push modular
│
├── 🧩 component-*                      # Componentes reutilizables
│   ├── component-build-native.yml      # Build nativo optimizado
│   ├── component-build-jvm.yml         # Build JVM optimizado  
│   ├── component-docker-push.yml       # Docker build y push
│   ├── component-build-native-basic.yml # Build nativo básico
│   └── component-build-jvm-basic.yml   # Build JVM básico
│
├── 🚀 production-*                     # Solo para producción
│   ├── production-express.yml          # Deploy express (~25 min)
│   ├── production-parallel.yml         # Deploy turbo (~15-20 min)
│   └── production-deploy.yml           # Deploy básico
│
├── 🔧 development-*                    # Para desarrollo y testing
│   ├── development-test.yml            # Tests unitarios e integración
│   ├── development-quality-check.yml   # SonarQube, linting, etc.
│   └── development-security-scan.yml   # Escaneo de seguridad
│
└── 🤝 shared-*                        # Workflows compartidos
    ├── shared-deploy.yml               # Deploy genérico
    ├── shared-push.yml                 # Push a registry
    └── shared-validate-deployment.yml  # Validaciones
```

## 🎯 Workflows Principales (Puntos de entrada)

### **smart-pipeline.yml** 🎯 (Recomendado)
Pipeline adaptativo que se ajusta automáticamente al entorno.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/smart-pipeline.yml@main
```

### **build-and-push.yml** 🔧 (Original)
Workflow monolítico original (519 líneas).
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/build-and-push.yml@main
```

### **build-and-push-modular.yml** ⚡ (Modular)
Versión modular del build-and-push usando componentes.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/build-and-push-modular.yml@main
```

## 🧩 Componentes Reutilizables

### **component-build-native.yml**
Build nativo con GraalVM optimizado.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/component-build-native.yml@main
with:
  production_optimized: true
```

### **component-build-jvm.yml**
Build JVM rápido y optimizado.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/component-build-jvm.yml@main
```

### **component-docker-push.yml**
Docker build y push especializado.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/component-docker-push.yml@main
with:
  build_type: "native"
  artifact_name: "my-app-native-runner"
  push_to_registry: true
```

## 🚀 Workflows de Producción

### **production-express.yml**
Deploy express para hotfixes urgentes.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/production-express.yml@main
```

### **production-parallel.yml**
Deploy turbo con paralelización máxima.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/production-parallel.yml@main
```

## 🔧 Workflows de Desarrollo

### **development-test.yml**
Tests unitarios e integración.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/development-test.yml@main
with:
  java_version: '21'
  run_integration_tests: true
```

### **development-quality-check.yml**
Análisis de calidad de código.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/development-quality-check.yml@main
with:
  sonar_enabled: true
secrets:
  SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### **development-security-scan.yml**
Escaneo de seguridad y vulnerabilidades.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/development-security-scan.yml@main
with:
  scan_dependencies: true
  scan_code: true
```

## 🤝 Workflows Compartidos

### **shared-deploy.yml**
Deploy genérico que funciona para cualquier ambiente.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/shared-deploy.yml@main
with:
  image_version: "v1.0.0"
  environment: "production"
```

### **shared-validate-deployment.yml**
Validaciones de deployment.
```yaml
uses: carlosorbegoso/workflow-templates/.github/workflows/shared-validate-deployment.yml@main
with:
  allowed_branches: "main,master,develop"
  require_production_branch: true
```

## 📊 Ventajas de esta organización

### ✅ **Claridad**
- Separación clara entre producción y desarrollo
- Fácil encontrar el workflow que necesitas
- Propósito evidente de cada archivo

### ✅ **Mantenibilidad**
- Archivos más pequeños y enfocados
- Cambios aislados por responsabilidad
- Menos conflictos en el código

### ✅ **Reutilización**
- Componentes modulares
- Workflows especializados
- Fácil composición de pipelines

### ✅ **Escalabilidad**
- Fácil agregar nuevos workflows
- Estructura extensible
- Organización que crece con el proyecto

## 🔄 Migración

### **Para proyectos existentes:**
1. Cambia las referencias en tus workflows:
   ```yaml
   # Antes
   uses: carlosorbegoso/workflow-templates/.github/workflows/test.yml@main
   
   # Después  
   uses: carlosorbegoso/workflow-templates/.github/workflows/development/test.yml@main
   ```

2. Usa el smart-pipeline como punto de entrada principal
3. Considera usar componentes modulares para casos específicos

### **Para proyectos nuevos:**
1. Usa `smart-pipeline.yml` como base
2. Personaliza según tus necesidades
3. Aprovecha los componentes modulares