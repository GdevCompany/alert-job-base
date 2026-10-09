# AGENTS.md — alert-job-base

**Meta + Maven parent** для мультирепо alert-job. GitHub: **`alert-job-base`**. Соседние клоны `alert-job-*` — в одной папке на диске. Монорепо legacy: **`alert-job`**.

## Содержимое

| Что | Где |
|-----|-----|
| Parent POM (`alert-job-parent`) | `pom.xml` → `mvn -N install` |
| Инфра-конфиг для Docker | `config/` (монтируется из `alert-job-deploy` compose) |
| Документация продукта | `README*.md` |
| Обзор всех репо | `REPOS.md`, `README_FOR_DEVELOPERS_*`, workspace |

**Docker compose здесь нет** — только `alert-job-deploy`.

## Cursor

| Задача | Что открыть |
|--------|-------------|
| Один сервис | `alert-job-notification` и т.д. |
| Вся платформа | `alert-job-base.code-workspace` |
| Стенд | `../alert-job-deploy` |

## Сборка Java (порядок)

1. Этот репо: `mvn -N install`
2. `alert-job-common`: `mvn install -DskipTests`
3. Сервисы: `mvn package`

Клоны и запуск: `README_FOR_DEVELOPERS_*`, `REPOS.md`. В git не коммитить `node_modules`, `target`, `dist` (см. `.gitignore` в каждом репо).
