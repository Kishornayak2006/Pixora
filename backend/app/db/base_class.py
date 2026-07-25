from app.db.base import Base

# Import every model here for Alembic autogenerate
from app.features.auth.models import User
from app.features.studio.models import Studio
from app.features.event.models import Event
from app.features.photo.models import Photo
from app.db.models.face_embedding import FaceEmbedding
from app.features.guest.models import Guest
from app.features.guest_gallery.models import GuestGallery, GuestGalleryPhoto