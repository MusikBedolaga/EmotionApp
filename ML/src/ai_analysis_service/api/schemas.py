from __future__ import annotations

import datetime as dt
from typing import Any, Literal

from pydantic import BaseModel, Field

EmotionLabel = Literal["joy", "sadness", "anger", "fear", "surprise", "neutral"]
ValenceLabel = Literal["positive", "neutral", "negative"]


class AlbumTopicSummary(BaseModel):
    id: int
    name: str
    color: str


class EmotionScores(BaseModel):
    joy: float = 0.0
    sadness: float = 0.0
    anger: float = 0.0
    fear: float = 0.0
    surprise: float = 0.0
    neutral: float = 0.0


class EmotionCounts(BaseModel):
    joy: int = 0
    sadness: int = 0
    anger: int = 0
    fear: int = 0
    surprise: int = 0
    neutral: int = 0


class NoteEmotionResult(BaseModel):
    summary: str | None = None
    word_count: int = 0
    top_words: list[str] = Field(default_factory=list)
    emotion_scores: EmotionScores = Field(default_factory=EmotionScores)
    dominant_emotion: EmotionLabel = "neutral"
    valence: ValenceLabel = "neutral"
    confidence: float = 0.0
    model_backend: str = "heuristic-v1"
    album_topics: list[AlbumTopicSummary] = Field(default_factory=list)


class PeriodEmotionResult(BaseModel):
    summary: str | None = None
    notes_count: int = 0
    total_words: int = 0
    top_words: list[str] = Field(default_factory=list)
    emotion_distribution: EmotionScores = Field(default_factory=EmotionScores)
    dominant_emotion: EmotionLabel = "neutral"
    valence: ValenceLabel = "neutral"
    confidence: float = 0.0
    note_emotion_counts: EmotionCounts = Field(default_factory=EmotionCounts)
    model_backend: str = "heuristic-v1"
    album_topics: list[AlbumTopicSummary] = Field(default_factory=list)


class TopicEmotionResponse(BaseModel):
    topic_id: int
    name: str
    color: str
    album_count: int
    note_count: int
    summary: str | None = None
    top_words: list[str] = Field(default_factory=list)
    emotion_distribution: EmotionScores = Field(default_factory=EmotionScores)
    dominant_emotion: EmotionLabel = "neutral"
    valence: ValenceLabel = "neutral"
    confidence: float = 0.0
    model_backend: str = "heuristic-v1"
    period_from: dt.datetime | None = None
    period_to: dt.datetime | None = None


class NoteAnalyzeRequest(BaseModel):
    model: str = "emotion-zero-shot-v1"
    result_type: str = "emotion_profile"


class NoteAnalysisResponse(BaseModel):
    id: int
    note_id: int
    album_id: int
    user_id: int
    model: str
    result_type: str
    result_text: str | None
    result_json: NoteEmotionResult | dict[str, Any] | None
    created_at: dt.datetime


class PeriodAnalyzeRequest(BaseModel):
    period_from: dt.datetime
    period_to: dt.datetime
    period_type: str = Field(default="custom", pattern="^(week|month|custom)$")
    analysis_type: str = "emotion_period_report"
    model: str = "emotion-zero-shot-v1"


class PeriodAnalysisResponse(BaseModel):
    id: int
    album_id: int
    user_id: int
    period_from: dt.datetime
    period_to: dt.datetime
    period_type: str
    analysis_type: str
    model: str
    result_text: str | None
    result_json: PeriodEmotionResult | dict[str, Any] | None
    created_at: dt.datetime

