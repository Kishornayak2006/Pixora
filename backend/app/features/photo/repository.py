from sqlalchemy import case, func
from sqlalchemy.orm import Session

from app.features.event.models import Event
from app.features.photo.enums import ProcessingStatus
from app.features.photo.models import Photo


class PhotoRepository:
    def __init__(self, db: Session):
        self.db = db

    def create(self, photo: Photo) -> Photo:
        self.db.add(photo)
        self.db.commit()
        self.db.refresh(photo)
        return photo

    def create_many(self, photos: list[Photo]) -> list[Photo]:
        self.db.add_all(photos)
        self.db.commit()

        for photo in photos:
            self.db.refresh(photo)

        return photos

    def get_event(self, event_id: int) -> Event | None:
        return (
            self.db.query(Event)
            .filter(Event.id == event_id)
            .first()
        )

    def get_by_event_id(
        self,
        event_id: int,
        page: int,
        page_size: int,
        sort: str = "desc",
    ):
        query = self.db.query(Photo).filter(
            Photo.event_id == event_id,
        )

        print("Repository sort:", sort)

        if sort == "asc":
            query = query.order_by(Photo.created_at.asc())
        else:
            query = query.order_by(Photo.created_at.desc())

        total = query.count()

        photos = (
            query.offset((page - 1) * page_size)
            .limit(page_size)
            .all()
        )

        return photos, total

    def get_by_id(self, photo_id: int):
        return (
            self.db.query(Photo)
            .filter(Photo.id == photo_id)
            .first()
        )

    def get_duplicate(
        self,
        event_id: int,
        file_hash: str,
    ):
        return (
            self.db.query(Photo)
            .filter(
                Photo.event_id == event_id,
                Photo.file_hash == file_hash,
            )
            .first()
        )

    def get_event_by_owner(
        self,
        event_id: int,
        owner_id: int,
    ):
        from app.features.studio.models import Studio

        return (
            self.db.query(Event)
            .join(Studio)
            .filter(
                Event.id == event_id,
                Studio.owner_id == owner_id,
            )
            .first()
        )

    def delete(self, photo: Photo):
        self.db.delete(photo)
        self.db.commit()

    def get_photo_by_owner(
        self,
        photo_id: int,
        owner_id: int,
    ):
        from app.features.studio.models import Studio

        return (
            self.db.query(Photo)
            .join(Event)
            .join(Studio)
            .filter(
                Photo.id == photo_id,
                Studio.owner_id == owner_id,
            )
            .first()
        )

    def get_ai_status(
        self,
        event_id: int,
    ):
        # 1. Fetch counts in a single aggregated query for high performance
        counts = (
            self.db.query(
                func.count(Photo.id).label("total"),
                func.count(
                    case((Photo.processing_status == ProcessingStatus.COMPLETED, 1))
                ).label("indexed"),
                func.count(
                    case(
                        (
                            Photo.processing_status.in_(
                                [
                                    ProcessingStatus.PENDING,
                                    ProcessingStatus.PROCESSING,
                                ]
                            ),
                            1,
                        )
                    )
                ).label("processing"),
                func.count(
                    case((Photo.processing_status == ProcessingStatus.FAILED, 1))
                ).label("failed"),
            )
            .filter(Photo.event_id == event_id)
            .first()
        )

        total = counts.total if counts else 0
        indexed = counts.indexed if counts else 0
        processing = counts.processing if counts else 0
        failed = counts.failed if counts else 0

        # 2. Fetch queue items
        active_photos = (
            self.db.query(Photo.original_name, Photo.processing_status)
            .filter(
                Photo.event_id == event_id,
                Photo.processing_status.in_(
                    [
                        ProcessingStatus.PENDING,
                        ProcessingStatus.PROCESSING,
                        ProcessingStatus.FAILED,
                    ]
                ),
            )
            .all()
        )

        processing_queue = [
            p.original_name
            for p in active_photos
            if p.processing_status in [ProcessingStatus.PENDING, ProcessingStatus.PROCESSING]
        ]
        failed_queue = [
            p.original_name
            for p in active_photos
            if p.processing_status == ProcessingStatus.FAILED
        ]

        # 3. Calculate dynamic progress percentage
        progress = (
            100.0 if total == 0 else round((indexed / total) * 100, 1)
        )

        # 4. Calculate dynamic remaining estimated time
        average_seconds = 3  # Estimated duration per image in seconds
        remaining_seconds = processing * average_seconds

        if processing == 0:
            estimated_time = "Completed"
        elif remaining_seconds < 60:
            estimated_time = f"~{remaining_seconds} sec"
        else:
            minutes = remaining_seconds // 60
            seconds = remaining_seconds % 60
            estimated_time = f"~{minutes} min {seconds} sec"

        # 5. Calculate success metrics & remaining count
        completed = indexed
        processed = indexed + failed
        success_rate = (
            round((completed / processed) * 100, 1)
            if processed > 0
            else 100.0
        )
        processing_speed = "20 photos/min"
        remaining_photos = processing

        return {
            "total_photos": total,
            "indexed_photos": indexed,
            "processing_photos": processing,
            "failed_photos": failed,
            "progress": progress,
            "estimated_time": estimated_time,
            "processing_queue": processing_queue,
            "failed_queue": failed_queue,
            "ready": processing == 0,
            "processing_speed": processing_speed,
            "success_rate": success_rate,
            "remaining_photos": remaining_photos,
        }

    def get_failed_photos(
        self,
        event_id: int,
    ):
        return (
            self.db.query(Photo)
            .filter(
                Photo.event_id == event_id,
                Photo.processing_status == ProcessingStatus.FAILED,
            )
            .all()
        )