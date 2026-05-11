## ML монорепозиторий (Python)

Здесь лежат два Python‑микросервиса:

- **`ai_analysis_service`** — быстрый анализ заметки и периодный анализ альбома, хранение результатов в Postgres, опциональный Kafka consumer `note-events`.
- **`analytics_service`** — агрегации/ряды для графиков по заметкам/альбомам/топикам (и опционально по активности AI).

### Быстрый старт (локально)

Создай виртуальное окружение и установи зависимости:

```bash
cd ML
python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -e .
```

Скопируй пример окружения:

```bash
cp .env.example .env
```

Подними миграции (создаст схему `ai` и таблицы результатов):

```bash
alembic upgrade head
```

Запуск API сервисов:

```bash
uvicorn ai_analysis_service.main:app --reload --port 8010
uvicorn analytics_service.main:app --reload --port 8020
```

Опционально: Kafka‑воркер AI (слушает `note-events`):

```bash
python -m ai_analysis_service.kafka_worker
```

### Переменные окружения

См. `.env.example`.

