from sqlalchemy.orm import Session

from app.db.models.face_embedding import FaceEmbedding
from app.features.guest.models import Guest


class GuestRepository:

    def __init__(self, db: Session):
        self.db = db

    def create(
        self,
        guest: Guest,
    ) -> Guest:
        self.db.add(guest)
        self.db.commit()
        self.db.refresh(guest)
        return guest

    def get_event_embeddings(
        self,
        event_id: int,
    ):
        return (
            self.db.query(FaceEmbedding)
            .join(FaceEmbedding.photo)
            .filter_by(event_id=event_id)
            .all()
        )