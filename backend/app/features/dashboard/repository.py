from datetime import date

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.features.event.models import Event
from app.features.photo.models import Photo
from app.features.studio.models import Studio


class DashboardRepository:

    def __init__(self, db: Session):
        self.db = db

    def get_dashboard(self, studio_id: int):

        total_events = (
            self.db.query(Event)
            .filter(Event.studio_id == studio_id)
            .count()
        )

        today_events = (
            self.db.query(Event)
            .filter(
                Event.studio_id == studio_id,
                Event.event_date == date.today(),
            )
            .count()
        )

        events = (
            self.db.query(Event.id)
            .filter(Event.studio_id == studio_id)
            .subquery()
        )

        total_photos = (
            self.db.query(Photo)
            .filter(Photo.event_id.in_(events))
            .count()
        )

        processed = (
            self.db.query(func.coalesce(func.sum(Event.processed_photos), 0))
            .filter(Event.studio_id == studio_id)
            .scalar()
        )

        failed = (
            self.db.query(func.coalesce(func.sum(Event.failed_photos), 0))
            .filter(Event.studio_id == studio_id)
            .scalar()
        )

        storage = (
            self.db.query(func.coalesce(func.sum(Photo.file_size), 0))
            .filter(Photo.event_id.in_(events))
            .scalar()
        )

        return {
            "total_events": total_events,
            "today_events": today_events,
            "total_photos": total_photos,
            "processed_photos": processed,
            "processing_photos": total_photos - processed - failed,
            "failed_photos": failed,
            "storage_used_mb": round(storage / (1024 * 1024), 2),
        }