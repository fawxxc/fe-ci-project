# Практично-лабораторне заняття №8
# Неперервна інтеграція: GitHub Actions + GHCR (Front-end)

## Мета
Ознайомитися з принципами і практиками 
неперервної інтеграції, сформувати навички 
автоматизації CI/CD процесів в GitHub Actions

## GitHub Skills (для звіту)

1) **Hello GitHub Actions**  
Repo: https://github.com/fawxxc/skills-hello-github-actions

2) **Publish Packages**  
Repo: https://github.com/fawxxc/skills-publish-packages

## Вимоги до workflow
### Тригери
Workflow має 2 тригери:
- ручний запуск: `workflow_dispatch`;
- автоматичний запуск при `push` у гілки:
  - `main`
  - `feature/*`
  - ### Job та кроки
Workflow містить 1 job з такими кроками:
1. **Checkout репозиторію** (actions/checkout).
2. **Setup Node.js**.
3. **Один скрипт**, який виконує:
   - `npm i -g pnpm`
   - `pnpm install`
   - `pnpm run build`
4. **Login to GHCR** (docker/login-action):
   - `registry: ghcr.io`
   - `username` з github context (`github.repository_owner`)
   - `password` = `secrets.GITHUB_TOKEN`
5. **Build & Push Docker image** (docker/build-push-action):
   - `context: .`
   - `push: true`
   - тег: `ghcr.io/<login>/<repo>`

---

## Файли проєкту
- `.github/workflows/fe-docker-ghcr.yml` — workflow для CI/CD.
- `Dockerfile` — інструкції збірки Docker-образу.
- `package.json` — залежності та скрипти збірки (Vite).

---

## Dockerfile
Проєкт збирається у папку `dist`, яку nginx віддає як статичний сайт.

```dockerfile
FROM nginx:1.24-alpine
COPY dist/ /usr/share/nginx/html
```
## Workflow

Файл workflow: **`.github/workflows/fe-docker-ghcr.yml`**

### Тригери
Workflow запускається у двох випадках:
- **вручну** через кнопку **Run workflow** (`workflow_dispatch`);
- **автоматично** при `push` у гілки:
  - `main`
  - `feature/*`

### Структура
Workflow містить **1 job**: `build_and_push`, який виконується на `ubuntu-latest`.

### Кроки job
1. **Checkout репозиторію**  
   Використовується `actions/checkout@v4` (клонування репозиторію з налаштуваннями за замовчуванням).

2. **Setup Node.js**  
   Встановлюється Node.js (версія `20`) через `actions/setup-node@v4`.

3. **Один скрипт для pnpm + залежностей + build**  
   В одному `run`-скрипті виконується:
   - встановлення pnpm: `npm i -g pnpm`
   - встановлення залежностей: `pnpm install`
   - збірка проєкту: `pnpm run build`

4. **Авторизація в GitHub Container Registry (GHCR)**  
   Використовується `docker/login-action@v3`:
   - `registry: ghcr.io`
   - `username: ${{ github.repository_owner }}`
   - `password: ${{ secrets.GITHUB_TOKEN }}`

5. **Збірка та публікація Docker-образу в GHCR**  
   Використовується `docker/build-push-action@v6`:
   - `context: .` (поточна директорія)
   - `push: true` (виконується завантаження образу)
   - `tags: ghcr.io/${{ github.repository_owner }}/${{ github.event.repository.name }}`

### Як запустити вручну
1. Перейти у вкладку **Actions**.
2. Вибрати workflow **Build & Push FE Docker image to GHCR**.
3. Натиснути **Run workflow** → обрати гілку `main` → підтвердити запуск.

### Як перевірити, що все успішно
- **Actions:** останній запуск workflow має бути зі статусом ✅ (зелений).
- **Packages:** у репозиторії/профілі має з’явитися Docker-образ:
  `docker pull ghcr.io/fawxxc/fe-ci-project:latest`

> Примітка: для збірки Docker-образу потрібен файл `Dockerfile` у корені репозиторію.
