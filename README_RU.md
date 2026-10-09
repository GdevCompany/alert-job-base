# alert-job

Рабочий сайт: [aj.gdev.by](https://aj.gdev.by)

**Цель:** быстрые избирательные уведомления о заказах на биржах по вашим фильтрам (позитивные и негативные).

Биржи: [freelance.ru](https://freelance.ru), [fl.ru](https://www.fl.ru), [weblancer.net](https://www.weblancer.net), [freelancehunt](https://freelancehunt.com/), [youdo](https://youdo.com/), [kwork](https://kwork.ru/), [freelancer](https://www.freelancer.com/), [truelancer](https://www.truelancer.com/).

## Архитектура

Микросервисы в **нескольких git-репозиториях** (`alert-job-*`). Этот репозиторий (**alert-job-base**):

- Maven parent (`pom.xml`)
- конфиги для Docker (`config/`)
- документация, workspace

**Docker Compose** — только в **`alert-job-deploy`**. Список репозиториев: `REPOS.md`.

Монорепозиторий [alert-job](https://github.com/gdevby/alert-job) сохранён для истории; для разработки — мультирепо.

## Стек

Spring Boot / Cloud, WebFlux, Keycloak, React (Vite), MariaDB, Docker, **Java 25**, Maven, Node.js.

## Инструкции для разработчиков

| ОС | Язык |
|----|------|
| [Linux](README_FOR_DEVELOPERS_LINUX_RU.md) | русский |
| [Linux](README_FOR_DEVELOPERS_LINUX_EN.md) | English |
| [Windows](README_FOR_DEVELOPERS_WINDOWS_RU.md) | русский |
| [Windows](README_FOR_DEVELOPERS_WNDOWS_EN.md) | English |

Кратко: клоны-соседи → JDK 25 → `mvn -N install` в **alert-job-base** → **alert-job-common** → сервисы → front → `docker compose` из **alert-job-deploy**. Нужен свободный порт **80** и записи в `hosts` (см. гайды).

Тестовый аккаунт: логин `test`, пароль `test`.

## Продакшен

`alert-job-deploy`: `docker-compose-prod.yml`, `.env` из `env_sample.properties`.

## Установка Docker (Linux)

<details>
<summary>Ubuntu — развернуть</summary>

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
```

Перелогиньтесь или перезагрузите ПК. На производных Ubuntu (Mint) может понадобиться `UBUNTU_CODENAME` вместо `VERSION_CODENAME`.

</details>

English: [README.md](README.md).
