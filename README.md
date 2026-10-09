# alert-job

Live site: [aj.gdev.by](https://aj.gdev.by)

**Goal:** fast, selective notifications about freelance orders using positive and negative filters.

Supported exchanges include [freelance.ru](https://freelance.ru), [fl.ru](https://www.fl.ru), [weblancer.net](https://www.weblancer.net), [freelancehunt](https://freelancehunt.com/), [youdo](https://youdo.com/), [kwork](https://kwork.ru/), [freelancer](https://www.freelancer.com/), [truelancer](https://www.truelancer.com/).

## Architecture

Microservices platform split into **multiple git repositories** (`alert-job-*`). This repo (**alert-job-base**) holds:

- Maven parent POM (`pom.xml`, artifact `alert-job-parent`)
- Infrastructure configs for Docker (`config/`)
- Documentation and `alert-job-base.code-workspace`

Docker Compose lives in **`alert-job-deploy`**. See `REPOS.md` for the full repo list.

The legacy monorepo [github.com/gdevby/alert-job](https://github.com/gdevby/alert-job) is kept for history; new development uses the multi-repo layout.

## Technologies

- Spring Boot / Spring Cloud, WebFlux, Keycloak  
- React (Vite), MariaDB, Docker  
- **Java 25**, Maven, Node.js  

## Developer guides (how to run locally)

| OS | Language |
|----|----------|
| [Linux](README_FOR_DEVELOPERS_LINUX_EN.md) | English |
| [Linux](README_FOR_DEVELOPERS_LINUX_RU.md) | Russian |
| [Windows](README_FOR_DEVELOPERS_WNDOWS_EN.md) | English |
| [Windows](README_FOR_DEVELOPERS_WINDOWS_RU.md) | Russian |

Short checklist: clone sibling repos → JDK 25 → `mvn -N install` in **alert-job-base** → **alert-job-common** → services → front `npm ci && npm run build` → compose from **alert-job-deploy**.

Test account: login `test`, password `test`.

## Production

Configuration and compose: repository **`alert-job-deploy`** (`docker-compose-prod.yml`, `env_sample.properties` → `.env`).

## Install Docker (Linux)

<details>
<summary>Docker CE on Ubuntu (expand)</summary>

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

Re-login or reboot. On Ubuntu derivatives (e.g. Mint) you may need `UBUNTU_CODENAME` instead of `VERSION_CODENAME`.

</details>

Russian version: [README_RU.md](README_RU.md).
