from pathlib import Path
from uuid import uuid4

from fastapi import UploadFile

from app.core.config import settings


class FileStorageService:
    def __init__(self):
        self.upload_dir = Path(settings.PHOTO_UPLOAD_DIR)
        self.upload_dir.mkdir(parents=True, exist_ok=True)

    def save(self, file: UploadFile, file_bytes: bytes) -> tuple[str, str]:
        extension = Path(file.filename).suffix.lower()

        unique_name = f"{uuid4()}{extension}"

        file_path = self.upload_dir / unique_name

        with open(file_path, "wb") as image:
            image.write(file_bytes)

        return unique_name, str(file_path)

    def delete(self, file_path: str):
        path = Path(file_path)

        if path.exists():
            path.unlink()