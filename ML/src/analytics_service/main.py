from __future__ import annotations

from fastapi import FastAPI

from analytics_service.api.routes import router as stats_router
from ml_common.config.settings import get_settings
from ml_common.observability.logging import configure_logging


def create_app() -> FastAPI:
    settings = get_settings()
    configure_logging(settings.log_level)

    app = FastAPI(title="Analytics/Stats Service", version="0.1.0")

    @app.get("/healthz")
    async def healthz() -> dict:
        return {"status": "ok"}

    app.include_router(stats_router)
    return app


app = create_app()

