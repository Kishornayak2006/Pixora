import os

from app.features.ai.face_detector import FaceDetector
from app.features.ai.repository import AIRepository
from app.services.s3_service import S3Service


class AIService:

    def __init__(self, repo: AIRepository):
        self.repo = repo
        self.detector = FaceDetector()
        self.s3 = S3Service()

    def generate_embeddings(
        self,
        photo_id: int,
    ):
        photo = self.repo.get_photo(photo_id)

        if photo is None:
            return

        temp_file = None

        try:
            # Decide whether to use S3 or legacy local storage
            if photo.storage_key:
                temp_file = self.s3.download_to_temp(
                    photo.storage_key,
                )
                image_path = temp_file
            else:
                image_path = photo.file_path

            faces = self.detector.detect(
                image_path,
            )

            if not faces:
                self.repo.mark_failed(photo_id)
                return

            print(
                f"Photo {photo.id}: {len(faces)} face(s) detected."
            )

            print("Calling save_embeddings()...")

            self.repo.save_embeddings(
                photo.id,
                faces,
            )

            print("save_embeddings() finished.")

        except Exception as e:
            print(f"Embedding generation failed: {e}")

            self.repo.mark_failed(photo_id)

        finally:
            if temp_file and os.path.exists(temp_file):
                try:
                    os.remove(temp_file)
                except Exception:
                    pass