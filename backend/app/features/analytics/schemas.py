from pydantic import BaseModel


class MonthlyEventStat(BaseModel):
    month: str
    count: int


class MonthlyPhotoStat(BaseModel):
    month: str
    photos: int


class EventTypeStat(BaseModel):
    event_type: str
    count: int


class ProcessingStat(BaseModel):
    processed: int
    processing: int
    failed: int


class StorageStat(BaseModel):
    month: str
    storage_mb: float