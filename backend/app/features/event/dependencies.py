from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.features.event.repository import EventRepository
from app.features.event.service import EventService
from app.features.studio.repository import StudioRepository


def get_event_service(
    db: Session = Depends(get_db),
) -> EventService:
    return EventService(
        EventRepository(db),
        StudioRepository(db),
    )