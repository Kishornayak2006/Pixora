from app.features.ai.repository import AIRepository
from app.features.ai.search_service import SearchService
from app.features.guest_gallery.repository import GuestGalleryRepository


class GuestGalleryService:

    def __init__(
        self,
        gallery_repo: GuestGalleryRepository,
        ai_repo: AIRepository,
    ):
        self.gallery_repo = gallery_repo
        self.search_service = SearchService(ai_repo)

    def create_gallery(
        self,
        event_id: int,
        selfie_path: str,
    ):
        """
        Run AI search and create a guest gallery.
        """

        matches = self.search_service.search(
            event_id=event_id,
            selfie_path=selfie_path,
        )

        gallery = self.gallery_repo.create_gallery(
            event_id=event_id,
        )

        for match in matches:

            self.gallery_repo.add_photo(
                gallery_id=gallery.id,
                photo_id=match["photo_id"],
                similarity=match["similarity"],
            )

        return {
            "gallery_token": gallery.gallery_token,
            "total_matches": len(matches),
        }

    def get_gallery(
        self,
        gallery_token: str,
    ):
        """
        Fetch a previously created guest gallery.
        """

        gallery = self.gallery_repo.get_gallery(
            gallery_token,
        )

        if gallery is None:
            return None

        photos = []

        for item in gallery.photos:

            photos.append(
                {
                    "photo_id": item.photo.id,
                    "similarity": item.similarity,
                    "image_url": "/" + item.photo.file_path.replace("\\", "/"),
                    "original_name": item.photo.original_name,
                }
            )

        return {
            "gallery_token": gallery.gallery_token,
            "event_id": gallery.event_id,
            "created_at": gallery.created_at,
            "total_photos": len(photos),
            "photos": photos,
        }