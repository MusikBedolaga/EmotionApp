from __future__ import annotations

import logging
import re
from functools import lru_cache
from typing import Mapping

from ml_common.config.settings import get_settings

log = logging.getLogger("ai_analysis_service.emotion_model")

EMOTION_LABELS = ("joy", "sadness", "anger", "fear", "surprise", "neutral")
_ZERO_SHOT_LABELS_RU = {
    "joy": "радость",
    "sadness": "грусть",
    "anger": "злость",
    "fear": "страх",
    "surprise": "удивление",
    "neutral": "нейтральность",
}
_HEURISTIC_KEYWORDS = {
    "joy": {"рад", "счастлив", "вдохновлен", "люблю", "спокойно", "получилось", "успех"},
    "sadness": {"грустно", "одиноко", "потеря", "устал", "тоскливо", "плохо"},
    "anger": {"злюсь", "бесит", "ненавижу", "раздражает", "злость", "ярость"},
    "fear": {"страшно", "тревожно", "боюсь", "паника", "страх", "переживаю"},
    "surprise": {"удивлен", "неожиданно", "внезапно", "поразило", "шок", "сюрприз"},
}
_DEFAULT_HEURISTIC_PRIOR = {
    "joy": 0.15,
    "sadness": 0.15,
    "anger": 0.12,
    "fear": 0.12,
    "surprise": 0.08,
    "neutral": 0.38,
}
_MODEL_ALIASES = {
    "emotion-zero-shot-v1": "zero-shot",
    "zero-shot-v1": "zero-shot",
}


def _normalize_scores(raw_scores: Mapping[str, float]) -> dict[str, float]:
    total = sum(max(float(raw_scores.get(label, 0.0)), 0.0) for label in EMOTION_LABELS)
    if total <= 0:
        return {label: 0.0 for label in EMOTION_LABELS}
    return {
        label: round(max(float(raw_scores.get(label, 0.0)), 0.0) / total, 4)
        for label in EMOTION_LABELS
    }


def dominant_emotion_for_scores(scores: Mapping[str, float]) -> str:
    return max(EMOTION_LABELS, key=lambda label: float(scores.get(label, 0.0)))


def valence_for_scores(scores: Mapping[str, float]) -> str:
    positive = float(scores.get("joy", 0.0))
    negative = (
        float(scores.get("sadness", 0.0))
        + float(scores.get("anger", 0.0))
        + float(scores.get("fear", 0.0))
    )
    if positive >= negative + 0.1:
        return "positive"
    if negative >= positive + 0.1:
        return "negative"
    return "neutral"


def _tokenize(text: str) -> list[str]:
    normalized = re.sub(r"[^0-9a-zа-яё_\s-]+", " ", (text or "").lower(), flags=re.IGNORECASE)
    return [token for token in re.split(r"\s+", normalized.strip()) if len(token) >= 3]


def _heuristic_scores(text: str) -> dict[str, float]:
    words = _tokenize(text)
    raw_scores = dict(_DEFAULT_HEURISTIC_PRIOR)
    for word in words:
        for emotion, keywords in _HEURISTIC_KEYWORDS.items():
            if word in keywords:
                raw_scores[emotion] += 1.0
                raw_scores["neutral"] = max(raw_scores["neutral"] - 0.1, 0.05)
    if not words:
        raw_scores["neutral"] += 1.0
    return _normalize_scores(raw_scores)


@lru_cache(maxsize=4)
def _load_zero_shot_pipeline(model_name: str, local_files_only: bool):
    try:
        from transformers import pipeline
    except Exception:
        log.exception("transformers_unavailable")
        return None

    settings = get_settings()
    try:
        return pipeline(
            task="zero-shot-classification",
            model=model_name,
            tokenizer=model_name,
            device=settings.emotion_model_device,
            local_files_only=local_files_only,
        )
    except Exception:
        log.exception("zero_shot_pipeline_init_failed", extra={"model_name": model_name})
        return None


def _zero_shot_scores(text: str, model_name: str, local_files_only: bool) -> dict[str, float] | None:
    classifier = _load_zero_shot_pipeline(model_name, local_files_only)
    if classifier is None:
        return None

    try:
        result = classifier(
            text or "",
            candidate_labels=[_ZERO_SHOT_LABELS_RU[label] for label in EMOTION_LABELS],
            hypothesis_template=get_settings().emotion_hypothesis_template,
            multi_label=True,
        )
    except Exception:
        log.exception("zero_shot_inference_failed", extra={"model_name": model_name})
        return None

    scores_by_label = {
        key: float(score)
        for label_text, score in zip(result.get("labels", []), result.get("scores", []), strict=False)
        for key, ru_label in _ZERO_SHOT_LABELS_RU.items()
        if label_text == ru_label
    }
    return _normalize_scores(scores_by_label)


def predict_emotion_scores(text: str, *, requested_model: str | None = None) -> tuple[dict[str, float], str]:
    requested_model = (requested_model or "").strip()
    settings = get_settings()
    if requested_model in {"baseline-v1", "heuristic-v1", "heuristic"}:
        return _heuristic_scores(text), "heuristic-v1"

    if settings.emotion_model_backend in {"zero-shot", "auto"}:
        model_name = settings.emotion_model_name if _MODEL_ALIASES.get(requested_model) == "zero-shot" else requested_model
        model_name = model_name or settings.emotion_model_name
        scores = _zero_shot_scores(text, model_name, settings.emotion_model_local_files_only)
        if scores is not None:
            return scores, model_name

    return _heuristic_scores(text), "heuristic-v1"
