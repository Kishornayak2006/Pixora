from datetime import UTC, datetime
from enum import Enum
import secrets

from sqlalchemy import (
    Date,
    DateTime,
    Enum as SQLEnum,
    ForeignKey,
    Integer,
    String,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base



class EventType(str, Enum):
    WEDDING = "WEDDING"
    RECEPTION = "RECEPTION"
    BIRTHDAY = "BIRTHDAY"
    CORPORATE = "CORPORATE"
    COLLEGE = "COLLEGE"
    OTHER = "OTHER"


class EventStatus(str, Enum):
    UPCOMING = "UPCOMING"
    ONGOING = "ONGOING"
    COMPLETED = "COMPLETED"


class Event(Base):
    __tablename__ = "events"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    studio_id: Mapped[int] = mapped_column(
        ForeignKey("studios.id"),
        nullable=False,
    )

    event_name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    event_type: Mapped[EventType] = mapped_column(
        SQLEnum(EventType),
        default=EventType.OTHER,
        nullable=False,
    )

    client_name: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    client_phone: Mapped[str] = mapped_column(
        String(20),
        nullable=False,
    )

    client_email: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )

    event_date: Mapped[datetime] = mapped_column(
        Date,
        nullable=False,
    )

    location: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )

    cover_image: Mapped[str | None] = mapped_column(
        String(500),
        nullable=True,
    )

    status: Mapped[EventStatus] = mapped_column(
        SQLEnum(EventStatus),
        default=EventStatus.UPCOMING,
        nullable=False,
    )

    gallery_token: Mapped[str] = mapped_column(
        String(32),
        unique=True,
        nullable=False,
        default=lambda: secrets.token_urlsafe(16),
    )

    total_photos: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
    )

    processed_photos: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
    )

    failed_photos: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(UTC),
    )

    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(UTC),
        onupdate=lambda: datetime.now(UTC),
    )

    studio = relationship(
        "Studio",
        back_populates="events",
    )

    photos = relationship(
        "Photo",
        back_populates="event",
        cascade="all, delete-orphan",
    )

    guests = relationship(
        "Guest",
        back_populates="event",
        cascade="all, delete-orphan",
    )