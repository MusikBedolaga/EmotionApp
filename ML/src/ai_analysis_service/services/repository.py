from __future__ import annotations

import datetime as dt

import sqlalchemy as sa
from sqlalchemy.ext.asyncio import AsyncSession

from ai_analysis_service.db.models import AiNoteAnalysis, AiPeriodAnalysis
from ml_common.db.content_tables import album_topic, albums, notes, topics


async def fetch_note_with_owner(session: AsyncSession, note_id: int) -> dict:
    q = (
        sa.select(
            notes.c.id.label("note_id"),
            notes.c.album_id.label("album_id"),
            notes.c.title.label("title"),
            notes.c.content.label("content"),
            notes.c.created_at.label("created_at"),
            albums.c.user_id.label("user_id"),
        )
        .select_from(notes.join(albums, notes.c.album_id == albums.c.id))
        .where(notes.c.id == note_id)
    )
    row = (await session.execute(q)).mappings().first()
    if not row:
        raise LookupError("note_not_found")
    return dict(row)


async def assert_album_belongs_to_user(session: AsyncSession, album_id: int, user_id: int) -> None:
    q = sa.select(albums.c.id).where(albums.c.id == album_id, albums.c.user_id == user_id)
    row = (await session.execute(q)).first()
    if not row:
        raise LookupError("album_not_found_or_forbidden")


async def fetch_notes_texts_for_period(
    session: AsyncSession,
    album_id: int,
    period_from: dt.datetime,
    period_to: dt.datetime,
) -> list[str]:
    q = (
        sa.select(notes.c.content)
        .where(
            notes.c.album_id == album_id,
            notes.c.created_at >= period_from,
            notes.c.created_at <= period_to,
        )
        .order_by(notes.c.created_at.asc())
    )
    rows = (await session.execute(q)).scalars().all()
    return [r or "" for r in rows]


async def fetch_notes_for_period(
    session: AsyncSession,
    *,
    album_id: int,
    period_from: dt.datetime,
    period_to: dt.datetime,
) -> list[dict]:
    q = (
        sa.select(
            notes.c.id.label("note_id"),
            notes.c.album_id.label("album_id"),
            notes.c.title.label("title"),
            notes.c.content.label("content"),
            notes.c.created_at.label("created_at"),
        )
        .where(
            notes.c.album_id == album_id,
            notes.c.created_at >= period_from,
            notes.c.created_at <= period_to,
        )
        .order_by(notes.c.created_at.asc())
    )
    return [dict(row) for row in (await session.execute(q)).mappings().all()]


async def save_note_analysis(
    session: AsyncSession,
    *,
    note_id: int,
    album_id: int,
    user_id: int,
    model: str,
    result_type: str,
    result_text: str | None,
    result_json: dict | None,
) -> AiNoteAnalysis:
    obj = AiNoteAnalysis(
        note_id=note_id,
        album_id=album_id,
        user_id=user_id,
        model=model,
        result_type=result_type,
        result_text=result_text,
        result_json=result_json,
    )
    session.add(obj)
    await session.commit()
    await session.refresh(obj)
    return obj


async def save_period_analysis(
    session: AsyncSession,
    *,
    album_id: int,
    user_id: int,
    period_from: dt.datetime,
    period_to: dt.datetime,
    period_type: str,
    analysis_type: str,
    model: str,
    result_text: str | None,
    result_json: dict | None,
) -> AiPeriodAnalysis:
    obj = AiPeriodAnalysis(
        album_id=album_id,
        user_id=user_id,
        period_from=period_from,
        period_to=period_to,
        period_type=period_type,
        analysis_type=analysis_type,
        model=model,
        result_text=result_text,
        result_json=result_json,
    )
    session.add(obj)
    await session.commit()
    await session.refresh(obj)
    return obj


async def get_latest_note_analysis(
    session: AsyncSession, *, note_id: int, user_id: int
) -> AiNoteAnalysis | None:
    q = (
        sa.select(AiNoteAnalysis)
        .where(AiNoteAnalysis.note_id == note_id, AiNoteAnalysis.user_id == user_id)
        .order_by(AiNoteAnalysis.created_at.desc())
        .limit(1)
    )
    return (await session.execute(q)).scalars().first()


async def list_period_analyses(
    session: AsyncSession, *, album_id: int, user_id: int, limit: int = 50
) -> list[AiPeriodAnalysis]:
    q = (
        sa.select(AiPeriodAnalysis)
        .where(AiPeriodAnalysis.album_id == album_id, AiPeriodAnalysis.user_id == user_id)
        .order_by(AiPeriodAnalysis.created_at.desc())
        .limit(limit)
    )
    return list((await session.execute(q)).scalars().all())


async def get_latest_period_analysis(
    session: AsyncSession,
    *,
    album_id: int,
    user_id: int,
) -> AiPeriodAnalysis | None:
    q = (
        sa.select(AiPeriodAnalysis)
        .where(AiPeriodAnalysis.album_id == album_id, AiPeriodAnalysis.user_id == user_id)
        .order_by(AiPeriodAnalysis.created_at.desc())
        .limit(1)
    )
    return (await session.execute(q)).scalars().first()


async def list_topics_for_album(session: AsyncSession, *, album_id: int) -> list[dict]:
    q = (
        sa.select(topics.c.id, topics.c.name, topics.c.color)
        .select_from(topics.join(album_topic, topics.c.id == album_topic.c.topic_id))
        .where(album_topic.c.album_id == album_id)
        .order_by(topics.c.name.asc())
    )
    return [dict(r) for r in (await session.execute(q)).mappings().all()]


async def fetch_topic_with_owner(session: AsyncSession, *, topic_id: int, user_id: int) -> dict:
    q = (
        sa.select(topics.c.id, topics.c.name, topics.c.color)
        .select_from(
            topics.join(album_topic, topics.c.id == album_topic.c.topic_id).join(
                albums, album_topic.c.album_id == albums.c.id
            )
        )
        .where(topics.c.id == topic_id, albums.c.user_id == user_id)
        .group_by(topics.c.id, topics.c.name, topics.c.color)
        .limit(1)
    )
    row = (await session.execute(q)).mappings().first()
    if not row:
        raise LookupError("topic_not_found_or_forbidden")
    return dict(row)


async def fetch_notes_for_topic(
    session: AsyncSession,
    *,
    topic_id: int,
    user_id: int,
    period_from: dt.datetime | None = None,
    period_to: dt.datetime | None = None,
) -> list[dict]:
    q = (
        sa.select(
            notes.c.id.label("note_id"),
            notes.c.album_id.label("album_id"),
            notes.c.title.label("title"),
            notes.c.content.label("content"),
            notes.c.created_at.label("created_at"),
        )
        .select_from(
            notes.join(albums, notes.c.album_id == albums.c.id).join(
                album_topic, album_topic.c.album_id == albums.c.id
            )
        )
        .where(albums.c.user_id == user_id, album_topic.c.topic_id == topic_id)
        .order_by(notes.c.created_at.asc())
    )
    if period_from is not None:
        q = q.where(notes.c.created_at >= period_from)
    if period_to is not None:
        q = q.where(notes.c.created_at <= period_to)
    return [dict(row) for row in (await session.execute(q)).mappings().all()]

