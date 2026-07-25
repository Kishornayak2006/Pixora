import app.db.models
from app.db.session import SessionLocal
from app.features.ai.repository import AIRepository
from app.features.ai.service import AIService

from app.core.celery_app import celery


@celery.task(name="app.tasks.ai_tasks.generate_embedding")
def generate_embedding(photo_id: int):
    print("========== TASK START ==========")
    print("Photo ID:", photo_id)

    db = SessionLocal()

    try:
        print("Creating AIRepository...")
        repo = AIRepository(db)

        print("Creating AIService...")
        service = AIService(repo)

        print("Calling generate_embeddings()...")
        service.generate_embeddings(photo_id)

        print("Returned from generate_embeddings()")

    finally:
        db.close()

    print("========== TASK END ==========")