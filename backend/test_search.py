import app.db.base_class


from app.db.session import SessionLocal
from app.features.ai.service import AIService

db = SessionLocal()

service = AIService(db)

results = service.search(
    "uploads/photos/Kishor.jpeg"
)

print(results)