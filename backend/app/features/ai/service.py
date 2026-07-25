from app.features.ai.face_detector import FaceDetector
from app.features.ai.repository import AIRepository


class AIService:

    def __init__(self, repo: AIRepository):
        self.repo = repo
        self.detector = FaceDetector()

    def generate_embeddings(
        self,
        photo_id: int,
    ):
        photo = self.repo.get_photo(photo_id)

        if photo is None:
            return

        try:
            faces = self.detector.detect(
                photo.file_path
            )

            if not faces:
                self.repo.mark_failed(photo_id)
                return

            print(f"Photo {photo.id}: {len(faces)} face(s) detected.")

            print("Calling save_embeddings()...")

            self.repo.save_embeddings(
                photo.id,
                faces,
            )

            print("save_embeddings() finished.")

        except Exception as e:
            print(f"Embedding generation failed: {e}")

            self.repo.mark_failed(photo_id)