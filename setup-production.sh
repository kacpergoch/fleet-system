#!/usr/bin/env bash
# Fleet System - production setup for GHCR

set -euo pipefail

echo "-----------------------------------------------"
echo "Fleet System - production setup (GHCR)"
echo "-----------------------------------------------"
echo ""

read -r -p "Enter your GitHub username: " github_user
if [ -z "$github_user" ]; then
    echo "Error: GitHub username cannot be empty."
    exit 1
fi

read -r -p "Enter image tag [default: 1.0.0]: " image_tag
image_tag=${image_tag:-1.0.0}

read -r -p "Enter frontend port [default: 80]: " frontend_port
frontend_port=${frontend_port:-80}

read -r -s -p "Enter a strong PostgreSQL password (min 20 chars): " db_password
echo ""
if [ ${#db_password} -lt 20 ]; then
    echo "Error: password is too short (minimum 20 characters)."
    exit 1
fi

registry_host="ghcr.io/$github_user"

echo ""
echo "Configuration summary:"
echo "  Registry:      $registry_host"
echo "  Image tag:     $image_tag"
echo "  Frontend port: $frontend_port"
echo "  DB password:   ***${#db_password} characters***"
echo ""

cat > .env.prod <<EOF
# Fleet System - production environment
# Do not commit this file to git

REGISTRY_HOST=$registry_host
IMAGE_TAG=$image_tag
FRONTEND_PORT=$frontend_port

POSTGRES_DB=fleet_mgmt
POSTGRES_USER=fleet_admin
POSTGRES_PASSWORD=$db_password
EOF

echo ""
echo "OK: created .env.prod"
echo ""
echo "Next steps:"
echo ""
echo "1. Log in to GHCR:"
echo "   echo \"<PAT>\" | docker login ghcr.io -u $github_user --password-stdin"
echo ""
echo "2. Build and push images:"
echo "   docker compose build"
echo "   docker tag fleet-system-backend:latest $registry_host/fleet-backend:$image_tag"
echo "   docker tag fleet-system-frontend:latest $registry_host/fleet-frontend:$image_tag"
echo "   docker push $registry_host/fleet-backend:$image_tag"
echo "   docker push $registry_host/fleet-frontend:$image_tag"
echo ""
echo "3. On the production server run:"
echo "   docker compose -f docker-compose.prod.yml --env-file .env.prod pull"
echo "   docker compose -f docker-compose.prod.yml --env-file .env.prod up -d"
echo ""
echo "4. Verify status:"
echo "   docker compose -f docker-compose.prod.yml ps"
echo ""
echo "Details: DEPLOY.md"

