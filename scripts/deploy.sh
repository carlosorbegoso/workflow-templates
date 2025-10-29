#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOCKER_IMAGE=${DOCKER_IMAGE:-}
PROJECT_NAME=${PROJECT_NAME:-$(basename ${DEPLOY_PATH:-$(pwd)})}
DEPLOY_PATH=${DEPLOY_PATH:-$(pwd)}

echo -e "${BLUE}=== Deploy Script Started ===${NC}"
echo -e "${BLUE}Docker Image: ${DOCKER_IMAGE}${NC}"
echo -e "${BLUE}Project Name: ${PROJECT_NAME}${NC}"
echo -e "${BLUE}Deploy Path: ${DEPLOY_PATH}${NC}"

if [ -z "$DOCKER_IMAGE" ]; then
  echo -e "${RED}ERROR: DOCKER_IMAGE not defined${NC}"
  echo -e "${YELLOW}Usage: DOCKER_IMAGE=image:tag PROJECT_NAME=name ./deploy.sh${NC}"
  exit 1
fi

if [ ! -d "$DEPLOY_PATH" ]; then
  echo -e "${RED}ERROR: DEPLOY_PATH does not exist: $DEPLOY_PATH${NC}"
  exit 1
fi

cd "$DEPLOY_PATH"

if [ ! -f "docker-compose.yml" ]; then
  echo -e "${RED}ERROR: docker-compose.yml not found in $DEPLOY_PATH${NC}"
  echo -e "${YELLOW}TIP: Create a docker-compose.yml based on docker-compose.example.yml${NC}"
  exit 1
fi

# Exportar variables para docker-compose
export DOCKER_IMAGE="$DOCKER_IMAGE"
export PROJECT_NAME="$PROJECT_NAME"
export COMPOSE_PROJECT_NAME="$PROJECT_NAME"

echo -e "${YELLOW}Pulling image: $DOCKER_IMAGE${NC}"
if ! docker pull "$DOCKER_IMAGE"; then
  echo -e "${RED}ERROR: Failed to pull image $DOCKER_IMAGE${NC}"
  echo -e "${YELLOW}TIP: Verify the image exists and you have access permissions${NC}"
  exit 1
fi

echo -e "${YELLOW}Stopping previous container...${NC}"
docker-compose down || true

echo -e "${YELLOW}Starting new container...${NC}"
if ! docker-compose up -d; then
  echo -e "${RED}ERROR: Failed to start the container${NC}"
  echo -e "${YELLOW}Container logs:${NC}"
  docker-compose logs
  exit 1
fi

echo -e "${YELLOW}Waiting for the container to be ready...${NC}"
sleep 10

echo -e "${YELLOW}Checking status...${NC}"
if docker-compose ps | grep -q "Up"; then
  echo -e "${GREEN}SUCCESS: $PROJECT_NAME deployed successfully${NC}"

  # Show container information
  echo -e "${BLUE}Container status:${NC}"
  docker-compose ps

  # Show exposed ports
  echo -e "${BLUE}Exposed ports:${NC}"
  docker-compose port app 8080 2>/dev/null || echo "Port 8080 not exposed"

else
  echo -e "${RED}ERROR: $PROJECT_NAME is not running${NC}"
  echo -e "${YELLOW}Container logs:${NC}"
  docker-compose logs
  exit 1
fi

echo -e "${YELLOW}Cleaning up unused images...${NC}"
docker image prune -f --filter "dangling=true" || true

echo -e "${GREEN}Deploy completed successfully${NC}"
echo -e "${BLUE}=== Deploy Script Finished ===${NC}"