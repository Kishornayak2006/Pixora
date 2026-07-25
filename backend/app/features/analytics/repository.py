from sqlalchemy import extract, func
from sqlalchemy.orm import Session

from app.features.event.models import Event
from app.features.photo.models import Photo


class AnalyticsRepository:

    def __init__(self, db: Session):
        self.db = db

    MONTHS = [
        "",
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
    ]

    # ==========================================================
    # Monthly Events
    # ==========================================================

    def monthly_events(self, studio_id: int):

        rows = (
            self.db.query(
                extract("month", Event.event_date).label("month"),
                func.count(Event.id).label("count"),
            )
            .filter(Event.studio_id == studio_id)
            .group_by(extract("month", Event.event_date))
            .order_by(extract("month", Event.event_date))
            .all()
        )

        return [
            {
                "month": self.MONTHS[int(row.month)],
                "count": row.count,
            }
            for row in rows
        ]

    # ==========================================================
    # Monthly Photos
    # ==========================================================

    def monthly_photos(self, studio_id: int):

        rows = (
            self.db.query(
                extract("month", Photo.created_at).label("month"),
                func.count(Photo.id).label("photos"),
            )
            .join(Event, Event.id == Photo.event_id)
            .filter(Event.studio_id == studio_id)
            .group_by(extract("month", Photo.created_at))
            .order_by(extract("month", Photo.created_at))
            .all()
        )

        return [
            {
                "month": self.MONTHS[int(row.month)],
                "photos": row.photos,
            }
            for row in rows
        ]

    # ==========================================================
    # Event Types
    # ==========================================================

    def event_types(self, studio_id: int):

        rows = (
            self.db.query(
                Event.event_type,
                func.count(Event.id).label("count"),
            )
            .filter(Event.studio_id == studio_id)
            .group_by(Event.event_type)
            .order_by(func.count(Event.id).desc())
            .all()
        )

        return [
            {
                "event_type": row.event_type,
                "count": row.count,
            }
            for row in rows
        ]

    # ==========================================================
    # Processing Statistics
    # ==========================================================

    def processing_stats(self, studio_id: int):

        processed = (
            self.db.query(
                func.coalesce(func.sum(Event.processed_photos), 0)
            )
            .filter(Event.studio_id == studio_id)
            .scalar()
        )

        failed = (
            self.db.query(
                func.coalesce(func.sum(Event.failed_photos), 0)
            )
            .filter(Event.studio_id == studio_id)
            .scalar()
        )

        total = (
            self.db.query(
                func.coalesce(func.sum(Event.total_photos), 0)
            )
            .filter(Event.studio_id == studio_id)
            .scalar()
        )

        processing = max(total - processed - failed, 0)

        return {
            "processed": processed,
            "processing": processing,
            "failed": failed,
        }

    # ==========================================================
    # Storage Statistics
    # ==========================================================

    def storage_stats(self, studio_id: int):

        rows = (
            self.db.query(
                extract("month", Photo.created_at).label("month"),
                func.sum(Photo.file_size).label("storage"),
            )
            .join(Event, Event.id == Photo.event_id)
            .filter(Event.studio_id == studio_id)
            .group_by(extract("month", Photo.created_at))
            .order_by(extract("month", Photo.created_at))
            .all()
        )

        return [
            {
                "month": self.MONTHS[int(row.month)],
                "storage_mb": round((row.storage or 0) / (1024 * 1024), 2),
            }
            for row in rows
        ]