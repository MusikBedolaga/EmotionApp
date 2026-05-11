from __future__ import annotations

import sqlalchemy as sa


metadata = sa.MetaData()

albums = sa.Table(
    "albums",
    metadata,
    sa.Column("id", sa.BigInteger, primary_key=True),
    sa.Column("user_id", sa.BigInteger, nullable=False),
    sa.Column("title", sa.String(length=200), nullable=False),
    sa.Column("description", sa.String(length=50)),
    sa.Column("created_at", sa.DateTime(timezone=False)),
)

notes = sa.Table(
    "notes",
    metadata,
    sa.Column("id", sa.BigInteger, primary_key=True),
    sa.Column("album_id", sa.BigInteger, nullable=False),
    sa.Column("title", sa.String(length=200), nullable=False),
    sa.Column("content", sa.Text, nullable=False),
    sa.Column("created_at", sa.DateTime(timezone=False)),
)

topics = sa.Table(
    "topics",
    metadata,
    sa.Column("id", sa.BigInteger, primary_key=True),
    sa.Column("name", sa.String(length=120), nullable=False),
    sa.Column("color", sa.String(length=20), nullable=False),
    sa.Column("created_at", sa.DateTime(timezone=False)),
)

album_topic = sa.Table(
    "album_topic",
    metadata,
    sa.Column("album_id", sa.BigInteger, nullable=False),
    sa.Column("topic_id", sa.BigInteger, nullable=False),
)

