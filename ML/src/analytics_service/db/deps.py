from __future__ import annotations

from collections.abc import AsyncIterator

from sqlalchemy.ext.asyncio import AsyncSession

from ml_common.db.session import get_sessionmaker


async def get_db_session() -> AsyncIterator[AsyncSession]:
    session_maker = get_sessionmaker()
    async with session_maker() as session:
        yield session

