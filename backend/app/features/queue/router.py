from fastapi import APIRouter, Depends, HTTPException

from app.features.auth.dependencies import get_current_user
from app.features.auth.models import User

from app.features.queue.dependencies import get_queue_service
from app.features.queue.schemas import QueueStatusResponse
from app.features.queue.service import QueueService

router = APIRouter(
    prefix="/queue",
    tags=["Queue"],
)


@router.get(
    "/events/{event_id}",
    response_model=QueueStatusResponse,
)
def get_queue_status(
    event_id: int,
    current_user: User = Depends(get_current_user),
    service: QueueService = Depends(get_queue_service),
):
    result = service.get_queue_status(event_id)

    if result is None:
        raise HTTPException(
            status_code=404,
            detail="Event not found",
        )

    return result