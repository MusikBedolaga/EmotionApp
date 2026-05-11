from __future__ import annotations

from ai_analysis_service.services import analyzer


def _fake_predict(_: str, *, requested_model: str | None = None):
    if requested_model == "sad-model":
        return (
            {
                "joy": 0.05,
                "sadness": 0.6,
                "anger": 0.1,
                "fear": 0.1,
                "surprise": 0.05,
                "neutral": 0.1,
            },
            "fake-sad-model",
        )
    return (
        {
            "joy": 0.62,
            "sadness": 0.08,
            "anger": 0.05,
            "fear": 0.05,
            "surprise": 0.1,
            "neutral": 0.1,
        },
        "fake-joy-model",
    )


def test_analyze_note_returns_emotion_contract(monkeypatch):
    monkeypatch.setattr(analyzer, "predict_emotion_scores", _fake_predict)

    summary, payload = analyzer.analyze_note("Лучший день", "Сегодня я очень рад и спокоен.")

    assert summary == payload["summary"]
    assert payload["dominant_emotion"] == "joy"
    assert payload["valence"] == "positive"
    assert payload["model_backend"] == "fake-joy-model"
    assert payload["top_words"]


def test_analyze_period_aggregates_note_level_predictions(monkeypatch):
    monkeypatch.setattr(analyzer, "predict_emotion_scores", _fake_predict)

    summary, payload = analyzer.analyze_period(
        [
            {"album_id": 1, "title": "Первая", "content": "Радостный день"},
            {"album_id": 1, "title": "Вторая", "content": "Мне все еще спокойно"},
        ]
    )

    assert summary == payload["summary"]
    assert payload["notes_count"] == 2
    assert payload["dominant_emotion"] == "joy"
    assert payload["emotion_distribution"]["joy"] > payload["emotion_distribution"]["sadness"]
    assert payload["note_emotion_counts"]["joy"] == 2


def test_aggregate_topic_emotions_counts_albums(monkeypatch):
    monkeypatch.setattr(analyzer, "predict_emotion_scores", _fake_predict)

    payload = analyzer.aggregate_topic_emotions(
        {"id": 7, "name": "Работа", "color": "#111111"},
        [
            {"album_id": 10, "title": "A", "content": "Радостный день"},
            {"album_id": 11, "title": "B", "content": "Тяжелый день"},
        ],
        requested_model="sad-model",
    )

    assert payload["topic_id"] == 7
    assert payload["album_count"] == 2
    assert payload["note_count"] == 2
    assert payload["dominant_emotion"] == "sadness"
    assert payload["model_backend"] == "fake-sad-model"
