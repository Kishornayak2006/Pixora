from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.features.studio.service import StudioService


def get_studio_service(
    db: Session = Depends(get_db),
):
    return StudioService(db)