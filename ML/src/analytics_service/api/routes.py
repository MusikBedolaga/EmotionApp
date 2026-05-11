from __future__ import annotations

import datetime as dt

import sqlalchemy as sa
from fastapi import APIRouter, Depends, Header, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from analytics_service.api.schemas import AiActivityPoint, AlbumTopRow, TimeseriesPoint, TopicUsageRow
from analytics_service.db.deps import get_db_session
from ml_common.db.ai_tables import ai_note_analysis, ai_period_analysis
from ml_common.db.content_tables import album_topic, albums, notes, topics

router = APIRouter(prefix="/api/stats", tags=["stats"])


def _date_trunc(bucket: str, column) -> sa.ColumnElement:
    if bucket not in {"day", "week", "month"}:
        raise ValueError("invalid bucket")
    return sa.func.date_trunc(bucket, column)


def _naive(dt_value: dt.datetime) -> dt.datetime:
    if dt_value.tzinfo is None:
        return dt_value
    return dt_value.astimezone(dt.timezone.utc).replace(tzinfo=None)


def _aware_utc(dt_value: dt.datetime) -> dt.datetime:
    if dt_value.tzinfo is None:
        return dt_value.replace(tzinfo=dt.timezone.utc)
    return dt_value.astimezone(dt.timezone.utc)


@router.get("/notes/timeseries", response_model=list[TimeseriesPoint])
async def notes_timeseries(
    from_: dt.datetime = Query(alias="from"),
    to: dt.datetime = Query(),
    bucket: str = Query(pattern="^(day|week|month)$"),
    album_id: int | None = Query(default=None),
    topic_id: int | None = Query(default=None),
    session: AsyncSession = Depends(get_db_session),
    x_user_id: int = Header(alias="X-User-Id"),
) -> list[dict]:
    from_value = _naive(from_)
    to_value = _naive(to)
    if from_value > to_value:
        raise HTTPException(status_code=422, detail="from должен быть <= to")

    bucket_col = _date_trunc(bucket, notes.c.created_at).label("bucket_start")

    from_clause = notes.join(albums, notes.c.album_id == albums.c.id)
    if topic_id is not None:
        from_clause = from_clause.join(album_topic, album_topic.c.album_id == albums.c.id)

    q = sa.select(bucket_col, sa.func.count(sa.distinct(notes.c.id)).label("count")).select_from(from_clause)
    q = q.where(
        albums.c.user_id == x_user_id,
        notes.c.created_at >= from_value,
        notes.c.created_at <= to_value,
    )

    if album_id is not None:
        q = q.where(notes.c.album_id == album_id)

    if topic_id is not None:
        q = q.where(album_topic.c.topic_id == topic_id)

    q = q.group_by(bucket_col).order_by(bucket_col.asc())

    rows = (await session.execute(q)).mappings().all()
    return [{"bucket_start": r["bucket_start"], "count": int(r["count"])} for r in rows]


@router.get("/albums/top", response_model=list[AlbumTopRow])
async def top_albums(
    from_: dt.datetime = Query(alias="from"),
    to: dt.datetime = Query(),
    limit: int = Query(default=10, ge=1, le=100),
    session: AsyncSession = Depends(get_db_session),
    x_user_id: int = Header(alias="X-User-Id"),
) -> list[dict]:
    from_value = _naive(from_)
    to_value = _naive(to)
    if from_value > to_value:
        raise HTTPException(status_code=422, detail="from должен быть <= to")

    q = (
        sa.select(notes.c.album_id.label("album_id"), sa.func.count(notes.c.id).label("notes_count"))
        .select_from(notes.join(albums, notes.c.album_id == albums.c.id))
        .where(
            albums.c.user_id == x_user_id,
            notes.c.created_at >= from_value,
            notes.c.created_at <= to_value,
        )
        .group_by(notes.c.album_id)
        .order_by(sa.desc(sa.literal_column("notes_count")))
        .limit(limit)
    )
    rows = (await session.execute(q)).mappings().all()
    return [{"album_id": int(r["album_id"]), "notes_count": int(r["notes_count"])} for r in rows]


@router.get("/topics/usage", response_model=list[TopicUsageRow])
async def topic_usage(
    from_: dt.datetime = Query(alias="from"),
    to: dt.datetime = Query(),
    session: AsyncSession = Depends(get_db_session),
    x_user_id: int = Header(alias="X-User-Id"),
) -> list[dict]:
    from_value = _naive(from_)
    to_value = _naive(to)
    if from_value > to_value:
        raise HTTPException(status_code=422, detail="from должен быть <= to")

    # notes -> albums -> album_topic -> topics
    q = (
        sa.select(
            topics.c.id.label("topic_id"),
            topics.c.name.label("name"),
            topics.c.color.label("color"),
            sa.func.count(sa.distinct(notes.c.id)).label("notes_count"),
        )
        .select_from(
            topics.join(album_topic, topics.c.id == album_topic.c.topic_id)
            .join(albums, albums.c.id == album_topic.c.album_id)
            .join(notes, notes.c.album_id == albums.c.id)
        )
        .where(
            albums.c.user_id == x_user_id,
            notes.c.created_at >= from_value,
            notes.c.created_at <= to_value,
        )
        .group_by(topics.c.id, topics.c.name, topics.c.color)
        .order_by(sa.desc(sa.literal_column("notes_count")))
    )
    rows = (await session.execute(q)).mappings().all()
    return [
        {
            "topic_id": int(r["topic_id"]),
            "name": r["name"],
            "color": r["color"],
            "notes_count": int(r["notes_count"]),
        }
        for r in rows
    ]


@router.get("/ai/activity", response_model=list[AiActivityPoint])
async def ai_activity(
    from_: dt.datetime = Query(alias="from"),
    to: dt.datetime = Query(),
    bucket: str = Query(pattern="^(day|week|month)$"),
    session: AsyncSession = Depends(get_db_session),
    x_user_id: int = Header(alias="X-User-Id"),
) -> list[dict]:
    from_value = _aware_utc(from_)
    to_value = _aware_utc(to)
    if from_value > to_value:
        raise HTTPException(status_code=422, detail="from должен быть <= to")

    ai_events = sa.union_all(
        sa.select(
            ai_note_analysis.c.user_id.label("user_id"),
            ai_note_analysis.c.created_at.label("created_at"),
        ),
        sa.select(
            ai_period_analysis.c.user_id.label("user_id"),
            ai_period_analysis.c.created_at.label("created_at"),
        ),
    ).subquery("ai_events")

    bucket_col = _date_trunc(bucket, ai_events.c.created_at).label("bucket_start")
    q = (
        sa.select(bucket_col, sa.func.count().label("count"))
        .select_from(ai_events)
        .where(
            ai_events.c.user_id == x_user_id,
            ai_events.c.created_at >= from_value,
            ai_events.c.created_at <= to_value,
        )
        .group_by(bucket_col)
        .order_by(bucket_col.asc())
    )
    try:
        rows = (await session.execute(q)).mappings().all()
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"AI таблицы недоступны: {type(e).__name__}")
    return [{"bucket_start": r["bucket_start"], "count": int(r["count"])} for r in rows]

