from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Application
    APP_NAME: str = "Pixora API"
    APP_VERSION: str = "1.0.0"
    API_V1_PREFIX: str = "/api/v1"

    # Database
    DATABASE_URL: str
    TEST_DATABASE_URL: str

    # JWT
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # AI
    SIMILARITY_THRESHOLD: float = 0.65

    # Uploads
    UPLOAD_DIR: str = "uploads"
    PHOTO_UPLOAD_DIR: str = "uploads/photos"
    TEMP_UPLOAD_DIR: str = "uploads/temp"

    MAX_IMAGE_SIZE_MB: int = 20

    ALLOWED_IMAGE_EXTENSIONS: str = "jpg,jpeg,png,webp"

    ALLOWED_IMAGE_MIME_TYPES: str = (
        "image/jpeg,image/png,image/webp"
    )

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # Cloudinary
    # AWS S3
    AWS_ACCESS_KEY_ID: str
    AWS_SECRET_ACCESS_KEY: str
    AWS_REGION: str
    AWS_S3_BUCKET: str

    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=True,
        extra="ignore",
    )


settings = Settings()