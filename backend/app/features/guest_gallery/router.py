import os
import shutil
import tempfile
from fastapi.responses import FileResponse
from app.features.guest_gallery.download_service import (
    GuestGalleryDownloadService,
)
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session
from app.core.rate_limiter import limiter
from app.db.session import get_db
from app.features.ai.repository import AIRepository
from app.features.guest_gallery.repository import GuestGalleryRepository
from app.features.guest_gallery.schemas import (
    CreateGalleryResponse,
    GalleryResponse,
)
from app.features.guest_gallery.service import GuestGalleryService
from fastapi import (
    APIRouter,
    Depends,
    File,
    HTTPException,
    UploadFile,
    Request,
)
from fastapi import BackgroundTasks

router = APIRouter(
    prefix="/guest-gallery",
    tags=["Guest Gallery"],
)


@router.post(
    "/events/{event_id}/search",
    response_model=CreateGalleryResponse,
)
@limiter.limit("10/minute")
def create_gallery(
    request: Request,      # <-- REQUIRED
    event_id: int,
    selfie: UploadFile = File(...),
    db: Session = Depends(get_db),
):

    suffix = os.path.splitext(selfie.filename)[1]

    with tempfile.NamedTemporaryFile(
        delete=False,
        suffix=suffix,
    ) as temp:

        shutil.copyfileobj(
            selfie.file,
            temp,
        )

        selfie_path = temp.name

    try:

        service = GuestGalleryService(
            GuestGalleryRepository(db),
            AIRepository(db),
        )

        return service.create_gallery(
            event_id=event_id,
            selfie_path=selfie_path,
        )

    finally:

        if os.path.exists(selfie_path):
            os.remove(selfie_path)


@router.get(
    "/{gallery_token}",
    response_model=GalleryResponse,
)
def get_gallery(
    gallery_token: str,
    db: Session = Depends(get_db),
):

    service = GuestGalleryService(
        GuestGalleryRepository(db),
        AIRepository(db),
    )

    gallery = service.get_gallery(
        gallery_token,
    )

    if gallery is None:
        raise HTTPException(
            status_code=404,
            detail="Gallery not found",
        )

    return gallery

@router.get(
    "/{gallery_token}/download",
)
@limiter.limit("30/hour")
def download_gallery(
    request: Request,
    background_tasks: BackgroundTasks,
    gallery_token: str,
    db: Session = Depends(get_db),
):
    service = GuestGalleryService(
        GuestGalleryRepository(db),
        AIRepository(db),
    )

    gallery = service.gallery_repo.get_gallery(
        gallery_token,
    )

    if gallery is None:
        raise HTTPException(
            status_code=404,
            detail="Gallery not found",
        )

    zip_path = GuestGalleryDownloadService().create_zip(
        gallery,
    )
    background_tasks.add_task(
        os.remove,
        zip_path,
    )

    return FileResponse(
        path=zip_path,
        filename=f"{gallery.gallery_token}.zip",
        media_type="application/zip",
    )