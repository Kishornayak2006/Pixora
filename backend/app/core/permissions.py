from fastapi import HTTPException, status

from app.features.auth.models import User
from app.features.event.models import Event


def verify_studio_owner(
    current_user: User,
):
    if current_user.studio is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not own a studio.",
        )

    return current_user.studio


def verify_event_owner(
    current_user: User,
    event: Event,
):
    studio = verify_studio_owner(current_user)

    if event.studio_id != studio.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not authorized to access this event.",
        )

    return event