"""create ai schema and tables

Revision ID: 0001_create_ai
Revises: None
Create Date: 2026-03-11

"""

from __future__ import annotations

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = "0001_create_ai"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.execute("CREATE SCHEMA IF NOT EXISTS ai")

    op.create_table(
        "note_analysis",
        sa.Column("id", sa.BigInteger(), primary_key=True, autoincrement=True),
        sa.Column("note_id", sa.BigInteger(), nullable=False),
        sa.Column("album_id", sa.BigInteger(), nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("model", sa.String(length=100), nullable=False),
        sa.Column("result_type", sa.String(length=60), nullable=False),
        sa.Column("result_text", sa.Text(), nullable=True),
        sa.Column("result_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        schema="ai",
    )
    op.create_index(
        "ix_ai_note_analysis_note_id_created_at",
        "note_analysis",
        ["note_id", "created_at"],
        schema="ai",
    )
    op.create_index(
        "ix_ai_note_analysis_album_id_created_at",
        "note_analysis",
        ["album_id", "created_at"],
        schema="ai",
    )
    op.create_index(
        "ix_ai_note_analysis_user_id_created_at",
        "note_analysis",
        ["user_id", "created_at"],
        schema="ai",
    )

    op.create_table(
        "period_analysis",
        sa.Column("id", sa.BigInteger(), primary_key=True, autoincrement=True),
        sa.Column("album_id", sa.BigInteger(), nullable=False),
        sa.Column("user_id", sa.BigInteger(), nullable=False),
        sa.Column("period_from", sa.DateTime(timezone=True), nullable=False),
        sa.Column("period_to", sa.DateTime(timezone=True), nullable=False),
        sa.Column("period_type", sa.String(length=30), nullable=False),
        sa.Column("analysis_type", sa.String(length=60), nullable=False),
        sa.Column("model", sa.String(length=100), nullable=False),
        sa.Column("result_text", sa.Text(), nullable=True),
        sa.Column("result_json", postgresql.JSONB(astext_type=sa.Text()), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("now()"), nullable=False),
        schema="ai",
    )
    op.create_index(
        "ix_ai_period_analysis_album_period",
        "period_analysis",
        ["album_id", "period_from", "period_to"],
        schema="ai",
    )
    op.create_index(
        "ix_ai_period_analysis_user_id_created_at",
        "period_analysis",
        ["user_id", "created_at"],
        schema="ai",
    )


def downgrade() -> None:
    op.drop_index("ix_ai_period_analysis_user_id_created_at", table_name="period_analysis", schema="ai")
    op.drop_index("ix_ai_period_analysis_album_period", table_name="period_analysis", schema="ai")
    op.drop_table("period_analysis", schema="ai")

    op.drop_index("ix_ai_note_analysis_user_id_created_at", table_name="note_analysis", schema="ai")
    op.drop_index("ix_ai_note_analysis_album_id_created_at", table_name="note_analysis", schema="ai")
    op.drop_index("ix_ai_note_analysis_note_id_created_at", table_name="note_analysis", schema="ai")
    op.drop_table("note_analysis", schema="ai")

    op.execute("DROP SCHEMA IF EXISTS ai")

