# 🎯 Configuración de Ambientes CI/CD

Este documento explica cómo habilitar/deshabilitar el CI/CD para diferentes ambientes.

## 🚀 Opciones de Configuración

### **Opción 1: Solo Producción** (Actual)
```yaml
# En quarkus-service.yml
on:
  push:
    branches: 
      - main
      - master
      # - develop          ← Comentado (deshabilitado)
      # - 'feature/**'     ← Comentado (deshabilitado)
      # - 'hotfix/**'      ← Comentado (deshabilitado)
      # - 'release/**'     ← Comentado (deshabilitado)

jobs:
  adaptive-pipeline:
    # Solo ejecuta en main/master
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master'
```

### **Opción 2: Solo Desarrollo**
```yaml
# En quarkus-service.yml
on:
  push:
    branches: 
      # - main             ← Comentado (deshabilitado)
      # - master           ← Comentado (deshabilitado)
      - develop            ← Habilitado
      - 'feature/**'       ← Habilitado
      - 'hotfix/**'        ← Habilitado
      - 'release/**'       ← Habilitado

jobs:
  adaptive-pipeline:
    # Solo ejecuta en ramas de desarrollo
    if: github.ref == 'refs/heads/develop' || startsWith(github.ref, 'refs/heads/feature/') || startsWith(github.ref, 'refs/heads/hotfix/') || startsWith(github.ref, 'refs/heads/release/')
```

### **Opción 3: Todos los Ambientes**
```yaml
# En quarkus-service.yml
on:
  push:
    branches: 
      - main               ← Habilitado
      - master             ← Habilitado
      - develop            ← Habilitado
      - 'feature/**'       ← Habilitado
      - 'hotfix/**'        ← Habilitado
      - 'release/**'       ← Habilitado

jobs:
  adaptive-pipeline:
    # Ejecuta en todas las ramas (quitar la línea if o usar always())
    # if: always()
```

### **Opción 4: Control Manual**
```yaml
# En quarkus-service.yml
on:
  workflow_dispatch:      # Solo ejecución manual
    inputs:
      environment:
        description: 'Entorno de deploy'
        required: true
        type: choice
        options:
        - production
        - development
        - staging

jobs:
  adaptive-pipeline:
    # Solo ejecuta manualmente
    if: github.event_name == 'workflow_dispatch'
```

## 🔧 Cómo Cambiar la Configuración

### **Para habilitar solo producción:**
1. Abre `examples/quarkus-service.yml`
2. Comenta las ramas que no quieres:
   ```yaml
   branches: 
     - main
     - master
     # - develop          ← Agregar # al inicio
     # - 'feature/**'     ← Agregar # al inicio
   ```
3. Asegúrate que el `if` esté configurado para solo producción

### **Para habilitar todos los ambientes:**
1. Descomenta todas las ramas:
   ```yaml
   branches: 
     - main
     - master
     - develop            ← Quitar # del inicio
     - 'feature/**'       ← Quitar # del inicio
   ```
2. Quita o comenta la línea `if` en el job

### **Para deshabilitar completamente:**
1. Comenta todo el trigger `on:` o
2. Agrega `if: false` al job

## 🎯 Configuraciones Comunes

### **Startup/MVP** (Solo producción)
```yaml
on:
  push:
    branches: [main, master]
  workflow_dispatch:

jobs:
  adaptive-pipeline:
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/master'
```

### **Equipo pequeño** (Producción + manual)
```yaml
on:
  push:
    branches: [main, master]
  workflow_dispatch:

jobs:
  adaptive-pipeline:
    # Sin if - permite manual desde cualquier rama
```

### **Equipo grande** (Todos los ambientes)
```yaml
on:
  push:
    branches: [main, master, develop, 'feature/**', 'hotfix/**']
  pull_request:
    branches: [main, master, develop]

jobs:
  adaptive-pipeline:
    # Sin if - ejecuta en todas las ramas configuradas
```

## ⚡ Pipelines Alternativos por Ambiente

### **Solo para hotfixes urgentes:**
```yaml
# Crear .github/workflows/hotfix.yml
on:
  push:
    branches: ['hotfix/**']

jobs:
  express-deploy:
    uses: carlosorbegoso/workflow-templates/.github/workflows/production-express.yml@main
```

### **Solo para producción turbo:**
```yaml
# Crear .github/workflows/production.yml
on:
  push:
    branches: [main, master]

jobs:
  turbo-deploy:
    uses: carlosorbegoso/workflow-templates/.github/workflows/production-parallel.yml@main
```

## 🚨 Recomendaciones

- **Startup**: Solo producción + manual
- **Desarrollo activo**: Todos los ambientes
- **Mantenimiento**: Solo producción
- **Hotfixes**: Pipeline express separado