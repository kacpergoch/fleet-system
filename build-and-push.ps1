# Fleet System - Production Build and Push to GHCR
# Usage: .\build-and-push.ps1 -GithubUsername "your-username" -ImageTag "1.0.0" -PersonalAccessToken "ghp_xxx..."

param(
    [Parameter(Mandatory = $true)]
    [string]$GithubUsername,

    [Parameter(Mandatory = $true)]
    [string]$ImageTag,

    [Parameter(Mandatory = $true)]
    [string]$PersonalAccessToken
)

$ErrorActionPreference = "Stop"

$Registry = "ghcr.io/$GithubUsername"

Write-Host "-----------------------------------------------" -ForegroundColor Cyan
Write-Host "Fleet System - Build and Push to GHCR" -ForegroundColor Cyan
Write-Host "-----------------------------------------------" -ForegroundColor Cyan
Write-Host ""
Write-Host "Registry: $Registry" -ForegroundColor Yellow
Write-Host "Image Tag: $ImageTag" -ForegroundColor Yellow
Write-Host ""

Write-Host "[1/4] Building images..." -ForegroundColor Green
docker compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/4] Tagging images..." -ForegroundColor Green
docker tag fleet-system-backend:latest "$Registry/fleet-backend:$ImageTag"
docker tag fleet-system-frontend:latest "$Registry/fleet-frontend:$ImageTag"
Write-Host "Tagged as: $Registry/fleet-backend:$ImageTag" -ForegroundColor Cyan
Write-Host "Tagged as: $Registry/fleet-frontend:$ImageTag" -ForegroundColor Cyan

Write-Host ""
Write-Host "[3/4] Logging in to GHCR..." -ForegroundColor Green
$PersonalAccessToken | docker login ghcr.io -u $GithubUsername --password-stdin
if ($LASTEXITCODE -ne 0) {
    Write-Host "GHCR login failed!" -ForegroundColor Red
    exit 1
}

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

Write-Host ""
Write-Host "-----------------------------------------------" -ForegroundColor Cyan
Write-Host "Images are ready for deployment!" -ForegroundColor Green
Write-Host "-----------------------------------------------" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend:  $Registry/fleet-backend:$ImageTag" -ForegroundColor Cyan
Write-Host "Frontend: $Registry/fleet-frontend:$ImageTag" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Update .env.prod:" -ForegroundColor Yellow
Write-Host "     REGISTRY_HOST=$Registry" -ForegroundColor Gray
Write-Host "     IMAGE_TAG=$ImageTag" -ForegroundColor Gray
Write-Host "     POSTGRES_PASSWORD=<strong_password>" -ForegroundColor Gray
Write-Host "  2. On the production server:" -ForegroundColor Yellow
Write-Host "     docker compose -f docker-compose.prod.yml --env-file .env.prod pull" -ForegroundColor Gray
Write-Host "     docker compose -f docker-compose.prod.yml --env-file .env.prod up -d" -ForegroundColor Gray
Write-Host "  3. Verify:" -ForegroundColor Yellow
Write-Host "     docker compose -f docker-compose.prod.yml ps" -ForegroundColor Gray
Write-Host "-----------------------------------------------" -ForegroundColor Cyan
