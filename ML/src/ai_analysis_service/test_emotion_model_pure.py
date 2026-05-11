"""Unit-тесты чистых функций emotion_model без загрузки Transformers."""

from __future__ import annotations

from ai_analysis_service.services.emotion_model import (
    EMOTION_LABELS,
    dominant_emotion_for_scores,
    valence_for_scores,
)


def test_emotion_labels_is_six_classes() -> None:
    assert len(EMOTION_LABELS) == 6
    assert set(EMOTION_LABELS) == {
        "joy",
        "sadness",
        "anger",
        "fear",
        "surprise",
        "neutral",
    }


def test_dominant_emotion_for_scores_resolves_tie_by_label_order() -> None:
    flat = {label: 0.2 for label in EMOTION_LABELS}
    assert dominant_emotion_for_scores(flat) == "joy"


def test_valence_for_scores_positive_when_joy_clearly_wins() -> None:
    scores = {
        "joy": 0.85,
        "sadness": 0.05,
        "anger": 0.03,
        "fear": 0.02,
        "surprise": 0.03,
        "neutral": 0.02,
    }
    assert valence_for_scores(scores) == "positive"
