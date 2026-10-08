# alert-job — мультирепо

Каталог `alert-job-splitted/` на диске — **только раскладка** соседних клонов, **не** git-репозиторий. В git не пушится.

Каждая папка `alert-job-*` ниже — **отдельный git-репозиторий** для push на GitHub и деплоя. Исходный монорепо: `D:\TEMP\projects\gdev\alert-job` (репо **`alert-job`**).

## Репозитории

| Папка | Назначение |
|-------|------------|
| `alert-job-base` | Maven parent (`pom.xml`), `config/` для nginx/prometheus/БД, документация, workspace |
| `alert-job-common` | Библиотека `common-alert-job` |
| `alert-job-core`, `parser`, `notification`, `llm`, `gateway`, `config` | Java-сервисы |
| `alert-job-front` | Frontend |
| `alert-job-deploy` | **Единственный** источник `docker-compose*.yml`, Dockerfile, `keycloak/` |
| `alert-job-config-repo` | Spring Cloud Config (properties/yml), сосед `alert-job-deploy` |

Отдельного `alert-job-parent` и `alert-job-keycloak` **нет** (влиты в base / deploy).

## Клонирование

См. `alert-job-base/clone-all.ps1.example` — все репо как соседние каталоги.

## Сборка Java

```bash
cd alert-job-base && mvn -N install
cd ../alert-job-common && mvn install -DskipTests
cd ../alert-job-notification && mvn package -DskipTests
```

В сервисах: `<relativePath>../alert-job-base/pom.xml</relativePath>`.

## Docker / деплой

```bash
cd alert-job-deploy
cp env_sample.properties .env   # заполнить
docker compose build keycloak   # dev, при необходимости
docker compose up
```

Prod: `docker compose -f docker-compose-prod.yml --env-file .env up -d`.

Требуются соседи: `alert-job-base` (config), `alert-job-config-repo` (config server).

## Cursor

- Один сервис: открыть папку репо.
- Вся платформа: `alert-job-base/alert-job-base.code-workspace`.
- Общие правила: `_cursor-template/` (в этом репо) → копировать `00-alert-job-ecosystem.mdc` в сервисы при изменении.
- После локального `npm install` / `mvn package`: `scripts/clean-artifacts.ps1` — в git не коммитить `node_modules`, `target`, `dist`.
