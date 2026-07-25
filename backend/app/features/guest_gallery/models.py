from datetime import UTC, datetime
from uuid import uuid4

from sqlalchemy import DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class GuestGallery(Base):
    __tablename__ = "guest_galleries"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    gallery_token: Mapped[str] = mapped_column(
        String(36),
        unique=True,
        nullable=False,
        default=lambda: str(uuid4()),
        index=True,
    )

    event_id: Mapped[int] = mapped_column(
        ForeignKey("events.id"),
        nullable=False,
        index=True,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(UTC),
    )

    photos = relationship(
        "GuestGalleryPhoto",
        back_populates="gallery",
        cascade="all, delete-orphan",
    )


class GuestGalleryPhoto(Base):
    __tablename__ = "guest_gallery_photos"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
    )

    gallery_id: Mapped[int] = mapped_column(
        ForeignKey("guest_galleries.id"),
        nullable=False,
        index=True,
    )

    photo_id: Mapped[int] = mapped_column(
        ForeignKey("photos.id"),
        nullable=False,
        index=True,
    )

    similarity: Mapped[float] = mapped_column(
        Float,
        nullable=False,
    )

    gallery = relationship(
        "GuestGallery",
        back_populates="photos",
    )

    photo = relationship(
        "Photo",
    )