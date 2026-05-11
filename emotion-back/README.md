# EmotionApp Backend

Бэкенд состоит из Spring-сервисов в `emotion-back/` и Python ML-сервисов в `../ML/`.

## Соответствие архитектуре

- `api-gateway` — единая точка входа и BFF.
- `auth-service` — регистрация, логин и выдача JWT.
- `content` — Notes Service: альбомы, заметки, топики и связь `album-topic`.
- `ML/src/ai_analysis_service` — AI Analysis Service.
- `ML/src/analytics_service` — Analytics/Stats Service.
- Kafka используется как message broker для событий заметок.

Redis, Search Service и ElasticSearch в текущей сборке не используются.

## Основные маршруты через gateway

- `POST /auth/sign-up`
- `POST /auth/sign-in`
- `GET|POST|PATCH|DELETE /content/**`
- `GET /api/bff/home`
- `POST|GET /ai/**`
- `GET /stats/**`

## Что добавлено

- регистрация пользователя теперь принимает `age`;
- `content` умеет CRUD по `topics`, привязку/отвязку топиков к альбомам и `recent notes`;
- заметки обновляются только через отдельный `PATCH`-контракт для метаданных;
- `content` публикует события `note.created`, `note.renamed`, `note.deleted`;
- `api-gateway` умеет проксировать AI/Stats и агрегировать главную страницу;
- `analytics` учитывает и `note_analysis`, и `period_analysis` в AI activity.

## Переменные окружения

См. `.env.example`.

## Локальный запуск

1. Подними Postgres.
2. Опционально подними Kafka, если нужен асинхронный AI flow по событиям заметок.
3. Запусти `auth-service`, `content`, `api-gateway`.
4. В `../ML` подними `ai_analysis_service` и `analytics_service`.

Если Kafka не запущена, основной CRUD и BFF продолжают работать, но публикация событий будет только логироваться с retry-ошибками.