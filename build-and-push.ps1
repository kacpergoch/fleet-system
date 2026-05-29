# Fleet System — Production Build & Push to GHCR
# Usage: .\build-and-push.ps1 -GithubUsername "your-username" -ImageTag "1.0.0" -PersonalAccessToken "ghp_xxx..."

param(
    [Parameter(Mandatory=$true)]
    [string]$GithubUsername,

    [Parameter(Mandatory=$true)]
    [string]$ImageTag,

    [Parameter(Mandatory=$true)]
    [string]$PersonalAccessToken
)

$ErrorActionPreference = "Stop"

$Registry = "ghcr.io/$GithubUsername"

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Fleet System — Build & Push to GHCR" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "Registry: $Registry" -ForegroundColor Yellow
Write-Host "Image Tag: $ImageTag" -ForegroundColor Yellow
Write-Host ""

# Step 1: Build
Write-Host "[1/4] Building images..." -ForegroundColor Green
docker compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Step 2: Tag
Write-Host ""
Write-Host "[2/4] Tagging images..." -ForegroundColor Green
docker tag fleet-system-backend:latest "$Registry/fleet-backend:$ImageTag"
docker tag fleet-system-frontend:latest "$Registry/fleet-frontend:$ImageTag"
Write-Host "Tagged as: $Registry/fleet-backend:$ImageTag" -ForegroundColor Cyan
Write-Host "Tagged as: $Registry/fleet-frontend:$ImageTag" -ForegroundColor Cyan

# Step 3: Login to GHCR
Write-Host ""
Write-Host "[3/4] Logging in to GHCR..." -ForegroundColor Green
$PersonalAccessToken | docker login ghcr.io -u $GithubUsername --password-stdin
if ($LASTEXITCODE -ne 0) {
    Write-Host "GHCR login failed!" -ForegroundColor Red
    exit 1
}

# Step 4: Push
Write-Host ""
Write-Host "[4/4] Pushing images to GHCR..." -ForegroundColor Green

docker push "$Registry/fleet-backend:$ImageTag"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Push backend failed!" -ForegroundColor Red
    exit 1
}

docker push "$Registry/fleet-frontend:$ImageTag"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Push frontend failed!" -ForegroundColor Red
    exit 1
}

# Step 5: Success
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "✓ Obrazy gotowe do wdrażania!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend:  $Registry/fleet-backend:$ImageTag" -ForegroundColor Cyan
Write-Host "Frontend: $Registry/fleet-frontend:$ImageTag" -ForegroundColor Cyan
Write-Host ""
Write-Host "Następne kroki:" -ForegroundColor Cyan
Write-Host "  1. Zaktualizuj .env.prod:" -ForegroundColor Yellow
Write-Host "     REGISTRY_HOST=$Registry" -ForegroundColor Gray
Write-Host "     IMAGE_TAG=$ImageTag" -ForegroundColor Gray
Write-Host "     POSTGRES_PASSWORD=<mocne_hasło>" -ForegroundColor Gray
Write-Host "  2. Na serwerze produkcyjnym:" -ForegroundColor Yellow
Write-Host "     docker compose -f docker-compose.prod.yml --env-file .env.prod pull" -ForegroundColor Gray
Write-Host "     docker compose -f docker-compose.prod.yml --env-file .env.prod up -d" -ForegroundColor Gray
Write-Host "  3. Zweryfikuj:" -ForegroundColor Yellow
Write-Host "     docker compose -f docker-compose.prod.yml ps" -ForegroundColor Gray
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
