# BrickCRM

BrickCRM — самодостаточная CRM на Rails 8 (Hotwire, haml, dartsass, Solid Queue,
PostgreSQL 16). Без привязок к внешним системам: SSO, входящие события и
вебхуки — опциональные механики, включаются конфигурацией.
Подробно: [ARCHITECTURE.md](ARCHITECTURE.md).

## Запуск локально (Docker)

```bash
docker compose -f docker-compose.dev.yml up --build
```

Поднимает Postgres 16 и приложение: миграции и сиды выполняются на старте,
исходники смонтированы — правки подхватываются без пересборки.
Приложение: http://localhost:3000. Вход: `admin@example.com` / `changeme123`
(создаётся сидами при пустой базе; в проде поменять после первого входа).

Команды внутри контейнера:

```bash
docker compose -f docker-compose.dev.yml exec crm bin/rails console
docker compose -f docker-compose.dev.yml logs -f crm
```

## Основные механики

- Аутентификация: локальные аккаунты (bcrypt) и/или внешний SSO (JWT RS256) — способы сосуществуют, каждый включается конфигурацией
- Доступ: роли × права по разделам × скоуп по филиалам (row-level)
- Входящий API событий с картой токенов источников, идемпотентный inbox
- Исходящие вебхуки: outbox + доставка по расписанию в WebhookEndpoint
- Каркас разделов: дашборд, лиды, клиенты, задачи, календарь, отчёты, настройки

## Прод

```bash
cp .env.example .env   # заполнить
docker compose up -d --build
```

Самодостаточный стек: db + crm (127.0.0.1:3007, за reverse-proxy) + worker.
