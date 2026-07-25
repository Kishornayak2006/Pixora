from sqlalchemy.orm import Session, joinedload

from app.features.guest_gallery.models import (
    GuestGallery,
    GuestGalleryPhoto,
)


class GuestGalleryRepository:

    def __init__(self, db: Session):
        self.db = db

    def create_gallery(
        self,
        event_id: int,
    ) -> GuestGallery:

        gallery = GuestGallery(
            event_id=event_id,
        )

        self.db.add(gallery)
        self.db.commit()
        self.db.refresh(gallery)

        return gallery

    def add_photo(
        self,
        gallery_id: int,
        photo_id: int,
        similarity: float,
    ) -> GuestGalleryPhoto:

        gallery_photo = GuestGalleryPhoto(
            gallery_id=gallery_id,
            photo_id=photo_id,
            similarity=similarity,
        )

        self.db.add(gallery_photo)
        self.db.commit()

        return gallery_photo

    def get_gallery(
        self,
        gallery_token: str,
    ) -> GuestGallery | None:

        return (
            self.db.query(GuestGallery)
            .options(
                joinedload(GuestGallery.photos)
                .joinedload(GuestGalleryPhoto.photo)
            )
            .filter(
                GuestGallery.gallery_token == gallery_token
            )
            .first()
        )