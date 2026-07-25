from sqlalchemy.orm import Session

from app.features.event.models import Event


class GalleryRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_event_by_token(self, token: str):
        return (
            self.db.query(Event)
            .filter(Event.gallery_token == token)
            .first()
        )