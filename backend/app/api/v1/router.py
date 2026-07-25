from fastapi import APIRouter
from app.features.qr.router import router as qr_router
from app.features.auth.router import router as auth_router
from app.features.studio.router import router as studio_router
from app.features.event.router import router as event_router
from app.features.photo.router import router as photo_router
from app.features.gallery.router import router as gallery_router
from app.features.dashboard.router import router as dashboard_router
from app.features.analytics.router import router as analytics_router
from app.features.queue.router import router as queue_router


api_router = APIRouter()

api_router.include_router(auth_router)
api_router.include_router(studio_router)
api_router.include_router(event_router)
api_router.include_router(photo_router)
api_router.include_router(gallery_router)
api_router.include_router(qr_router)
api_router.include_router(dashboard_router)
api_router.include_router(analytics_router)
api_router.include_router(queue_router)
