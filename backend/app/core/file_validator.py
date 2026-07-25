import os

from fastapi import HTTPException, UploadFile, status


from app.core.config import settings

ALLOWED_EXTENSIONS = {
    "." + ext.strip().lower()
    for ext in settings.ALLOWED_IMAGE_EXTENSIONS.split(",")
}

ALLOWED_MIME_TYPES = {
    mime.strip()
    for mime in settings.ALLOWED_IMAGE_MIME_TYPES.split(",")
}


def validate_image(file: UploadFile):
    extension = ""

    if file.filename:
        extension = "." + file.filename.split(".")[-1].lower()

    if extension not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported image format.",
        )

    if file.content_type not in ALLOWED_MIME_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid content type.",
        )

    # Calculate file size
    file.file.seek(0, os.SEEK_END)

    file_size = file.file.tell()
    file.file.seek(0)

    max_size = settings.MAX_IMAGE_SIZE_MB * 1024 * 1024

    if file_size > max_size:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"Image size exceeds {settings.MAX_IMAGE_SIZE_MB} MB limit.",
        )