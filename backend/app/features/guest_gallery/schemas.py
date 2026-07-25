from datetime import datetime

from pydantic import BaseModel


class GalleryPhoto(BaseModel):
    photo_id: int
    similarity: float
    image_url: str
    original_name: str


class CreateGalleryResponse(BaseModel):
    gallery_token: str
    total_matches: int


class GalleryResponse(BaseModel):
    gallery_token: str
    event_id: int
    created_at: datetime
    total_photos: int
    photos: list[GalleryPhoto]