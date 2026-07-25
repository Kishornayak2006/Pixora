from datetime import datetime

from pydantic import BaseModel


class QueueStatusResponse(BaseModel):
    status: str

    total_photos: int
    processed_photos: int
    failed_photos: int
    remaining_photos: int

    progress: float

    eta_seconds: int

    estimated_completion: datetime | None