import os
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base


# Get the database URL from environment variable or use a default
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql+asyncpg://user:password@localhost:5432/mydatabase")


# Create the SQLAlchemy async engine
engine = create_async_engine(DATABASE_URL, echo=True, future=True)

# Create a configured "AsyncSession" class
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    class_=AsyncSession
)


# Base class for models
Base = declarative_base()


# Dependency for getting async DB session (for use in FastAPI, etc.)
async def get_db():
    async with SessionLocal() as db:
        try:
            yield db
        finally:
            await db.close()
