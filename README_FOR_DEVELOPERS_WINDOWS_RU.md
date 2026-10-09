# Запуск alert-job для разработки (Windows)

Платформа в **нескольких git-репозиториях**. Все папки `alert-job-*` — **соседи** в одной директории (например `D:\projects\`).

Монорепозиторий `alert-job` — legacy; для работы клонируйте список ниже.

## 1. Что установить

| Инструмент | Версия |
|------------|--------|
| JDK | **25** (`JAVA_HOME`) |
| Maven | 3.9+ |
| Node.js | LTS (удобно через [nvm-windows](https://github.com/coreybutler/nvm-windows/releases)) |
| Docker Desktop | |
| Git | |

## 2. Клонирование

PowerShell (пример — измените `$base`):

```powershell
$base = "D:\projects"
$org = "https://github.com/gdevby"
$repos = @(
  "alert-job-base","alert-job-common","alert-job-core","alert-job-parser",
  "alert-job-notification","alert-job-llm","alert-job-gateway","alert-job-config",
  "alert-job-config-repo","alert-job-front","alert-job-deploy"
)
foreach ($r in $repos) {
  $p = Join-Path $base $r
  if (-not (Test-Path $p)) { git clone "$org/$r.git" $p }
}
```

## 3. Сборка Java

```powershell
$env:JAVA_HOME = "C:\Program Files\Java\jdk-25"

cd D:\projects\alert-job-base
mvn -N install

cd ..\alert-job-common
mvn install -DskipTests -Ddocker.skip=true

cd ..\alert-job-notification
mvn package -DskipTests -Ddocker.skip=true
```

Порядок: **base → common → сервис**.

## 4. Frontend

```powershell
cd D:\projects\alert-job-front
copy .env.example .env
npm ci
npm run build
```

Статика для nginx: `D:\projects\alert-job-front\dist`.

## 5. Переменные окружения

```powershell
cd D:\projects\alert-job-deploy
copy env_sample.properties .env
```

Ключ `APP_ENCRYPTION_KEY` (Git Bash / WSL):

```bash
openssl rand -hex 16
```

## 6. Keycloak (dev)

```powershell
cd D:\projects\alert-job-deploy\keycloak
docker build -t alert-job/alert-job-keycloak:0.1 .
```

Или Git Bash: `./build.sh`.

## 7. Docker

Только из **`alert-job-deploy`**:

```powershell
cd D:\projects\alert-job-deploy
docker compose build keycloak
docker compose up -d keycloak
```

Полный стенд: `docker compose up`. Нужны соседи `alert-job-base` (config) и `alert-job-config-repo`.

## 8. Config Server

При запуске **config** из IDE в `alert-job-config` укажите профиль `dev,native` и путь:

`spring.cloud.config.server.native.search-locations=file:///D:/projects/alert-job-config-repo`

(слэши `/` в URI, как в старых конфигах проекта.)

Через compose config-repo монтируется автоматически.

## 9. Hosts

Файл `C:\Windows\System32\drivers\etc\hosts` (от администратора):

```
127.0.0.1 config keycloak gateway notification parser core llm
127.0.0.1 auth.alertjob.by alertjob.by
```

Порт **80** свободен.

## 10. Nginx (опционально)

Скачайте [nginx для Windows](https://nginx.org/en/download.html). В `conf/nginx.conf` настройте `server` с proxy на `127.0.0.1:8015`, Keycloak `8080`, для `/front/`:

```nginx
root D:/projects/alert-job-front/dist;
```

Проверка: `nginx -t`, запуск `nginx.exe`.

## 11. PowerShell Execution Policy (если нужны скрипты)

Только если блокируются локальные `.ps1`:

```powershell
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Верните прежнее значение после настройки, если требует политика компании.

## 12. Запуск из IntelliJ IDEA

1. SDK **25**; `mvn -N install` в `alert-job-base`, затем `alert-job-common`.
2. Откройте сервис или `alert-job-base.code-workspace`.
3. Порядок запуска: **config → gateway → parser → core → notification → llm**.

Сайт: [http://alertjob.by](http://alertjob.by)

## 13. Тестовый аккаунт

- Логин: `test`  
- Пароль: `test`

## 14. Артефакты сборки

Не коммитьте `node_modules`, `target`, `dist` — они в `.gitignore` каждого репозитория.
