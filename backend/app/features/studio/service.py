from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.features.studio.schemas import (
    StudioCreate,
    StudioUpdate,
)
from app.features.auth.models import User
from app.features.studio.models import Studio
from app.features.studio.repository import StudioRepository
from app.features.studio.schemas import (
    StudioCreate,
)


class StudioService:
    def __init__(self, db: Session):
        self.repo = StudioRepository(db)

    def create(
        self,
        studio_data: StudioCreate,
        current_user: User,
    ) -> Studio:

        existing = self.repo.get_by_owner_id(current_user.id)

        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Studio already exists for this user.",
            )

        studio = Studio(
            owner_id=current_user.id,
            studio_name=studio_data.studio_name,
            phone=studio_data.phone,
            email=studio_data.email,
            description=studio_data.description,
            address=studio_data.address,
            city=studio_data.city,
            state=studio_data.state,
            country=studio_data.country,
            logo_url=studio_data.logo_url,
        )

        return self.repo.create(studio)
    
    

    def get_my_studio(
        self,
        current_user: User,
    ) -> Studio:

        studio = self.repo.get_by_owner_id(current_user.id)

        if studio is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Studio not found.",
            )

        return studio
    
    def update(
        self,
        studio_data: StudioUpdate,
        current_user: User,
    ) -> Studio:

        studio = self.repo.get_by_owner_id(current_user.id)

        if studio is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Studio not found.",
            )

        update_data = studio_data.model_dump(exclude_unset=True)

        for field, value in update_data.items():
            setattr(studio, field, value)

        return self.repo.update(studio)
    
    def delete(
        self,
        current_user: User,
    ) -> None:

        studio = self.repo.get_by_owner_id(current_user.id)

        if studio is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Studio not found.",
            )

        self.repo.delete(studio)