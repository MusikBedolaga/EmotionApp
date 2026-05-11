from __future__ import annotations

import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB


metadata = sa.MetaData()

ai_note_analysis = sa.Table(
    "note_analysis",
    metadata,
    sa.Column("id", sa.BigInteger, primary_key=True),
    sa.Column("note_id", sa.BigInteger, nullable=False),
    sa.Column("album_id", sa.BigInteger, nullable=False),
    sa.Column("user_id", sa.BigInteger, nullable=False),
    sa.Column("model", sa.String(length=100), nullable=False),
    sa.Column("result_type", sa.String(length=60), nullable=False),
    sa.Column("result_text", sa.Text),
    sa.Column("result_json", JSONB),
    sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    schema="ai",
)

ai_period_analysis = sa.Table(
    "period_analysis",
    metadata,
    sa.Column("id", sa.BigInteger, primary_key=True),
    sa.Column("album_id", sa.BigInteger, nullable=False),
    sa.Column("user_id", sa.BigInteger, nullable=False),
    sa.Column("period_from", sa.DateTime(timezone=True), nullable=False),
    sa.Column("period_to", sa.DateTime(timezone=True), nullable=False),
    sa.Column("period_type", sa.String(length=30), nullable=False),
    sa.Column("analysis_type", sa.String(length=60), nullable=False),
    sa.Column("model", sa.String(length=100), nullable=False),
    sa.Column("result_text", sa.Text),
    sa.Column("result_json", JSONB),
    sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
    schema="ai",
)

