#!/usr/bin/env bash
# Fleet System — skrypt przygotowania produkcji dla GHCR
# Uruchom interaktywnie, aby wygenerować `.env.prod` i dostać gotowe komendy.

set -euo pipefail

ask_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read -r -p "$prompt (t/n): " response
        case "$response" in
            [tT]|[tT][aA][kK]|[yY]|[yY][eE][sS]) return 0 ;;
            [nN]|[nN][iI][eE]|[nN][oO]) return 1 ;;
            *) echo "Wpisz 't' albo 'n'." ;;
        esac
    done
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Fleet System — przygotowanie produkcji (GHCR)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -r -p "Podaj nazwę użytkownika GitHub: " github_user
if [ -z "$github_user" ]; then
    echo "Błąd: nazwa użytkownika GitHub nie może być pusta."
    exit 1
fi

read -r -p "Podaj tag obrazu [domyślnie: 1.0.0]: " image_tag
image_tag=${image_tag:-1.0.0}

read -r -p "Podaj port frontendu [domyślnie: 80]: " frontend_port
frontend_port=${frontend_port:-80}

read -r -s -p "Podaj mocne hasło PostgreSQL (min. 20 znaków): " db_password
echo ""
if [ ${#db_password} -lt 20 ]; then
    echo "Błąd: hasło jest za krótkie (minimum 20 znaków)."
    exit 1
fi

registry_host="ghcr.io/$github_user"

echo ""
echo "Podsumowanie konfiguracji:"
echo "  Rejestr:        $registry_host"
echo "  Tag obrazu:     $image_tag"
echo "  Port frontendu: $frontend_port"
echo "  Hasło DB:       ***${#db_password} znaków***"
echo ""

if ! ask_yes_no "Czy chcesz zapisać `.env.prod` z tą konfiguracją?"; then
    echo "Przerwano."
    exit 1
fi

cat > .env.prod <<EOF
# Fleet System — środowisko produkcyjne
# UWAGA: nie commituj tego pliku do gita

REGISTRY_HOST=$registry_host
IMAGE_TAG=$image_tag
FRONTEND_PORT=$frontend_port

POSTGRES_DB=fleet_mgmt
POSTGRES_USER=fleet_admin
POSTGRES_PASSWORD=$db_password
EOF

echo ""
echo "✓ Utworzono `.env.prod`"
echo ""
echo "Dalsze kroki:"
echo ""
echo "1. Zaloguj się do GHCR:"
echo "   echo \"<PAT>\" | docker login ghcr.io -u $github_user --password-stdin"
echo ""
echo "2. Zbuduj i wypchnij obrazy:"
echo "   docker compose build"
echo "   docker tag fleet-system-backend:latest $registry_host/fleet-backend:$image_tag"
echo "   docker tag fleet-system-frontend:latest $registry_host/fleet-frontend:$image_tag"
echo "   docker push $registry_host/fleet-backend:$image_tag"
echo "   docker push $registry_host/fleet-frontend:$image_tag"
echo ""
echo "3. Na serwerze produkcyjnym uruchom:"
echo "   docker compose -f docker-compose.prod.yml --env-file .env.prod pull"
echo "   docker compose -f docker-compose.prod.yml --env-file .env.prod up -d"
echo ""
echo "4. Sprawdź stan:"
echo "   docker compose -f docker-compose.prod.yml ps"
echo ""
echo "Szczegóły: DEPLOY.md"

