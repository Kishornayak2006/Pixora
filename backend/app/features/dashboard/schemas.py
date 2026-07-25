from pydantic import BaseModel


class DashboardResponse(BaseModel):
    total_events: int
    today_events: int

    total_photos: int
    processed_photos: int
    processing_photos: int
    failed_photos: int

    storage_used_mb: float