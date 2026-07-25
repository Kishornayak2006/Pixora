from sqlalchemy import select
from sqlalchemy.orm import Session

from app.features.auth.models import User


class AuthRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_email(self, email: str) -> User | None:
        stmt = select(User).where(User.email == email)
        return self.db.execute(stmt).scalar_one_or_none()

    def create(self, user: User) -> User:
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user
    
    def get_by_id(self, user_id: int):
        stmt = select(User).where(User.id == user_id)
        return self.db.execute(stmt).scalar_one_or_none()