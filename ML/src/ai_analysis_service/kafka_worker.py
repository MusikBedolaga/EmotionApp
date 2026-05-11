from __future__ import annotations

import asyncio
import json
import logging
import re

from aiokafka import AIOKafkaConsumer

from ai_analysis_service.services.analyzer import analyze_note
from ai_analysis_service.services.repository import fetch_note_with_owner, list_topics_for_album, save_note_analysis
from ml_common.config.settings import get_settings
from ml_common.db.session import get_sessionmaker
from ml_common.observability.logging import configure_logging

log = logging.getLogger("ai_analysis_service.kafka_worker")

_SUPPORTED_EVENT_TYPES = {"note.created", "note.renamed", "note.updated"}
_IGNORED_EVENT_TYPES = {"note.deleted"}
_DEFAULT_MODEL = "emotion-zero-shot-v1"
_DEFAULT_RESULT_TYPE = "emotion_profile"


def _parse_event(payload: str) -> tuple[str | None, int | None]:
    payload = (payload or "").strip()
    if not payload:
        return None, None

    # JSON
    if payload.startswith("{") and payload.endswith("}"):
        try:
            obj = json.loads(payload)
            event_type = obj.get("event_type") or obj.get("eventType")
            note_id = obj.get("note_id") or obj.get("noteId") or obj.get("id")
            if note_id is None:
                return event_type, None
            return event_type, int(note_id)
        except Exception:
            return None, None

    # raw number
    if payload.isdigit():
        return None, int(payload)

    # find number inside string
    m = re.search(r"\b(\d+)\b", payload)
    if m:
        return None, int(m.group(1))

    return None, None


async def _process_note(note_id: int) -> None:
    settings = get_settings()
    session_maker = get_sessionmaker()
    async with session_maker() as session:
        try:
            note = await fetch_note_with_owner(session, note_id)
        except LookupError:
            log.info("note_not_found", extra={"note_id": note_id})
            return

        result_text, result_json = analyze_note(
            note["title"],
            note["content"],
            requested_model=_DEFAULT_MODEL,
        )
        topics = await list_topics_for_album(session, album_id=int(note["album_id"]))
        result_json = {**(result_json or {}), "album_topics": topics}

        await save_note_analysis(
            session,
            note_id=int(note["note_id"]),
            album_id=int(note["album_id"]),
            user_id=int(note["user_id"]),
            model=_DEFAULT_MODEL,
            result_type=_DEFAULT_RESULT_TYPE,
            result_text=result_text,
            result_json=result_json,
        )
        log.info(
            "note_analyzed",
            extra={"note_id": note_id, "backend": settings.emotion_model_backend},
        )


async def main() -> None:
    settings = get_settings()
    configure_logging(settings.log_level)

    consumer = AIOKafkaConsumer(
        settings.kafka_note_events_topic,
        bootstrap_servers=settings.kafka_bootstrap_servers,
        group_id=settings.kafka_consumer_group,
        enable_auto_commit=False,
        auto_offset_reset="earliest",
    )

    await consumer.start()
    try:
        log.info(
            "consumer_started",
            extra={
                "topic": settings.kafka_note_events_topic,
                "bootstrap": settings.kafka_bootstrap_servers,
                "group": settings.kafka_consumer_group,
            },
        )
        async for msg in consumer:
            raw = msg.value.decode("utf-8", errors="replace") if msg.value else ""
            event_type, note_id = _parse_event(raw)
            if note_id is None:
                log.warning("unsupported_event_payload", extra={"payload": raw[:2000]})
                await consumer.commit()
                continue

            if event_type in _IGNORED_EVENT_TYPES:
                log.info("event_ignored", extra={"event_type": event_type, "note_id": note_id})
                await consumer.commit()
                continue

            if event_type is not None and event_type not in _SUPPORTED_EVENT_TYPES:
                log.warning(
                    "unsupported_event_type",
                    extra={"event_type": event_type, "note_id": note_id},
                )
                await consumer.commit()
                continue

            try:
                await _process_note(note_id)
                await consumer.commit()
            except Exception:
                log.exception("processing_failed", extra={"note_id": note_id})
                # не коммитим offset, чтобы Kafka могла повторить
                await asyncio.sleep(1)
    finally:
        await consumer.stop()


if __name__ == "__main__":
    asyncio.run(main())

