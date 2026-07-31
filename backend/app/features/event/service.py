from fastapi import HTTPException, status
from app.features.photo.repository import PhotoRepository
from app.features.auth.models import User
from app.features.event.models import Event
from app.features.event.repository import EventRepository
from app.features.event.schemas import EventCreate
from app.features.studio.repository import StudioRepository
from app.core.permissions import (
    verify_event_owner,
    verify_studio_owner,
)

class EventService:
    def __init__(
        self,
        event_repo: EventRepository,
        studio_repo: StudioRepository,
        photo_repo: PhotoRepository,
    ):
        self.event_repo = event_repo
        self.studio_repo = studio_repo
        self.photo_repo = photo_repo

    def create(
        self,
        event_data: EventCreate,
        current_user: User,
    ) -> Event:

        studio = verify_studio_owner(current_user)

        event = Event(
            studio_id=studio.id,
            **event_data.model_dump(),
        )

        return self.event_repo.create(event)
    
    def get_my_events(
        self,
        current_user: User,
    ) -> list[Event]:

        studio = verify_studio_owner(current_user)

        return self.event_repo.get_by_studio_id(studio.id)
    
    def update(
        self,
        current_user: User,
        event_id: int,
        data: EventCreate,
    ):
        event = self.event_repo.get_by_id(event_id)

        if event is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found.",
            )

        verify_event_owner(
            current_user,
            event,
        )

        for key, value in data.model_dump().items():
            setattr(event, key, value)

        return self.event_repo.update(event)


    def delete(
        self,
        current_user: User,
        event_id: int,
    ):
        event = self.event_repo.get_by_id(event_id)

        if event is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found.",
            )

        verify_event_owner(
            current_user,
            event,
        )

        self.event_repo.delete(event)

    def get_progress(self, event_id: int):
        event = self.event_repo.get(event_id)

        if event is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found."
            )

        remaining = max(
            event.total_photos
            - event.processed_photos
            - event.failed_photos,
            0,
        )

        progress = (
            (
                event.processed_photos + event.failed_photos
            )
            / event.total_photos
            * 100
            if event.total_photos
            else 100
        )

        return {
            "total": event.total_photos,
            "processed": event.processed_photos,
            "failed": event.failed_photos,
            "remaining": remaining,
            "progress": round(progress, 2),
            "completed": remaining == 0,
        }

    def set_cover_photo(
        self,
        current_user: User,
        event_id: int,
        photo_id: int,
    ):
        event = self.event_repo.get_by_id(event_id)

        if event is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Event not found.",
            )

        verify_event_owner(
            current_user,
            event,
        )

        photo = self.photo_repo.get_by_id(photo_id)

        if photo is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Photo not found.",
            )

        if photo.event_id != event.id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Photo does not belong to this event.",
            )

        event.cover_image = photo.image_url

        return self.event_repo.save(event)