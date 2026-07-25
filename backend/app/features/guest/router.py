from fastapi import APIRouter, Depends, File, Form, UploadFile, Request

from app.features.guest.dependencies import get_guest_service
from app.features.guest.service import GuestService
from app.core.rate_limiter import limiter

router = APIRouter(
    prefix="/guest",
    tags=["Guest"],
)


@router.post("/search")
@limiter.limit("10/minute")
def search_guest(
    request: Request,      # <-- REQUIRED
    event_id: int = Form(...),
    selfie: UploadFile = File(...),
    service: GuestService = Depends(get_guest_service),
):
    return service.search(
        event_id,
        selfie,
    )