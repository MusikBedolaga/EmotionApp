from __future__ import annotations

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    database_url: str = "postgresql+asyncpg://postgres:123@localhost:5433/help_book_db"

    kafka_bootstrap_servers: str = "localhost:9092"
    kafka_note_events_topic: str = "note-events"
    kafka_consumer_group: str = "ai-analysis-service"

    emotion_model_backend: str = "zero-shot"
    emotion_model_name: str = "MoritzLaurer/mDeBERTa-v3-base-mnli-xnli"
    emotion_model_device: int = -1
    emotion_model_local_files_only: bool = False
    emotion_hypothesis_template: str = "Этот текст выражает эмоцию {}."

    log_level: str = "INFO"


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()

