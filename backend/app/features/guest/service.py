import shutil
import uuid
from pathlib import Path

from fastapi import HTTPException, UploadFile, status
from sqlalchemy.orm import Session

from app.features.ai.repository import AIRepository
from app.features.ai.search_service import SearchService
from app.features.guest.repository import GuestRepository

from app.core.config import settings

TEMP_DIR = Path(settings.TEMP_UPLOAD_DIR)
TEMP_DIR.mkdir(parents=True, exist_ok=True)


class GuestService:

    def __init__(
        self,
        repo: GuestRepository,
    ):
        self.repo = repo
        self.db: Session = repo.db

    def search(
        self,
        event_id: int,
        selfie: UploadFile,
    ):

        extension = Path(selfie.filename).suffix

        filename = f"{uuid.uuid4()}{extension}"

        path = TEMP_DIR / filename

        with open(path, "wb") as buffer:
            shutil.copyfileobj(selfie.file, buffer)

        try:

            ai_repo = AIRepository(self.db)

            search_service = SearchService(ai_repo)

            results = search_service.search(
                event_id=event_id,
                selfie_path=str(path),
            )
            return {
                "matches": len(results),
                "photos": results,
            }

        finally:

            if path.exists():
                path.unlink()