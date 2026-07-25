from sqlalchemy import select
from sqlalchemy.orm import Session

from app.features.studio.models import Studio


class StudioRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, studio: Studio) -> Studio:
        self.db.add(studio)
        self.db.commit()
        self.db.refresh(studio)
        return studio

    def get_by_owner_id(self, owner_id: int) -> Studio | None:
        stmt = select(Studio).where(Studio.owner_id == owner_id)
        return self.db.execute(stmt).scalar_one_or_none()

    def update(self, studio: Studio) -> Studio:
        self.db.commit()
        self.db.refresh(studio)
        return studio

    def delete(self, studio: Studio) -> None:
        self.db.delete(studio)
        self.db.commit()