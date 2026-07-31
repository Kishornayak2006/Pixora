from datetime import UTC, datetime

from sqlalchemy import DateTime, Enum, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.core.config import settings
from app.features.photo.enums import ProcessingStatus


class Photo(Base):
    __tablename__ = "photos"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True,
    )

    event_id: Mapped[int] = mapped_column(
        ForeignKey("events.id"),
        nullable=False,
    )

    original_name: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
    )

    file_name: Mapped[str] = mapped_column(
        String(255),
        nullable=False,
        unique=True,
    )

    # Legacy local storage path
    file_path: Mapped[str] = mapped_column(
        String(500),
        nullable=False,
    )

    # AWS S3 object key
    storage_key: Mapped[str | None] = mapped_column(
        String(500),
        nullable=True,
    )

    mime_type: Mapped[str] = mapped_column(
        String(100),
        nullable=False,
    )

    file_size: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    file_hash: Mapped[str] = mapped_column(
        String(64),
        nullable=False,
        index=True,
    )

    processing_status: Mapped[ProcessingStatus] = mapped_column(
        Enum(
            ProcessingStatus,
            name="processingstatus",
        ),
        nullable=False,
        default=ProcessingStatus.PENDING,
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(UTC),
    )

    event = relationship(
        "Event",
        back_populates="photos",
    )

    face_embeddings = relationship(
        "FaceEmbedding",
        back_populates="photo",
        cascade="all, delete-orphan",
    )

    @property
    def image_url(self) -> str:
        """
        Returns either:
        - A temporary presigned S3 URL
        - Legacy local URL
        """

        if self.storage_key:
            from app.services.s3_service import S3Service

            return S3Service().generate_presigned_url(
                self.storage_key,
            )

        return (
            f"http://127.0.0.1:8000/uploads/photos/"
            f"{self.file_name}"
        )