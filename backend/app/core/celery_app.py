from celery import Celery
from app.core.config import settings

# Register all SQLAlchemy models
import app.db.models

celery = Celery(
    "pixora",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
)

celery.conf.update(
    task_serializer="json",
    result_serializer="json",
    accept_content=["json"],
    timezone="Asia/Kolkata",
    enable_utc=True,
)

# Register Celery tasks
import app.tasks.ai_tasks