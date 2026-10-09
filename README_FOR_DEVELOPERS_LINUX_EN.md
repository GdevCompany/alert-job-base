# Running alert-job for development (Linux)

The platform is split into **multiple git repositories**. All `alert-job-*` folders must be **siblings** under one parent directory (e.g. `~/projects/`).

The legacy monorepo `alert-job` on GitHub is deprecated for day-to-day work; clone the repos below.

## 1. Prerequisites

| Tool | Version |
|------|---------|
| JDK | **25** (`JAVA_HOME`) |
| Maven | 3.9+ |
| Node.js + npm | LTS |
| Docker | Keycloak and full stack |
| Git | |

## 2. Clone repositories

```bash
mkdir -p ~/projects && cd ~/projects
ORG=https://github.com/gdevby
for r in alert-job-base alert-job-common alert-job-core alert-job-parser \
  alert-job-notification alert-job-llm alert-job-gateway alert-job-config \
  alert-job-config-repo alert-job-front alert-job-deploy; do
  git clone "$ORG/$r.git" "$r"
done
```

| Repository | Role |
|------------|------|
| `alert-job-base` | Maven parent (`pom.xml`), `config/`, docs |
| `alert-job-common` | shared Java library |
| `alert-job-*` services | microservices |
| `alert-job-front` | React (Vite) |
| `alert-job-deploy` | **docker-compose**, dev Keycloak image |
| `alert-job-config-repo` | Spring Cloud Config files |

## 3. Build Java (before IDE)

```bash
export JAVA_HOME=/path/to/jdk-25

cd ~/projects/alert-job-base
mvn -N install

cd ../alert-job-common
mvn install -DskipTests -Ddocker.skip=true

cd ../alert-job-notification
mvn package -DskipTests -Ddocker.skip=true
```

Order: **base → common → service**.

## 4. Frontend

```bash
cd ~/projects/alert-job-front
cp .env.example .env
npm ci
npm run build
```

Nginx static root: `~/projects/alert-job-front/dist`.

## 5. Environment variables

```bash
cd ~/projects/alert-job-deploy
cp env_sample.properties .env
openssl rand -hex 16   # set APP_ENCRYPTION_KEY in .env
```

## 6. Keycloak (dev)

```bash
cd ~/projects/alert-job-deploy/keycloak
chmod +x build.sh && ./build.sh
```

## 7. Docker

Run compose **only** from `alert-job-deploy`:

```bash
cd ~/projects/alert-job-deploy
docker compose build keycloak
docker compose up -d keycloak
```

Full stack: `docker compose up` (requires images from `rg.gdev.by` or local CI builds).  
Mounts: `../alert-job-base/config`, `../alert-job-config-repo`.

## 8. Config Server

**Option A — Docker compose** (recommended): `alert-job-config-repo` is already mounted.

**Option B — config from IDE:** in `alert-job-config`, set `spring.profiles.active=dev,native` and  
`spring.cloud.config.server.native.search-locations=file:///home/USER/projects/alert-job-config-repo`.

## 9. Hosts file

```
127.0.0.1 config keycloak gateway notification parser core llm
127.0.0.1 auth.alertjob.by alertjob.by
```

Port **80** must be free.

## 10. Nginx

Install nginx, add a server block proxying `/` → `127.0.0.1:8015`, `/keycloak` → `8080`, `/front/` → `alert-job-front/dist` (see Russian doc for full sample `aj.conf`).

## 11. Run from IDE (IntelliJ IDEA)

1. JDK **25**; `mvn -N install` in `alert-job-base`, then build `alert-job-common`.
2. Open a service repo or `alert-job-base.code-workspace`.
3. Start services in order: **config → gateway → parser → core → notification → llm**.

Open [http://alertjob.by](http://alertjob.by).

## 12. Test account

- Login: `test`  
- Password: `test`

## 13. Build artifacts

Do not commit `node_modules`, `target`, or `dist` (see `.gitignore` in each repo).
