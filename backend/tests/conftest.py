import pytest

from unittest.mock import patch

from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.main import app as fastapi_app
from app.core.config import settings
from app.db.base import Base
from app.db.session import get_db

# Import all models so SQLAlchemy can create tables
import app.db.models  # noqa: F401


# -------------------------------
# Test Database
# -------------------------------
engine = create_engine(
    settings.TEST_DATABASE_URL,
    pool_pre_ping=True,
)

TestingSessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
)


# -------------------------------
# Create & Drop Tables
# -------------------------------
@pytest.fixture(scope="session", autouse=True)
def setup_database():
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

    yield

    Base.metadata.drop_all(bind=engine)


# -------------------------------
# Dependency Override
# -------------------------------
def override_get_db():
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()


fastapi_app.dependency_overrides[get_db] = override_get_db


# -------------------------------
# Mock Celery Tasks
# -------------------------------
@pytest.fixture(autouse=True)
def mock_celery():
    with patch(
        "app.features.photo.service.generate_embedding.delay",
        return_value=None,
    ):
        yield


# -------------------------------
# Test Client
# -------------------------------
@pytest.fixture(scope="function")
def client():
    return TestClient(fastapi_app)