from __future__ import annotations

import datetime as dt

from pydantic import BaseModel, Field


class TimeseriesPoint(BaseModel):
    bucket_start: dt.datetime
    count: int


class AlbumTopRow(BaseModel):
    album_id: int
    notes_count: int


class TopicUsageRow(BaseModel):
    topic_id: int
    name: str
    color: str
    notes_count: int


class AiActivityPoint(BaseModel):
    bucket_start: dt.datetime
    count: int


class BucketParam(BaseModel):
    bucket: str = Field(pattern="^(day|week|month)$")

