#!/usr/bin/env bash
# Fleet System — Deploy production stack (bash)
# Usage: ./deploy-production.sh --env-file .env.prod --compose-file docker-compose.prod.yml

set -euo pipefail

ENV_FILE=${ENV_FILE:-.env.prod}
COMPOSE_FILE=${COMPOSE_FILE:-docker-compose.prod.yml}

usage() {
  cat <<EOF
Usage: $0 [--env-file PATH] [--compose-file PATH]
Defaults: --env-file .env.prod --compose-file docker-compose.prod.yml

This script pulls images defined in the compose file (using the provided env file)
and starts the services (detached). Intended to be run on the production host.
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --env-file) ENV_FILE="$2"; shift 2 ;;
    --compose-file) COMPOSE_FILE="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [ ! -f "$ENV_FILE" ]; then
  echo "Env file not found: $ENV_FILE" >&2
  exit 2
fi

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Compose file not found: $COMPOSE_FILE" >&2
  exit 2
fi

echo "Using env file: $ENV_FILE"
echo "Using compose file: $COMPOSE_FILE"

echo "Pulling images..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull

echo "Starting services..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d

echo "Checking status..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" ps

echo "Deployment finished."

