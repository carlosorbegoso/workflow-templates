#!/bin/bash

# Script de validación para builds de Quarkus
# Detecta configuraciones y problemas comunes antes del build

set -e

echo "🔍 Validating build configuration..."

# Detectar herramienta de build
if [ -f "pom.xml" ]; then
    BUILD_TOOL="maven"
    echo "✅ Build tool: Maven"
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
    BUILD_TOOL="gradle"
    echo "✅ Build tool: Gradle"
else
    echo "❌ ERROR: No build tool found (pom.xml or build.gradle)"
    exit 1
fi

# Validar estructura de proyecto Quarkus
if [ ! -d "src/main/java" ]; then
    echo "❌ ERROR: src/main/java directory not found"
    exit 1
fi

echo "✅ Project structure: Valid"

# Validar Dockerfiles
DOCKERFILE_NATIVE="src/main/docker/Dockerfile.native"
DOCKERFILE_JVM="src/main/docker/Dockerfile.jvm"

if [ -f "$DOCKERFILE_NATIVE" ]; then
    echo "✅ Dockerfile.native: Found"
else
    echo "⚠️  WARNING: Dockerfile.native not found - native builds may fail"
fi

if [ -f "$DOCKERFILE_JVM" ]; then
    echo "✅ Dockerfile.jvm: Found"
else
    echo "⚠️  WARNING: Dockerfile.jvm not found - JVM builds may fail"
fi

# Validar configuración específica por herramienta
if [ "$BUILD_TOOL" = "maven" ]; then
    echo "🔍 Validating Maven configuration..."
    
    # Verificar perfiles
    if ./mvnw help:all-profiles | grep -q "native"; then
        echo "✅ Maven native profile: Found"
    else
        echo "⚠️  WARNING: No native profile found in pom.xml"
        echo "   Add this to your pom.xml:"
        echo "   <profiles>"
        echo "     <profile>"
        echo "       <id>native</id>"
        echo "       <properties>"
        echo "         <quarkus.package.type>native</quarkus.package.type>"
        echo "       </properties>"
        echo "     </profile>"
        echo "   </profiles>"
    fi
    
    # Verificar dependencias de Quarkus
    if ./mvnw dependency:list | grep -q "quarkus"; then
        echo "✅ Quarkus dependencies: Found"
    else
        echo "❌ ERROR: No Quarkus dependencies found"
        exit 1
    fi

elif [ "$BUILD_TOOL" = "gradle" ]; then
    echo "🔍 Validating Gradle configuration..."
    
    # Listar tareas disponibles
    echo "📋 Available Gradle tasks:"
    AVAILABLE_TASKS=$(./gradlew tasks --all --quiet | grep -E "^[a-zA-Z]" | awk '{print $1}')
    
    # Verificar tareas esenciales
    if echo "$AVAILABLE_TASKS" | grep -q "^build$"; then
        echo "✅ Gradle build task: Found"
    else
        echo "❌ ERROR: No build task found"
        exit 1
    fi
    
    # Verificar plugin de Quarkus
    if ./gradlew properties | grep -q "quarkus"; then
        echo "✅ Quarkus plugin: Found"
    else
        echo "❌ ERROR: Quarkus plugin not found"
        echo "   Add this to your build.gradle:"
        echo "   plugins {"
        echo "     id 'io.quarkus' version 'X.X.X'"
        echo "   }"
        exit 1
    fi
    
    # Mostrar tareas que se pueden excluir
    EXCLUDABLE_TASKS=""
    for task in "javadoc" "checkstyleMain" "checkstyleTest" "spotbugsMain" "pmdMain"; do
        if echo "$AVAILABLE_TASKS" | grep -q "^${task}$"; then
            EXCLUDABLE_TASKS="$EXCLUDABLE_TASKS -x $task"
        fi
    done
    
    if [ -n "$EXCLUDABLE_TASKS" ]; then
        echo "📝 Recommended exclusions for faster builds: $EXCLUDABLE_TASKS"
    fi
fi

# Verificar configuración de aplicación
APP_PROPS="src/main/resources/application.properties"
APP_YML="src/main/resources/application.yml"

if [ -f "$APP_PROPS" ] || [ -f "$APP_YML" ]; then
    echo "✅ Application configuration: Found"
else
    echo "⚠️  WARNING: No application.properties or application.yml found"
fi

# Verificar memoria disponible para builds nativos
AVAILABLE_MEMORY=$(free -m | awk 'NR==2{printf "%.0f", $7}')
if [ "$AVAILABLE_MEMORY" -lt 4000 ]; then
    echo "⚠️  WARNING: Low memory ($AVAILABLE_MEMORY MB available)"
    echo "   Native builds require at least 4GB of RAM"
    echo "   Consider using JVM builds for development"
fi

echo ""
echo "🎯 Build recommendations:"
echo "   - For development: Use JVM builds (faster)"
echo "   - For production: Use native builds (smaller, faster startup)"
echo "   - Use caching to speed up subsequent builds"
echo ""
echo "✅ Validation completed!"