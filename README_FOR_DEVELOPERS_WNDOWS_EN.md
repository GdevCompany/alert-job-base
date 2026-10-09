# Running alert-job for development (Windows)

The platform uses **multiple git repositories**. Keep all `alert-job-*` folders as **siblings** (e.g. `D:\projects\`).

The legacy `alert-job` monorepo is not the primary workflow; clone the repos listed below.

## 1. Prerequisites

| Tool | Version |
|------|---------|
| JDK | **25** (`JAVA_HOME`) |
| Maven | 3.9+ |
| Node.js | LTS ([nvm-windows](https://github.com/coreybutler/nvm-windows/releases) optional) |
| Docker Desktop | |
| Git | |

## 2. Clone repositories

Clone the same repo list as in the Linux guide (`gdevby/alert-job-base`, `alert-job-common`, …, `alert-job-deploy`, `alert-job-config-repo`) as sibling folders.

## 3. Build Java

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-25"
cd D:\projects\alert-job-base; mvn -N install
cd ..\alert-job-common; mvn install -DskipTests -Ddocker.skip=true
cd ..\alert-job-notification; mvn package -DskipTests -Ddocker.skip=true
```

Order: **base → common → service**.

## 4. Frontend

```powershell
cd D:\projects\alert-job-front
copy .env.example .env
npm ci
npm run build
```

## 5. Environment variables

```powershell
cd D:\projects\alert-job-deploy
copy env_sample.properties .env
```

Set `APP_ENCRYPTION_KEY` (e.g. `openssl rand -hex 16` in Git Bash).

## 6. Keycloak (dev)

```powershell
cd D:\projects\alert-job-deploy\keycloak
docker build -t alert-job/alert-job-keycloak:0.1 .
```

## 7. Docker

From **`alert-job-deploy` only**:

```powershell
docker compose build keycloak
docker compose up -d keycloak
```

Full stack: `docker compose up`. Requires sibling `alert-job-base` and `alert-job-config-repo`.

## 8. Config Server

IDE: `dev,native` profile and  
`spring.cloud.config.server.native.search-locations=file:///D:/projects/alert-job-config-repo`  
in `alert-job-config`. Docker compose mounts config-repo automatically.

## 9. Hosts file

`C:\Windows\System32\drivers\etc\hosts`:

```
127.0.0.1 config keycloak gateway notification parser core llm
127.0.0.1 auth.alertjob.by alertjob.by
```

## 10. Nginx (optional)

Windows nginx: proxy `/` → gateway `8015`, `/keycloak` → `8080`, `/front/` → `D:/projects/alert-job-front/dist`.

## 11. IntelliJ IDEA

JDK **25**; install parent + common; start **config → gateway → parser → core → notification → llm**.  
Workspace: `alert-job-base/alert-job-base.code-workspace`.

## 12. Test account

Login `test`, password `test`.

## 13. Build artifacts

Do not commit `node_modules`, `target`, or `dist` (`.gitignore` in each repo).

For detailed Windows steps in Russian (nginx, ExecutionPolicy), see `README_FOR_DEVELOPERS_WINDOWS_RU.md`.
