# Fleet System — Quick Start Guide

This repository contains the components required to run the Fleet System, including the Docker Compose configuration and the source code for the backend and frontend applications.

Repository layout:
- `fleet-system` — Docker Compose configuration (nginx proxy, PostgreSQL, and service definitions)
- `fleet_mgmt_backend` — Spring Boot backend (Java / Gradle)
- `fleet_mgmt_frontend` — Frontend application (Vue + Vite)

Checklist before proceeding:
- Ensure Docker and Docker Compose are installed for containerized deployment.
- For local development, Java 17+ is required to run the backend; Node.js (recommended Node 20+) and npm are required to run the frontend.

1) Recommended: Run with Docker Compose
Open PowerShell in the `fleet-system` directory and execute:

```powershell
docker compose up -d --build
```

When the stack is running:
- The frontend is served at http://localhost on port 80.
- The backend API is available under the `/api` path; the nginx proxy forwards requests to the backend service.

You may create a `.env` file adjacent to `docker-compose.yml` to override environment variables (for example `POSTGRES_USER` and `POSTGRES_PASSWORD`). The default values are `postgres`.

2) Run the backend locally (without Docker)
Prerequisite: Java 17+.

```powershell
cd ..\fleet_mgmt_backend
.\gradlew.bat bootRun
```

Or build and run the executable JAR:

```powershell
.\gradlew.bat bootJar
java -jar build\libs\fleet_mgmt_backend-1.0-SNAPSHOT.jar
```

The application expects a PostgreSQL database. When running locally, you can either use the database service from Docker Compose or provide the following environment variables:
- SPRING_DATASOURCE_URL (e.g. `jdbc:postgresql://localhost:5432/fleet_mgmt`)
- SPRING_DATASOURCE_USERNAME
- SPRING_DATASOURCE_PASSWORD

3) Run the frontend locally

```powershell
cd ..\fleet_mgmt_frontend
npm install
# If the backend is running locally on port 8080, set the API base URL before starting the dev server:
$env:VITE_API_BASE = "http://localhost:8080/api"
npm run dev
```

Vite's development server typically listens on port 5173; the exact URL will be displayed in the console. When using Docker Compose, the production build of the frontend is served by nginx on port 80.

4) Example `.env`
You can add a `.env` file next to `docker-compose.yml` with the following values if desired:

```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=fleet_mgmt
```

5) Production scripts

For image publication and production deployment, the repository provides the following scripts:

- `build-and-push.ps1` — builds the Docker images and publishes them to GHCR from Windows PowerShell.
- `build-and-push.sh` — performs the same task from Bash.
- `deploy-production.ps1` — pulls the published images and starts the production stack from Windows PowerShell.
- `deploy-production.sh` — performs the same deployment flow from Bash.

Typical usage:

```powershell
.\build-and-push.ps1 -GithubUsername "your-username" -ImageTag "1.0.0" -PersonalAccessToken "ghp_xxx"
.\deploy-production.ps1 -EnvFile ".env.prod" -ComposeFile "docker-compose.prod.yml"
```

```bash
./build-and-push.sh -u your-username -t 1.0.0 -p ghp_xxx
./deploy-production.sh --env-file .env.prod --compose-file docker-compose.prod.yml
```

If the images are public in GHCR, the production host does not need to log in to pull them.

6) `.env.prod` and database password

Yes — `docker compose --env-file .env.prod` is exactly the right place to set production values such as the PostgreSQL password. The file is used at deploy time to inject values into the compose stack.

Example values in `.env.prod`:

```dotenv
IMAGE_TAG=1.0.0
FRONTEND_PORT=80
POSTGRES_DB=fleet_mgmt
POSTGRES_USER=fleet_admin
POSTGRES_PASSWORD=replace_with_a_strong_password
```

7) Useful commands
- Stop services: `docker compose down`
- Follow logs: `docker compose logs -f` or `docker compose logs -f <service>`
- Rebuild and restart: `docker compose up -d --build`

8) Troubleshooting
- If the frontend cannot reach the API: verify `VITE_API_BASE` for local development or confirm that nginx proxy in Docker Compose is correctly configured.
- If the backend fails to start: consult the service logs (`docker compose logs backend`) or Gradle/console output and verify that PostgreSQL is ready and reachable.

If you would like, I can extend this guide with a more detailed `.env` example, instructions for macOS/Linux, or deployment recommendations.

