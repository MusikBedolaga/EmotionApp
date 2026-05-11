from __future__ import annotations

import datetime as dt
from typing import Any

from sqlalchemy import BigInteger, DateTime, Index, String, Text, func
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    pass


class AiNoteAnalysis(Base):
    __tablename__ = "note_analysis"
    __table_args__ = (
        Index("ix_ai_note_analysis_note_id_created_at", "note_id", "created_at"),
        Index("ix_ai_note_analysis_album_id_created_at", "album_id", "created_at"),
        Index("ix_ai_note_analysis_user_id_created_at", "user_id", "created_at"),
        {"schema": "ai"},
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)

    note_id: Mapped[int] = mapped_column(BigInteger, nullable=False)
    album_id: Mapped[int] = mapped_column(BigInteger, nullable=False)
    user_id: Mapped[int] = mapped_column(BigInteger, nullable=False)

    model: Mapped[str] = mapped_column(String(length=100), nullable=False)
    result_type: Mapped[str] = mapped_column(String(length=60), nullable=False)

    result_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    result_json: Mapped[dict[str, Any] | None] = mapped_column(JSONB, nullable=True)

    created_at: Mapped[dt.datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )


class AiPeriodAnalysis(Base):
    __tablename__ = "period_analysis"
    __table_args__ = (
        Index("ix_ai_period_analysis_album_period", "album_id", "period_from", "period_to"),
        Index("ix_ai_period_analysis_user_id_created_at", "user_id", "created_at"),
        {"schema": "ai"},
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True, autoincrement=True)

    album_id: Mapped[int] = mapped_column(BigInteger, nullable=False)
    user_id: Mapped[int] = mapped_column(BigInteger, nullable=False)

    period_from: Mapped[dt.datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    period_to: Mapped[dt.datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    period_type: Mapped[str] = mapped_column(String(length=30), nullable=False)  # week/month/custom
    analysis_type: Mapped[str] = mapped_column(String(length=60), nullable=False)  # summary/stats/...
    model: Mapped[str] = mapped_column(String(length=100), nullable=False)

    result_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    result_json: Mapped[dict[str, Any] | None] = mapped_column(JSONB, nullable=True)

    created_at: Mapped[dt.datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

