from pydantic import BaseModel


class GuestRegisterResponse(BaseModel):
    guest_id: int
    matched_photos: list[int]
    total_matches: int