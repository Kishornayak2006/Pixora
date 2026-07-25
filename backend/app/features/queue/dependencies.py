from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db

from app.features.queue.repository import QueueRepository
from app.features.queue.service import QueueService


def get_queue_service(
    db: Session = Depends(get_db),
):
    repository = QueueRepository(db)
    return QueueService(repository)