from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db

from app.features.event.repository import EventRepository
from app.features.event.service import EventService

from app.features.photo.repository import PhotoRepository
from app.features.studio.repository import StudioRepository


def get_event_service(
    db: Session = Depends(get_db),
) -> EventService:
    return EventService(
        event_repo=EventRepository(db),
        studio_repo=StudioRepository(db),
        photo_repo=PhotoRepository(db),
    )