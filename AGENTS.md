# AGENTS.md — alert-job-base

**Meta + Maven parent** для мультирепо alert-job. Имя GitHub: **`alert-job-base`** (монорепо legacy: **`alert-job`**).

## Содержимое

| Что | Где |
|-----|-----|
| Parent POM (`alert-job-base`) | `pom.xml` → `mvn -N install` |
| Инфра-конфиг для Docker | `config/` (монтируется из `alert-job-deploy` compose) |
| Документация продукта | `README*.md` |
| Обзор всех репо | `REPOS.md`, `MULTIREPO-LAYOUT.md`, workspace |

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

Клоны: `clone-all.ps1.example`. Артефакты сборки (`node_modules`, `target`, `dist`) в git не входят — после проверки сборки: `scripts/clean-artifacts.ps1`.
