#!/bin/bash

# Script específico para verificar yape-hub
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== YAPE-HUB CHECK ===${NC}"
echo ""

# 1. Verify on the server
echo -e "${YELLOW}1. Checking server...${NC}"
DEPLOY_PATH="/opt/apps/yape-hub"  # Adjust if different

if [ -d "$DEPLOY_PATH" ]; then
    echo -e "${GREEN}✓ Directory exists: $DEPLOY_PATH${NC}"
    echo "Contents:"
    ls -la "$DEPLOY_PATH"
else
    echo -e "${RED}✗ Directory does not exist: $DEPLOY_PATH${NC}"
    echo "Available directories in /opt/apps:"
    ls -la /opt/apps/ 2>/dev/null || echo "Cannot access /opt/apps"
    exit 1
fi

echo ""

# 2. Verify docker-compose.yml
echo -e "${YELLOW}2. Checking docker-compose.yml...${NC}"
if [ -f "$DEPLOY_PATH/docker-compose.yml" ]; then
    echo -e "${GREEN}✓ docker-compose.yml exists${NC}"
    echo "Variables used:"
    grep -E '\$\{[^}]+\}' "$DEPLOY_PATH/docker-compose.yml" || echo "No variables found"
else
    echo -e "${RED}✗ docker-compose.yml DOES NOT EXIST${NC}"
    echo "This is likely the main problem"
fi

echo ""

# 3. Verify Docker image
echo -e "${YELLOW}3. Checking Docker image...${NC}"
echo "Looking for yape-hub images:"
docker images | grep yape-hub || echo "No local images found"

echo ""
echo "Attempting manual image pull:"
if docker pull ghcr.io/carlosorbegoso/yape-hub:v1.0.0; then
    echo -e "${GREEN}✓ Manual pull succeeded${NC}"
else
    echo -e "${RED}✗ Manual pull failed${NC}"
    echo "Check:"
    echo "1. Does the image exist on GHCR?"
    echo "2. Do you have permissions to access it?"
    echo "3. Are you authenticated with GHCR?"
fi

echo ""

# 4. Verify current status
echo -e "${YELLOW}4. Checking current status...${NC}"
cd "$DEPLOY_PATH" 2>/dev/null || exit 1

if docker-compose ps 2>/dev/null; then
    echo -e "${GREEN}Container status:${NC}"
    docker-compose ps
else
    echo -e "${RED}✗ Cannot obtain container status${NC}"
fi

echo ""

# 5. Attempt manual deployment
echo -e "${YELLOW}5. Do you want to attempt a manual deployment? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Setting environment variables..."
    export DOCKER_IMAGE="ghcr.io/carlosorbegoso/yape-hub:v1.0.0"
    export APP_NAME="yape-hub"
    export PROJECT_NAME="yape-hub"
    
    echo "Variables set:"
    echo "DOCKER_IMAGE=$DOCKER_IMAGE"
    echo "APP_NAME=$APP_NAME"
    echo "PROJECT_NAME=$PROJECT_NAME"
    
    echo ""
    echo "Attempting docker-compose pull..."
    if docker-compose pull; then
        echo -e "${GREEN}✓ Pull succeeded${NC}"
        echo ""
        echo "Attempting docker-compose up..."
        if docker-compose up -d; then
            echo -e "${GREEN}✓ Manual deployment succeeded${NC}"
            echo "Checking status:"
            docker-compose ps
        else
            echo -e "${RED}✗ Manual deployment failed${NC}"
            echo "Logs:"
            docker-compose logs
        fi
    else
        echo -e "${RED}✗ Manual pull failed${NC}"
        echo "Check the docker-compose.yml and variables"
    fi
fi

echo ""
echo -e "${BLUE}=== CHECK COMPLETE ===${NC}"