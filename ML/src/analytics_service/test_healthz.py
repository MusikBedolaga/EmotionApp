"""Синхронные smoke-тесты HTTP без поднятия БД (только /healthz)."""

from __future__ import annotations

from starlette.testclient import TestClient

from analytics_service.main import app


def test_healthz_returns_ok() -> None:
    client = TestClient(app)
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_openapi_docs_available() -> None:
    client = TestClient(app)
    response = client.get("/docs")
    assert response.status_code == 200
