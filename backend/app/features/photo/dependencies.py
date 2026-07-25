from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.features.photo.repository import PhotoRepository
from app.features.photo.service import PhotoService


def get_photo_service(
    db: Session = Depends(get_db),
) -> PhotoService:
    return PhotoService(
        PhotoRepository(db),
    )