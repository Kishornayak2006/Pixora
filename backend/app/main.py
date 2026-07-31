from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from pathlib import Path
from app.api.v1.router import api_router
from app.features.ai.router import router as ai_router
from app.core.config import settings
from app.core.exception_handlers import register_exception_handlers
from app.features.guest.router import router as guest_router
from app.features.gallery.router import router as gallery_router
from app.features.ai.router import router as ai_router
from fastapi.staticfiles import StaticFiles
from app.core.error_handlers import register_exception_handlers
from app.core.logging_middleware import LoggingMiddleware
from app.core.rate_limiter import limiter
from slowapi.errors import RateLimitExceeded
from slowapi import _rate_limit_exceeded_handler
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
)



app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://127.0.0.1",
        "http://localhost:3000",
    ],
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

register_exception_handlers(app)

UPLOAD_DIR = Path(settings.PHOTO_UPLOAD_DIR).parent

app.mount(
    "/uploads",
    StaticFiles(directory="uploads"),
    name="uploads",
)

app.include_router(
    api_router,
    prefix=settings.API_V1_PREFIX,
)

app.include_router(ai_router)


@app.get("/")
def root():
    return {"message": "Welcome to Pixora API 🚀"}

app.include_router(guest_router)

app.include_router(gallery_router)
app.include_router(ai_router)




app.state.limiter = limiter
app.add_exception_handler(
    RateLimitExceeded,
    _rate_limit_exceeded_handler,
)

from app.features.health.router import router as health_router

app.include_router(health_router)

@app.get("/cors-test")
def cors_test():
    return {"message": "CORS OK"}