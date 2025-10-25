# 📁 Ejemplos de Uso

Esta carpeta contiene ejemplos prácticos de cómo usar los workflows.

## 📋 Archivos disponibles:

### 🔄 Para migrar desde workflow existente:
- **`migration-guide.md`** - Guía completa de migración paso a paso
- **`microservice-workflow.yml`** - Archivo listo para copiar

### 🆕 Para proyectos nuevos:
- **`microservice-workflow.yml`** - Workflow completo para microservicios

## 🚀 Uso rápido:

### Si ya tienes un workflow:
1. Lee `migration-guide.md`
2. Copia `microservice-workflow.yml` a tu proyecto
3. Reemplaza tu workflow actual

### Si es un proyecto nuevo:
1. Copia `microservice-workflow.yml` como `.github/workflows/ci-cd.yml`
2. Configura los secrets necesarios
3. Haz push y listo

## 🎯 Comportamiento automático:

| Evento | Rama | Tiempo | Acciones |
|--------|------|--------|----------|
| Pull Request | cualquiera | 3-5 min | Solo tests básicos |
| Push | `main` | 5-8 min | Build → Deploy (producción) |
| Push | `develop`, `feature/*` | 15-20 min | Tests → Quality → Build → Deploy |

## 📞 ¿Necesitas ayuda?

- Revisa `migration-guide.md` para migración detallada
- Los workflows son inteligentes y se adaptan automáticamente
- Si no tienes secrets de desarrollo, usa los de producción