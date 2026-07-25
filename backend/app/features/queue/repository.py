from datetime import datetime, timedelta

from sqlalchemy.orm import Session

from app.features.event.models import Event


class QueueRepository:

    def __init__(self, db: Session):
        self.db = db

    def get_queue_status(self, event_id: int):

        event = (
            self.db.query(Event)
            .filter(Event.id == event_id)
            .first()
        )

        if not event:
            return None

        total = event.total_photos
        processed = event.processed_photos
        failed = event.failed_photos

        remaining = max(total - processed - failed, 0)

        progress = (
            round(((processed + failed) / total) * 100, 2)
            if total > 0
            else 0
        )

        # -------------------------------------------------------
        # Status
        # -------------------------------------------------------

        if total == 0:
            status = "waiting"

        elif processed + failed >= total:
            status = "completed"

        else:
            status = "processing"

        # -------------------------------------------------------
        # ETA Calculation
        # -------------------------------------------------------

        eta_seconds = 0
        estimated_completion = None

        if status == "processing":

            elapsed = (
                datetime.utcnow() - event.created_at
            ).total_seconds()

            completed = processed + failed

            if completed > 0:

                avg_per_photo = elapsed / completed

                eta_seconds = int(
                    remaining * avg_per_photo
                )

                estimated_completion = (
                    datetime.utcnow()
                    + timedelta(seconds=eta_seconds)
                )

        return {
            "status": status,
            "total_photos": total,
            "processed_photos": processed,
            "failed_photos": failed,
            "remaining_photos": remaining,
            "progress": progress,
            "eta_seconds": eta_seconds,
            "estimated_completion": estimated_completion,
        }