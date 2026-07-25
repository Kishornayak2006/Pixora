from pydantic import BaseModel


class SearchResult(BaseModel):
    photo_id: int
    similarity: float
    confidence: str
    image_url: str
    original_name: str


class SearchResponse(BaseModel):
    matches: list[SearchResult]