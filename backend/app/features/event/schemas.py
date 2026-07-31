from datetime import date
from enum import Enum

from pydantic import BaseModel, ConfigDict, EmailStr


class EventType(str, Enum):
    WEDDING = "WEDDING"
    RECEPTION = "RECEPTION"
    BIRTHDAY = "BIRTHDAY"
    CORPORATE = "CORPORATE"
    COLLEGE = "COLLEGE"
    OTHER = "OTHER"


class EventStatus(str, Enum):
    UPCOMING = "UPCOMING"
    ONGOING = "ONGOING"
    COMPLETED = "COMPLETED"


class EventCreate(BaseModel):
    event_name: str
    event_type: EventType = EventType.OTHER

    client_name: str
    client_phone: str
    client_email: EmailStr

    event_date: date
    location: str

    cover_image: str | None = None


class EventResponse(BaseModel):
    id: int
    studio_id: int

    gallery_token: str   # <-- ADD THIS

    event_name: str
    event_type: EventType

    client_name: str
    client_phone: str
    client_email: EmailStr

    event_date: date
    location: str

    cover_image: str | None
    status: EventStatus

    gallery_token: str

    model_config = ConfigDict(from_attributes=True)

class SetCoverPhotoRequest(BaseModel):
    photo_id: int