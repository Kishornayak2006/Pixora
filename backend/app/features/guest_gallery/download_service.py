from pathlib import Path
import zipfile
import tempfile

from app.features.guest_gallery.models import GuestGallery


class GuestGalleryDownloadService:

    def create_zip(
        self,
        gallery: GuestGallery,
    ) -> str:

        temp_dir = tempfile.mkdtemp()

        zip_path = Path(temp_dir) / f"{gallery.gallery_token}.zip"

        with zipfile.ZipFile(
            zip_path,
            "w",
            zipfile.ZIP_DEFLATED,
        ) as zip_file:

            for gallery_photo in gallery.photos:

                photo = gallery_photo.photo

                file_path = Path(photo.file_path)

                if file_path.exists():

                    zip_file.write(
                        file_path,
                        arcname=photo.original_name,
                    )

        return str(zip_path)