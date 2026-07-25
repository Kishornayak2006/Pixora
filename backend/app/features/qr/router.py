from fastapi import APIRouter
from fastapi.responses import Response

from app.features.qr.service import QRService

router = APIRouter(
    prefix="/qr",
    tags=["QR Code"],
)


@router.get("/{token}")
def generate_qr(token: str):
    url = f"http://127.0.0.1:8000/api/v1/gallery/{token}"

    image = QRService.generate_qr(url)

    return Response(
        content=image,
        media_type="image/png",
    )