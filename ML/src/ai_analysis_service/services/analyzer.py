from __future__ import annotations

import re
from collections import Counter
from typing import Any

from ai_analysis_service.services.emotion_model import (
    EMOTION_LABELS,
    dominant_emotion_for_scores,
    predict_emotion_scores,
    valence_for_scores,
)


def _tokens(text: str) -> list[str]:
    text = text.lower()
    text = re.sub(r"[^0-9a-zа-яё_\s-]+", " ", text, flags=re.IGNORECASE)
    parts = re.split(r"\s+", text.strip())
    return [p for p in parts if len(p) >= 3]


def _build_summary(text: str, max_chars: int) -> str:
    summary = (text or "").strip().replace("\n", " ")
    if len(summary) > max_chars:
        summary = summary[:max_chars].rstrip() + "…"
    return summary


def _top_words(text: str, limit: int) -> list[str]:
    return [word for word, _ in Counter(_tokens(text)).most_common(limit)]


def _empty_emotion_scores() -> dict[str, float]:
    return {emotion: 0.0 for emotion in EMOTION_LABELS}


def _average_scores(items: list[dict[str, float]]) -> dict[str, float]:
    if not items:
        return {"joy": 0.0, "sadness": 0.0, "anger": 0.0, "fear": 0.0, "surprise": 0.0, "neutral": 1.0}
    totals = {emotion: 0.0 for emotion in EMOTION_LABELS}
    for item in items:
        for emotion in EMOTION_LABELS:
            totals[emotion] += float(item.get(emotion, 0.0))
    return {emotion: round(totals[emotion] / len(items), 4) for emotion in EMOTION_LABELS}


def predict_note_emotions(
    title: str,
    content: str,
    *,
    requested_model: str | None = None,
) -> dict[str, Any]:
    text = f"{title}\n{content}".strip()
    words = _tokens(text)
    emotion_scores, model_backend = predict_emotion_scores(text, requested_model=requested_model)
    dominant_emotion = dominant_emotion_for_scores(emotion_scores)
    return {
        "summary": _build_summary(content or title, max_chars=240),
        "word_count": len(words),
        "top_words": _top_words(text, limit=10),
        "emotion_scores": emotion_scores,
        "dominant_emotion": dominant_emotion,
        "valence": valence_for_scores(emotion_scores),
        "confidence": round(float(emotion_scores.get(dominant_emotion, 0.0)), 4),
        "model_backend": model_backend,
    }


def aggregate_album_emotions(
    note_predictions: list[dict[str, Any]],
    note_entries: list[dict[str, Any]],
) -> dict[str, Any]:
    joined_text = "\n".join(f'{entry.get("title", "")}\n{entry.get("content", "")}'.strip() for entry in note_entries).strip()
    emotion_distribution = _average_scores(
        [prediction.get("emotion_scores", _empty_emotion_scores()) for prediction in note_predictions]
    )
    dominant_emotion = dominant_emotion_for_scores(emotion_distribution)
    dominant_counts = Counter(prediction.get("dominant_emotion", "neutral") for prediction in note_predictions)
    model_backend = next(
        (str(prediction.get("model_backend")) for prediction in note_predictions if prediction.get("model_backend")),
        "heuristic-v1",
    )
    return {
        "summary": _build_summary(joined_text, max_chars=500),
        "notes_count": len(note_entries),
        "total_words": sum(int(prediction.get("word_count", 0)) for prediction in note_predictions),
        "top_words": _top_words(joined_text, limit=20),
        "emotion_distribution": emotion_distribution,
        "dominant_emotion": dominant_emotion,
        "valence": valence_for_scores(emotion_distribution),
        "confidence": round(float(emotion_distribution.get(dominant_emotion, 0.0)), 4),
        "note_emotion_counts": {emotion: int(dominant_counts.get(emotion, 0)) for emotion in EMOTION_LABELS},
        "model_backend": model_backend,
    }


def aggregate_topic_emotions(
    topic: dict[str, Any],
    note_entries: list[dict[str, Any]],
    *,
    requested_model: str | None = None,
) -> dict[str, Any]:
    note_predictions = [
        predict_note_emotions(
            entry.get("title", ""),
            entry.get("content", ""),
            requested_model=requested_model,
        )
        for entry in note_entries
    ]
    aggregate = aggregate_album_emotions(note_predictions, note_entries)
    return {
        "topic_id": int(topic["id"]),
        "name": topic["name"],
        "color": topic["color"],
        "album_count": len({int(entry["album_id"]) for entry in note_entries if entry.get("album_id") is not None}),
        "note_count": len(note_entries),
        "summary": aggregate["summary"],
        "top_words": aggregate["top_words"],
        "emotion_distribution": aggregate["emotion_distribution"],
        "dominant_emotion": aggregate["dominant_emotion"],
        "valence": aggregate["valence"],
        "confidence": aggregate["confidence"],
        "model_backend": aggregate["model_backend"],
    }


def analyze_note(
    title: str,
    content: str,
    *,
    requested_model: str | None = None,
) -> tuple[str, dict[str, Any]]:
    result = predict_note_emotions(title, content, requested_model=requested_model)
    return str(result["summary"]), result


def analyze_period(
    note_entries: list[dict[str, Any]],
    *,
    requested_model: str | None = None,
) -> tuple[str, dict[str, Any]]:
    note_predictions = [
        predict_note_emotions(
            entry.get("title", ""),
            entry.get("content", ""),
            requested_model=requested_model,
        )
        for entry in note_entries
    ]
    result = aggregate_album_emotions(note_predictions, note_entries)
    return str(result["summary"]), result

