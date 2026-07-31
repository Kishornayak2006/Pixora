from fastapi import APIRouter, Depends, status
from app.features.event.schemas import (
    EventCreate,
    EventResponse,
    SetCoverPhotoRequest,
)   
from app.features.auth.dependencies import get_current_user
from app.features.auth.models import User
from app.features.event.dependencies import get_event_service
from app.features.event.schemas import EventCreate, EventResponse
from app.features.event.service import EventService

router = APIRouter(
    prefix="/events",
    tags=["Events"],
)


@router.post(
    "",
    response_model=EventResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_event(
    event: EventCreate,
    current_user: User = Depends(get_current_user),
    service: EventService = Depends(get_event_service),
):
    return service.create(
        event,
        current_user,
    )

@router.get(
    "",
    response_model=list[EventResponse],
)
def get_my_events(
    current_user: User = Depends(get_current_user),
    service: EventService = Depends(get_event_service),
):
    return service.get_my_events(current_user)

@router.put(
    "/{event_id}",
    response_model=EventResponse,
)
def update_event(
    event_id: int,
    event_data: EventCreate,
    current_user: User = Depends(get_current_user),
    service: EventService = Depends(get_event_service),
):
    return service.update(
        current_user,
        event_id,
        event_data,
    )


@router.delete(
    "/{event_id}",
    status_code=204,
)
def delete_event(
    event_id: int,
    current_user: User = Depends(get_current_user),
    service: EventService = Depends(get_event_service),
):
    service.delete(
        current_user,
        event_id,
    )

@router.get("/{event_id}/progress")
def get_progress(
    event_id: int,
    service: EventService = Depends(get_event_service),
):
    return service.get_progress(event_id)

@router.patch(
    "/{event_id}/cover",
    response_model=EventResponse,
)
def set_cover_photo(
    event_id: int,
    body: SetCoverPhotoRequest,
    current_user: User = Depends(get_current_user),
    service: EventService = Depends(get_event_service),
):
    return service.set_cover_photo(
        current_user=current_user,
        event_id=event_id,
        photo_id=body.photo_id,
    )