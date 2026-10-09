# Запуск alert-job для разработки (Linux)

Платформа разбита на **несколько git-репозиториев**. Все каталоги `alert-job-*` должны лежать **рядом** в одной родительской папке (например `~/projects/`).

Монорепозиторий `alert-job` на GitHub — legacy; для новой схемы клонируйте репозитории ниже.

## 1. Что установить

| Инструмент | Версия |
|------------|--------|
| JDK | **25** (`JAVA_HOME`) |
| Maven | 3.9+ |
| Node.js + npm | LTS |
| Docker | для Keycloak и полного стенда |
| Git | |

## 2. Клонирование

```bash
mkdir -p ~/projects && cd ~/projects
ORG=https://github.com/gdevby
for r in alert-job-base alert-job-common alert-job-core alert-job-parser \
  alert-job-notification alert-job-llm alert-job-gateway alert-job-config \
  alert-job-config-repo alert-job-front alert-job-deploy; do
  git clone "$ORG/$r.git" "$r"
done
```

| Репозиторий | Назначение |
|-------------|------------|
| `alert-job-base` | Maven parent (`pom.xml`), `config/`, документация |
| `alert-job-common` | общая Java-библиотека |
| `alert-job-*` (core, parser, …) | микросервисы |
| `alert-job-front` | React (Vite) |
| `alert-job-deploy` | **docker-compose**, Keycloak dev-образ |
| `alert-job-config-repo` | файлы Spring Cloud Config |

## 3. Сборка Java (перед IDE или отладкой)

```bash
export JAVA_HOME=/path/to/jdk-25

cd ~/projects/alert-job-base
mvn -N install

cd ../alert-job-common
mvn install -DskipTests -Ddocker.skip=true

# при необходимости один сервис:
cd ../alert-job-notification
mvn package -DskipTests -Ddocker.skip=true
```

Порядок всегда: **base → common → сервис**.

## 4. Frontend

```bash
cd ~/projects/alert-job-front
cp .env.example .env    # при необходимости
npm ci
npm run build           # каталог dist/ — не коммитить в git
```

Путь к статике для nginx: `~/projects/alert-job-front/dist`.

## 5. Переменные окружения (Docker / сервисы)

```bash
cd ~/projects/alert-job-deploy
cp env_sample.properties .env
```

Сгенерируйте ключ шифрования и пропишите в `.env`:

```bash
openssl rand -hex 16   # → APP_ENCRYPTION_KEY
```

## 6. Keycloak (dev)

```bash
cd ~/projects/alert-job-deploy/keycloak
chmod +x build.sh
./build.sh
```

## 7. Docker (минимум для dev)

Compose запускается **только** из `alert-job-deploy` (не из base).

```bash
cd ~/projects/alert-job-deploy
docker compose build keycloak
docker compose up -d keycloak
```

Полный стенд (все контейнеры): `docker compose up` — нужны образы `rg.gdev.by/alert-job/*` (pull из registry или сборка в CI).

Volumes: `../alert-job-base/config`, `../alert-job-config-repo`.

## 8. Config Server и config-repo

**Вариант A — через Docker compose** (рекомендуется): в `docker-compose.yml` уже смонтирован `../alert-job-config-repo`.

**Вариант B — сервис config из IDE:** в `alert-job-config` в `application.properties` (или env):

- `spring.profiles.active=dev,native`
- `spring.cloud.config.server.native.search-locations=file:///home/USER/projects/alert-job-config-repo`

## 9. Файл hosts

```bash
sudo nano /etc/hosts
```

Добавьте:

```
127.0.0.1 config keycloak gateway notification parser core llm
127.0.0.1 auth.alertjob.by alertjob.by
```

Для gateway иногда нужен IP LAN вместо 127.0.0.1 — см. общий README; порт **80** должен быть свободен.

## 10. Nginx (прокси к gateway и Keycloak)

```bash
sudo apt install nginx
sudo nano /etc/nginx/sites-enabled/aj.conf
```

Пример (замените путь к `dist`):

```nginx
server {
    listen 80;
    server_name aj.by alertjob.by;

    location / {
        proxy_pass http://127.0.0.1:8015;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /keycloak {
        rewrite ^/keycloak/(.*) /$1 break;
        proxy_pass http://127.0.0.1:8080/;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /front/ {
        rewrite ^/front/(.*) /$1 break;
        root /home/USER/projects/alert-job-front/dist;
    }

    location /page {
        try_files $uri /index.html;
    }
}
```

```bash
sudo systemctl restart nginx
sudo usermod -aG $USER www-data
```

## 11. Запуск из IDE (IntelliJ IDEA)

1. JDK **25**, Maven: `mvn -N install` в `alert-job-base`, затем `alert-job-common`.
2. Откройте репозиторий сервиса или workspace `alert-job-base/alert-job-base.code-workspace`.
3. Запустите микросервисы **в порядке**:
   1. config  
   2. gateway  
   3. parser  
   4. core  
   5. notification  
   6. llm  

Сайт: [http://alertjob.by](http://alertjob.by)

## 12. Тестовый аккаунт

- Логин: `test`  
- Пароль: `test`

## 13. Артефакты сборки

`node_modules`, `target`, `dist` в git не коммитятся (`.gitignore`). Удалить вручную или `mvn clean` / удалить папки после проверки сборки.
