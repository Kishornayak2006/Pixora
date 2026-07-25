from fastapi import UploadFile
from math import ceil
from app.core.exceptions import (
    DuplicatePhotoError,
    ResourceNotFoundError,
)
from app.core.file_storage import FileStorageService
from app.core.file_validator import validate_image
from app.core.hash import generate_sha256
from app.features.photo.models import Photo
from app.features.photo.repository import PhotoRepository
from app.tasks.ai_tasks import generate_embedding
from app.features.photo.enums import ProcessingStatus
from fastapi.responses import FileResponse


class PhotoService:
    def __init__(self, photo_repo: PhotoRepository):
        self.photo_repo = photo_repo
        self.storage = FileStorageService()

    def _prepare_photo(
        self,
        event_id: int,
        file: UploadFile,
    ) -> tuple[Photo | None, str |None]:
        validate_image(file)

        file_bytes = file.file.read()

        file_hash = generate_sha256(file_bytes)
        print("File:", file.filename)
        print("Hash:", file_hash)

        duplicate = self.photo_repo.get_duplicate(
            event_id,
            file_hash,
        )

        if duplicate:
            print(
                f"Duplicate -> ID={duplicate.id}, "
                f"Event={duplicate.event_id}, "
                f"Name={duplicate.original_name}"
            )
        else:
            print("Duplicate found: None")

        if duplicate:
            return None, file.filename

        unique_name, file_path = self.storage.save(
            file,
            file_bytes,
        )

        photo = Photo(
            event_id=event_id,
            original_name=file.filename,
            file_name=unique_name,
            file_path=file_path,
            mime_type=file.content_type,
            file_size=len(file_bytes),
            file_hash=file_hash,
            processing_status=ProcessingStatus.PENDING,
        )
        return photo, None

    def upload(
        self,
        owner_id: int,
        event_id: int,
        file: UploadFile,
    ) -> Photo:

        event = self.photo_repo.get_event_by_owner(
            event_id,
            owner_id,
        )

        if event is None:
            raise ResourceNotFoundError(
            "Event not found."
        )

        photo, _ = self._prepare_photo(
            event.id,
            file,
        )

        if photo is None:
            raise DuplicatePhotoError(
            "Duplicate photo detected."
        )

        photo = self.photo_repo.create(photo)

        event.total_photos += 1

        self.photo_repo.db.commit()

        print("========================")
        print("Dispatching Celery task")
        print("Photo ID:", photo.id)
        print("========================")


        generate_embedding.delay(photo.id)

        return photo

    def bulk_upload(
        self,
        owner_id: int,
        event_id: int,
        files: list[UploadFile],
    ):
        

        event = self.photo_repo.get_event_by_owner(
            event_id,
            owner_id,
        )

        if event is None:
            raise ResourceNotFoundError(
            "Event not found."
        )

        photos = []
        duplicate_files = []

        for file in files:

            photo, duplicate = self._prepare_photo(
                event.id,
                file,
            )

            if photo is None:
                duplicate_files.append(duplicate)
                continue

            photos.append(photo)

        photos = self.photo_repo.create_many(photos)

        event.total_photos += len(photos)

        self.photo_repo.db.commit()
        self.photo_repo.db.refresh(event)

        print("===================================")
        print("Photos created:", len(photos))
        print("Photo IDs:", [photo.id for photo in photos])
        print("===================================")

        for photo in photos:
            print("Dispatching Celery task for:", photo.id)

            try:
                result = generate_embedding.delay(photo.id)
                print("Task sent successfully:", result.id)
            except Exception as e:
                print("CELERY ERROR:", repr(e))

        return {
            "uploaded": len(photos),
            "duplicates": len(duplicate_files),
            "duplicate_files": duplicate_files,
        }

    def get_event_photos(
        self,
        owner_id: int,
        event_id: int,
        page: int = 1,
        page_size: int = 20,
        sort: str = "desc",
    ):
        event = self.photo_repo.get_event_by_owner(
            event_id,
            owner_id,
        )

        if event is None:
            raise ResourceNotFoundError(
                "Event not found."
            )

        print("SORT RECEIVED:", sort)

        photos, total = self.photo_repo.get_by_event_id(
            event_id,
            page,
            page_size,
            sort,
        )

        return {
            "meta": {
                "page": page,
                "page_size": page_size,
                "total": total,
                "total_pages": ceil(total / page_size) if total else 1,
            },
            "items": photos,
        }

    def delete_photo(
        self,
        owner_id: int,
        photo_id: int,
    ):
        photo = self.photo_repo.get_photo_by_owner(
            photo_id,
            owner_id,
        )

        if photo is None:
            raise ResourceNotFoundError(
                "Photo not found."
            )

        event = photo.event

        self.storage.delete(photo.file_path)

        event.total_photos -= 1

        self.photo_repo.delete(photo)

        return {
            "message": "Photo deleted successfully."
        }

    def download_photo(
        self,
        owner_id: int,
        photo_id: int,
    ):
        photo = self.photo_repo.get_photo_by_owner(
            photo_id,
            owner_id,
        )

        if photo is None:
            raise ResourceNotFoundError(
                "Photo not found."
            )

        return FileResponse(
            path=photo.file_path,
            media_type=photo.mime_type,
            filename=photo.original_name,
        )

    def get_ai_status(
        self,
        owner_id: int,
        event_id: int,
    ):
        event = self.photo_repo.get_event_by_owner(
            event_id,
            owner_id,
        )

        if event is None:
            raise ResourceNotFoundError(
                "Event not found."
            )

        return self.photo_repo.get_ai_status(event_id)

    def retry_failed_processing(
        self,
        owner_id: int,
        event_id: int,
    ):
        event = self.photo_repo.get_event_by_owner(
            event_id,
            owner_id,
        )

        if event is None:
            raise ResourceNotFoundError(
                "Event not found."
            )

        failed_photos = self.photo_repo.get_failed_photos(
            event_id,
        )

        for photo in failed_photos:
            photo.processing_status = ProcessingStatus.PENDING
            generate_embedding.delay(photo.id)

        self.photo_repo.db.commit()

        return {
            "message": f"{len(failed_photos)} photos queued for retry."
        }