from datetime import datetime
from app.features.photo.enums import ProcessingStatus
from pydantic import BaseModel, ConfigDict

from app.core.pagination import PaginationMeta


class PhotoResponse(BaseModel):
    id: int
    event_id: int
    original_name: str
    file_name: str
    image_url: str
    mime_type: str
    file_size: int
    processing_status: ProcessingStatus
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class BulkUploadResponse(BaseModel):
    uploaded: int
    duplicates: int
    duplicate_files: list[str]


class PhotoPaginationResponse(BaseModel):
    meta: PaginationMeta
    items: list[PhotoResponse]