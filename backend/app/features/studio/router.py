from fastapi import APIRouter, Depends, status
from app.features.studio.schemas import (
    StudioCreate,
    StudioResponse,
    StudioUpdate,
)
from app.features.auth.dependencies import get_current_user
from app.features.auth.models import User
from app.features.studio.dependencies import get_studio_service
from app.features.studio.schemas import (
    StudioCreate,
    StudioResponse,
)
from app.features.studio.service import StudioService

router = APIRouter(
    prefix="/studios",
    tags=["Studios"],
)


@router.post(
    "",
    response_model=StudioResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_studio(
    studio: StudioCreate,
    current_user: User = Depends(get_current_user),
    service: StudioService = Depends(get_studio_service),
):
    return service.create(
        studio,
        current_user,
    )


@router.get(
    "/me",
    response_model=StudioResponse,
)
def get_my_studio(
    current_user: User = Depends(get_current_user),
    service: StudioService = Depends(get_studio_service),
):
    return service.get_my_studio(current_user)

@router.put(
    "/me",
    response_model=StudioResponse,
)
def update_my_studio(
    studio: StudioUpdate,
    current_user: User = Depends(get_current_user),
    service: StudioService = Depends(get_studio_service),
):
    return service.update(
        studio,
        current_user,
    )

@router.delete(
    "/me",
    status_code=status.HTTP_204_NO_CONTENT,
)
def delete_my_studio(
    current_user: User = Depends(get_current_user),
    service: StudioService = Depends(get_studio_service),
):
    service.delete(current_user)