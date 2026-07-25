from fastapi import Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.features.guest.repository import GuestRepository
from app.features.guest.service import GuestService


def get_guest_service(
    db: Session = Depends(get_db),
):

    repo = GuestRepository(db)

    return GuestService(repo)