from fastapi import (
    APIRouter,
    Depends,
    File,
    Form,
    UploadFile,
    Request,
)

from app.features.auth.dependencies import get_current_user
from app.features.auth.models import User
from app.features.photo.dependencies import get_photo_service
from app.features.photo.schemas import (
    PhotoResponse,
    BulkUploadResponse,
    PhotoPaginationResponse,
)
from app.features.photo.service import PhotoService
from app.core.rate_limiter import limiter
from fastapi import Request


router = APIRouter(
    prefix="/photos",
    tags=["Photos"],
)


@router.post(
    "/upload",
    response_model=PhotoResponse,
)
def upload_photo(
    event_id: int = Form(...),
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    service: PhotoService = Depends(get_photo_service),
):
    return service.upload(
        owner_id=current_user.id,
        event_id=event_id,
        file=file,
    )


@router.post("/bulk-upload")
@limiter.limit("20/hour")
def bulk_upload(
    request: Request,
    event_id: int = Form(...),
    files: list[UploadFile] = File(...),
    current_user: User = Depends(get_current_user),
    service: PhotoService = Depends(get_photo_service),
):
    return service.bulk_upload(
        owner_id=current_user.id,
        event_id=event_id,
        files=files,
    )


@router.post("/bulk-upload-test")
async def bulk_upload_test(
    event_id: int = Form(...),
    files: list[UploadFile] = File(...),
):
    return {
        "event_id": event_id,
        "count": len(files),
        "names": [file.filename for file in files],
    }


@router.get(
    "/event/{event_id}",
    response_model=PhotoPaginationResponse,
)
def get_event_photos(
    event_id: int,
    page: int = 1,
    page_size: int = 20,
    sort: str = "desc",
    current_user: User = Depends(get_current_user),
    service: PhotoService = Depends(get_photo_service),
):
    return service.get_event_photos(
        owner_id=current_user.id,
        event_id=event_id,
        page=page,
        page_size=page_size,
        sort=sort,
    )

@router.delete("/{photo_id}")
def delete_photo(
    photo_id: int,
    current_user: User = Depends(get_current_user),
    service: PhotoService = Depends(get_photo_service),
):
    return service.delete_photo(
        owner_id=current_user.id,
        photo_id=photo_id,
    )

@router.get("/{photo_id}/download")
def download_photo(
    photo_id: int,
    current_user: User = Depends(get_current_user),
    service: PhotoService = Depends(get_photo_service),
):
    return service.download_photo(
        owner_id=current_user.id,
        photo_id=photo_id,
    )

@router.get("/event/{event_id}/ai-status")
def get_ai_status(
    event_id: int,
    current_user: User = Depends(get_current_user),
    service: PhotoService = Depends(get_photo_service),
):
    return service.get_ai_status(
        owner_id=current_user.id,
        event_id=event_id,
    )

@router.post("/event/{event_id}/retry-processing")
def retry_failed_processing(
    event_id: int,
    current_user: User = Depends(get_current_user),
    service: PhotoService = Depends(get_photo_service),
):
    return service.retry_failed_processing(
        owner_id=current_user.id,
        event_id=event_id,
    )