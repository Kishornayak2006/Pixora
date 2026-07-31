import cloudinary
import cloudinary.uploader

from app.core.config import settings


cloudinary.config(
    cloud_name=settings.CLOUDINARY_CLOUD_NAME,
    api_key=settings.CLOUDINARY_API_KEY,
    api_secret=settings.CLOUDINARY_API_SECRET,
    secure=True,
)


def upload_image(file_path: str, folder: str = "pixora"):
    """
    Upload an image to Cloudinary.

    Returns:
        dict: Cloudinary upload response
    """
    return cloudinary.uploader.upload(
        file_path,
        folder=folder,
        resource_type="image",
    )


def delete_image(public_id: str):
    """
    Delete an image from Cloudinary.
    """
    return cloudinary.uploader.destroy(public_id)