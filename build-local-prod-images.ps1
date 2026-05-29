param(
    [string] $RegistryHost = 'ghcr.io/kacpergoch',
    [string] $ImageTag = 'latest'
)

# Build backend image and tag it as the production name
$backendDir = Join-Path $PSScriptRoot '..\fleet_mgmt_backend'
Write-Host "Building backend from: $backendDir"
docker build -t "$RegistryHost/fleet-backend:$ImageTag" -f (Join-Path $backendDir 'Dockerfile') $backendDir

# Build frontend image and tag it as the production name
$frontendDir = Join-Path $PSScriptRoot '..\fleet_mgmt_frontend'
Write-Host "Building frontend from: $frontendDir"
docker build --build-arg VITE_API_BASE=/api -t "$RegistryHost/fleet-frontend:$ImageTag" -f (Join-Path $frontendDir 'Dockerfile') $frontendDir

Write-Host "Built images:"
docker images --filter=reference="$RegistryHost/*:$ImageTag"

Write-Host "You can now run the production compose file which will use these locally-built images:"
Write-Host "  docker compose -f docker-compose.prod.yml --env-file .env.prod up -d"


