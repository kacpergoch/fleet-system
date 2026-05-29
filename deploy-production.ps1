param(
    [string]$EnvFile = ".env.prod",
    [string]$ComposeFile = "docker-compose.prod.yml"
)

$ErrorActionPreference = 'Stop'

Write-Host "Fleet System — Deploy production stack"
Write-Host "Env file: $EnvFile"
Write-Host "Compose file: $ComposeFile"

if (-not (Test-Path $EnvFile)) {
    Write-Host "Env file not found: $EnvFile" -ForegroundColor Red
    exit 2
}

if (-not (Test-Path $ComposeFile)) {
    Write-Host "Compose file not found: $ComposeFile" -ForegroundColor Red
    exit 2
}

Write-Host "Pulling images..." -ForegroundColor Green
docker compose -f $ComposeFile --env-file $EnvFile pull

Write-Host "Starting services (detached)..." -ForegroundColor Green
docker compose -f $ComposeFile --env-file $EnvFile up -d

Write-Host "Checking status..." -ForegroundColor Green
docker compose -f $ComposeFile --env-file $EnvFile ps

Write-Host "Deployment finished." -ForegroundColor Cyan

