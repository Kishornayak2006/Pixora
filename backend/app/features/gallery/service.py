from sqlalchemy.orm import Session
import io
import zipfile
from pathlib import Path
from app.features.gallery.repository import GalleryRepository


class GalleryService:
    def __init__(self, db: Session):
        self.repo = GalleryRepository(db)

    def get_gallery(self, token: str):
        event = self.repo.get_event_by_token(token)

        if not event:
            return None

        return event
    
    def create_zip(self, event):
        memory_file = io.BytesIO()

        with zipfile.ZipFile(
            memory_file,
            mode="w",
            compression=zipfile.ZIP_DEFLATED,
        ) as zf:

            for photo in event.photos:
                file_path = Path(photo.file_path)

                if file_path.exists():
                    zf.write(
                        file_path,
                        arcname=file_path.name,
                    )

        memory_file.seek(0)

        return memory_file