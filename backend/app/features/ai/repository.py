from sqlalchemy.orm import Session

from app.db.models.face_embedding import FaceEmbedding
from app.features.photo.models import Photo
from app.features.photo.enums import ProcessingStatus


class AIRepository:

    def __init__(self, db: Session):
        self.db = db

    # ---------- Existing ----------

    def get_photo(self, photo_id: int):
        return (
            self.db.query(Photo)
            .filter(Photo.id == photo_id)
            .first()
        )

    def save_embeddings(
        self,
        photo_id: int,
        faces,
    ):
        """
        Save all detected face embeddings for a photo.
        Existing embeddings are deleted to avoid duplicates.
        """

        # Remove old embeddings if photo is reprocessed
        (
            self.db.query(FaceEmbedding)
            .filter(FaceEmbedding.photo_id == photo_id)
            .delete()
        )

        photo = self.get_photo(photo_id)

        if photo is None:
            return

        for idx, face in enumerate(faces):

            x1, y1, x2, y2 = map(int, face.bbox)

            self.db.add(
                FaceEmbedding(
                    photo_id=photo_id,
                    face_index=idx,
                    embedding=face.embedding.tolist(),
                    x=x1,
                    y=y1,
                    width=x2 - x1,
                    height=y2 - y1,
                )
            )

        photo.processing_status = ProcessingStatus.COMPLETED

        print("Status before commit:", photo.processing_status)

        self.db.commit()

        self.db.refresh(photo)

        print("Status after commit:", photo.processing_status)

    def mark_failed(
        self,
        photo_id: int,
    ):
        """
        Mark photo as FAILED if AI processing crashes.
        """

        photo = self.get_photo(photo_id)

        if photo is None:
            return

        photo.processing_status = ProcessingStatus.FAILED

        self.db.commit()

    # ---------- Search ----------

    def get_event_embeddings(
        self,
        event_id: int,
    ):
        """
        Returns:
        [
            (photo_id, embedding),
            ...
        ]
        """

        rows = (
            self.db.query(
                FaceEmbedding.photo_id,
                FaceEmbedding.embedding,
            )
            .join(Photo)
            .filter(Photo.event_id == event_id)
            .all()
        )

        return rows

    def get_photos_by_ids(
        self,
        photo_ids: list[int],
    ):
        """
        Returns Photo objects for matched IDs.
        """

        if not photo_ids:
            return []

        return (
            self.db.query(Photo)
            .filter(Photo.id.in_(photo_ids))
            .all()
        )