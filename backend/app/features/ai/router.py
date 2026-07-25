from pathlib import Path
import shutil
import uuid

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.features.ai.repository import AIRepository
from app.features.ai.search_service import SearchService

router = APIRouter(
    prefix="/ai",
    tags=["AI Search"],
)


@router.post("/events/{event_id}/search")
async def search_faces(
    event_id: int,
    selfie: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    upload_dir = Path("temp_search")
    upload_dir.mkdir(exist_ok=True)

    filename = f"{uuid.uuid4()}{Path(selfie.filename).suffix}"
    filepath = upload_dir / filename

    with filepath.open("wb") as buffer:
        shutil.copyfileobj(selfie.file, buffer)

    repo = AIRepository(db)
    service = SearchService(repo)

    try:
        matches = service.search(
            event_id=event_id,
            selfie_path=str(filepath),
        )

        return {
            "matches": matches
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e),
        )

    finally:
        if filepath.exists():
            filepath.unlink()