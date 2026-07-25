from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import (
    create_access_token,
    hash_password,
    verify_password,
)
from app.features.auth.models import User
from app.features.auth.repository import AuthRepository
from app.features.auth.schemas import (
    Token,
    UserCreate,
)


class AuthService:
    def __init__(self, db: Session):
        self.repo = AuthRepository(db)

    def register(self, user_data: UserCreate) -> User:
        existing = self.repo.get_by_email(user_data.email)

        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email already registered",
            )

        user = User(
            full_name=user_data.full_name,
            email=user_data.email,
            hashed_password=hash_password(user_data.password),
        )

        return self.repo.create(user)

    def login(self, email: str, password: str) -> Token:
        user = self.repo.get_by_email(email)

        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        if not verify_password(password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        access_token = create_access_token(
            subject=str(user.id),
        )

        return Token(
            access_token=access_token,
            token_type="bearer",
        )