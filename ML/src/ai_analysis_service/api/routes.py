from __future__ import annotations

import datetime as dt

from fastapi import APIRouter, Depends, Header, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from ai_analysis_service.api.schemas import (
    NoteAnalyzeRequest,
    NoteAnalysisResponse,
    PeriodAnalyzeRequest,
    PeriodAnalysisResponse,
    TopicEmotionResponse,
)
from ai_analysis_service.db.deps import get_db_session
from ai_analysis_service.services.analyzer import aggregate_topic_emotions, analyze_note, analyze_period
from ai_analysis_service.services.repository import (
    assert_album_belongs_to_user,
    fetch_note_with_owner,
    fetch_notes_for_period,
    fetch_notes_for_topic,
    fetch_topic_with_owner,
    get_latest_note_analysis,
    get_latest_period_analysis,
    list_period_analyses,
    list_topics_for_album,
    save_note_analysis,
    save_period_analysis,
)

router = APIRouter(prefix="/api/ai", tags=["ai"])


def _naive(dt_value: dt.datetime) -> dt.datetime:
    if dt_value.tzinfo is None:
        return dt_value
    return dt_value.astimezone(dt.timezone.utc).replace(tzinfo=None)


@router.post("/notes/{note_id}:analyze", response_model=NoteAnalysisResponse)
async def analyze_note_endpoint(
    note_id: int,
    payload: NoteAnalyzeRequest,
    session: AsyncSession = Depends(get_db_session),
    x_user_id: int = Header(alias="X-User-Id"),
):
    try:
        note = await fetch_note_with_owner(session, note_id)
    except LookupError:
        raise HTTPException(status_code=404, detail="Заметка не найдена")

    if int(note["user_id"]) != int(x_user_id):
        raise HTTPException(status_code=403, detail="Нет доступа к заметке")

    result_text, result_json = analyze_note(note["title"], note["content"], requested_model=payload.model)
    topics = await list_topics_for_album(session, album_id=int(note["album_id"]))
    result_json = {**(result_json or {}), "album_topics": topics}

    obj = await save_note_analysis(
        session,
        note_id=int(note["note_id"]),
        album_id=int(note["album_id"]),
        user_id=int(note["user_id"]),
        model=payload.model,
        result_type=payload.result_type,
        result_text=result_text,
        result_json=result_json,
    )
    return NoteAnalysisResponse.model_validate(obj, from_attributes=True)


@router.get("/notes/{note_id}/latest", response_model=NoteAnalysisResponse)
async def latest_note_analysis(
    note_id: int,
    session: AsyncSession = Depends(get_db_session),
    x_user_id: int = Header(alias="X-User-Id"),
):
    obj = await get_latest_note_analysis(session, note_id=note_id, user_id=x_user_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Результат анализа не найден")
    return NoteAnalysisResponse.model_validate(obj, from_attributes=True)


@router.post("/albums/{album_id}:analyze-period", response_model=PeriodAnalysisResponse)
async def analyze_period_endpoint(
    album_id: int,
    payload: PeriodAnalyzeRequest,
    session: AsyncSession = Depends(get_db_session),
    x_user_id: int = Header(alias="X-User-Id"),
):
    try:
        await assert_album_belongs_to_user(session, album_id=album_id, user_id=x_user_id)
    except LookupError:
        raise HTTPException(status_code=404, detail="Альбом не найден")

    period_from = _naive(payload.period_from)
    period_to = _naive(payload.period_to)
    if period_from > period_to:
        raise HTTPException(status_code=422, detail="period_from должен быть <= period_to")

    notes = await fetch_notes_for_period(
        session,
        album_id=album_id,
        period_from=period_from,
        period_to=period_to,
    )
    result_text, result_json = analyze_period(notes, requested_model=payload.model)
    result_json = {**(result_json or {}), "album_topics": await list_topics_for_album(session, album_id=album_id)}

    obj = await save_period_analysis(
        session,
        album_id=album_id,
        user_id=x_user_id,
        period_from=payload.period_from,
        period_to=payload.period_to,
        period_type=payload.period_type,
        analysis_type=payload.analysis_type,
        model=payload.model,
        result_text=result_text,
        result_json=result_json,
    )
    return PeriodAnalysisResponse.model_validate(obj, from_attributes=True)


@router.get("/albums/{album_id}/period-analyses", response_model=list[PeriodAnalysisResponse])
async def list_period_analyses_endpoint(
    album_id: int,
    session: AsyncSession = Depends(get_db_session),
    x_user_id: int = Header(alias="X-User-Id"),
    limit: int = 50,
):
    try:
        await assert_album_belongs_to_user(session, album_id=album_id, user_id=x_user_id)
    except LookupError:
        raise HTTPException(status_code=404, detail="Альбом не найден")

    objs = await list_period_analyses(session, album_id=album_id, user_id=x_user_id, limit=min(limit, 200))
    return [PeriodAnalysisResponse.model_validate(o, from_attributes=True) for o in objs]


@router.get("/albums/{album_id}/emotion-latest", response_model=PeriodAnalysisResponse)
async def latest_album_emotion_analysis(
    album_id: int,
    session: AsyncSession = Depends(get_db_session),
    x_user_id: int = Header(alias="X-User-Id"),
):
    try:
        await assert_album_belongs_to_user(session, album_id=album_id, user_id=x_user_id)
    except LookupError:
        raise HTTPException(status_code=404, detail="Альбом не найден")

    obj = await get_latest_period_analysis(session, album_id=album_id, user_id=x_user_id)
    if not obj:
        raise HTTPException(status_code=404, detail="Результат анализа альбома не найден")
    return PeriodAnalysisResponse.model_validate(obj, from_attributes=True)


@router.get("/topics/{topic_id}/emotion", response_model=TopicEmotionResponse)
async def topic_emotion_endpoint(
    topic_id: int,
    from_: dt.datetime | None = Query(default=None, alias="from"),
    to: dt.datetime | None = Query(default=None),
    model: str = Query(default="emotion-zero-shot-v1"),
    session: AsyncSession = Depends(get_db_session),
    x_user_id: int = Header(alias="X-User-Id"),
):
    if (from_ is None) != (to is None):
        raise HTTPException(status_code=422, detail="Параметры from и to должны быть переданы вместе")

    period_from = _naive(from_) if from_ is not None else None
    period_to = _naive(to) if to is not None else None
    if period_from is not None and period_to is not None and period_from > period_to:
        raise HTTPException(status_code=422, detail="from должен быть <= to")

    try:
        topic = await fetch_topic_with_owner(session, topic_id=topic_id, user_id=x_user_id)
    except LookupError:
        raise HTTPException(status_code=404, detail="Топик не найден")

    notes = await fetch_notes_for_topic(
        session,
        topic_id=topic_id,
        user_id=x_user_id,
        period_from=period_from,
        period_to=period_to,
    )
    payload = aggregate_topic_emotions(topic, notes, requested_model=model)
    payload["period_from"] = from_
    payload["period_to"] = to
    return TopicEmotionResponse.model_validate(payload)

