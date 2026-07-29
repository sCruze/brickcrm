# Архитектура BrickCRM

Ядро самодостаточно и не знает ни об одной внешней системе. Все точки
интеграции — опциональные механики, которые включаются конфигурацией и
без неё молчат. Интеграция с конкретной платформой делается в downstream-
проекте (или ветке конфигурации), не трогая ядро.

## Режимы и конфигурация (app/lib/crm_config.rb)

Способы входа не выбираются переключателем, а сосуществуют: каждый
активен, если сконфигурирован. Парольный вход включён по умолчанию,
SSO включается сам при наличии ключа и issuer.

| ENV | Значения | Что делает |
|---|---|---|
| `PASSWORD_AUTH` | пусто (дефолт) / `disabled` | `disabled` запрещает вход по паролю (для инсталляций «только SSO») |
| `INBOUND_API_TOKENS` | `источник:токен,...` | Карта токенов входящего API. **Fail-closed**: пусто = канал закрыт |
| `SSO_PROVIDER_NAME` | строка | Имя провайдера, пишется в `users.provider` |
| `SSO_ISSUER` + `SSO_PUBLIC_KEY_BASE64` | — | Оба заполнены = SSO включён |
| `SSO_AUTHORIZE_URL` | URL | Куда редиректить на вход |
| `SSO_ISSUER` / `SSO_AUDIENCE` | строки | Обязательные claims JWT |
| `SSO_PUBLIC_KEY_BASE64` | base64 PEM | Публичный ключ проверки подписи; приватный живёт у провайдера |

## Модель доступа

«Кто ты» решает провайдер идентичности, «что тебе можно» — только CRM:

- `users` — аккаунт; `provider`/`external_uid` заполнены у SSO-аккаунтов.
  Ключ связи — (provider, external_uid), вторичный — нормализованный email.
- `roles` — справочник прав: `permissions` = `{ раздел => [read, write, manage] }`.
- `branches` — филиалы/офисы (ось скоупа); `external_source`/`external_id` —
  для синхронизации из внешних систем.
- `memberships` — выдача роли пользователю в скоупе: `branch_id NULL` = вся сеть.
- Гейт входа: `User#can_sign_in?` = активен **и** есть активный membership.
  SSO-токен даёт только личность и никогда — права.
- Row-level видимость: `ApplicationPolicy::Scope#resolve` фильтрует по
  `branch_id` для всех, у кого нет глобального membership.

## Контракт SSO (для любого провайдера)

1. CRM редиректит неавторизованного на `SSO_AUTHORIZE_URL`.
2. Провайдер аутентифицирует и редиректит на `GET {CRM}/sso/callback?token=<JWT>`.
3. JWT: RS256, claims `sub`, `email`, `name`, `iss=SSO_ISSUER`,
   `aud=SSO_AUDIENCE` (дефолт `brickcrm`), `iat`, `exp` (рекомендация: 60 секунд).
4. CRM проверяет подпись/exp/iss/aud, апсертит пользователя
   (`Sso::IdentityUpserter`) и пускает только при активном membership.

## Синхронизация

- **Входящий канал**: `POST /api/v1/events`, `Authorization: Bearer <токен>`.
  Источник определяется по токену из `INBOUND_API_TOKENS` (константное
  сравнение). Идемпотентность: `UNIQUE (source, event_key)`; условие
  дедупликации в коде совпадает с индексом, статус не участвует. Дубликат
  получает 200 и no-op. Обработка — асинхронно: `Inbox::ProcessEventJob`
  → `Inbox::Router` → `Inbox::Handlers::<EntityType>Handler` (точка
  расширения: один обработчик на тип сущности).
- **Исходящий канал**: доменный код пишет `OutboxEvent` с `destination` =
  имя `WebhookEndpoint`; `Outbox::DrainerJob` (каждую минуту,
  `config/recurring.yml`) доставляет с `Idempotency-Key` и Bearer-токеном
  эндпоинта; ретраи с подсчётом попыток, после 10 неудач — статус `dead`.

Проверка входящего контура end-to-end:

```bash
# в .env: INBOUND_API_TOKENS=demo:какой-то-токен, перезапустить контейнер
curl -s -X POST http://localhost:3000/api/v1/events \
  -H "Authorization: Bearer какой-то-токен" \
  -H "Content-Type: application/json" \
  -d '{"event_key":"test-1","entity_type":"ping","entity_id":"1","event":"created","payload":{"hello":"world"}}'
# => {"status":"accepted","duplicate":false}; повторная отправка => duplicate:true
```

## Карта кода

```
app/lib/crm_config.rb                  # вся конфигурация режимов
app/models/{user,session,current,role,branch,membership}.rb
app/models/{inbox_event,outbox_event,webhook_endpoint}.rb
app/controllers/concerns/authentication.rb
app/controllers/sessions_controller.rb # локальный вход (режим local)
app/controllers/sso/                   # внешний SSO (режим sso)
app/services/sso/                      # верификация JWT, апсерт идентичности
app/controllers/api/                   # входящий API, fail-closed
app/services/inbox/                    # роутер + обработчики событий
app/jobs/{inbox,outbox}/               # обработка входящих, доставка исходящих
app/policies/application_policy.rb     # row-level скоуп по branch_id
```
