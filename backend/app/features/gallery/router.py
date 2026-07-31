from fastapi import APIRouter, Depends, HTTPException, Request
from sqlalchemy.orm import Session
from fastapi.responses import StreamingResponse
from app.db.session import get_db
from app.features.gallery.service import GalleryService

router = APIRouter(
    prefix="/gallery",
    tags=["Gallery"],
)


@router.get("/{token}")
def public_gallery(
    token: str,
    request: Request,
    db: Session = Depends(get_db),
):
    event = GalleryService(db).get_gallery(token)

    if not event:
        raise HTTPException(
            status_code=404,
            detail="Gallery not found",
        )

    base_url = str(request.base_url).rstrip("/")

    return {
        "event_id": event.id,
        "event_name": event.event_name,
        "cover_image": event.cover_image,
        "photos": [
            {
                "id": photo.id,
                "file_name": photo.file_name,
                "image_url": f"{base_url}/{photo.file_path.replace('\\', '/')}",
            }
            for photo in event.photos
        ],
    }

@router.get("/{token}/download")
def download_gallery(
    token: str,
    db: Session = Depends(get_db),
):
    service = GalleryService(db)

    event = service.get_gallery(token)

    if not event:
        raise HTTPException(
            status_code=404,
            detail="Gallery not found",
        )

    zip_file = service.create_zip(event)

    filename = f"{event.event_name}.zip"

    return StreamingResponse(
        zip_file,
        media_type="application/zip",
        headers={
            "Content-Disposition": f'attachment; filename="{filename}"'
        },
    )