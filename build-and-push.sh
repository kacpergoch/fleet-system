#!/usr/bin/env bash
# Fleet System — Build and push images to GHCR (bash)
# Usage:
#   GITHUB_USER=myuser IMAGE_TAG=1.0.0 PERSONAL_ACCESS_TOKEN=ghp_xxx ./build-and-push.sh
# or
#   ./build-and-push.sh -u myuser -t 1.0.0 -p ghp_xxx

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 -u GITHUB_USER -t IMAGE_TAG -p PERSONAL_ACCESS_TOKEN
Or set env vars: GITHUB_USER, IMAGE_TAG, PERSONAL_ACCESS_TOKEN

This script builds images using docker compose, tags them for GHCR and pushes them.
EOF
  exit 1
}

GITHUB_USER=${GITHUB_USER:-}
IMAGE_TAG=${IMAGE_TAG:-}
PERSONAL_ACCESS_TOKEN=${PERSONAL_ACCESS_TOKEN:-}

while getopts ":u:t:p:h" opt; do
  case $opt in
    u) GITHUB_USER="$OPTARG" ;;
    t) IMAGE_TAG="$OPTARG" ;;
    p) PERSONAL_ACCESS_TOKEN="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

if [ -z "$GITHUB_USER" ] || [ -z "$IMAGE_TAG" ] || [ -z "$PERSONAL_ACCESS_TOKEN" ]; then
  usage
fi

REGISTRY="ghcr.io/${GITHUB_USER}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Fleet System — Build & Push to GHCR"
echo "Registry: ${REGISTRY}"
echo "Image tag: ${IMAGE_TAG}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "[1/4] Building images..."
# pass VITE_API_BASE explicitly to ensure frontend uses /api in production build
docker compose build --build-arg VITE_API_BASE=/api

echo "[2/4] Tagging images..."
docker tag fleet-system-backend:latest "${REGISTRY}/fleet-backend:${IMAGE_TAG}"
docker tag fleet-system-frontend:latest "${REGISTRY}/fleet-frontend:${IMAGE_TAG}"

echo "[3/4] Logging in to GHCR..."
echo "$PERSONAL_ACCESS_TOKEN" | docker login ghcr.io -u "$GITHUB_USER" --password-stdin

echo "[4/4] Pushing images to GHCR..."
docker push "${REGISTRY}/fleet-backend:${IMAGE_TAG}"
docker push "${REGISTRY}/fleet-frontend:${IMAGE_TAG}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Done."
echo "Backend:  ${REGISTRY}/fleet-backend:${IMAGE_TAG}"
echo "Frontend: ${REGISTRY}/fleet-frontend:${IMAGE_TAG}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Next steps (example):"
echo "  1. Prepare .env.prod with REGISTRY_HOST=${REGISTRY} and IMAGE_TAG=${IMAGE_TAG}"
echo "  2. On production server:"
echo "     docker compose -f docker-compose.prod.yml --env-file .env.prod pull"
echo "     docker compose -f docker-compose.prod.yml --env-file .env.prod up -d"

