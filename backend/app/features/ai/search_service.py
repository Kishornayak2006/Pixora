from app.features.ai.face_detector import FaceDetector
from app.features.ai.repository import AIRepository
from app.features.ai.similarity import rank_matches


class SearchService:

    def __init__(self, repo: AIRepository):
        self.repo = repo
        self.detector = FaceDetector()

    def search(
        self,
        event_id: int,
        selfie_path: str,
    ):
        """
        Search photos in an event using a guest selfie.
        """

        # Detect face(s) in selfie
        faces = self.detector.detect(selfie_path)

        if not faces:
            return []

        # Use the first detected face
        query_embedding = faces[0].embedding.tolist()

        # Get all embeddings for this event
        candidates = self.repo.get_event_embeddings(event_id)

        # Rank by cosine similarity
        matches = rank_matches(
            query_embedding=query_embedding,
            candidates=candidates,
            threshold=0.60,
        )

        # Get matching photos
        photo_ids = [match["photo_id"] for match in matches]

        photos = self.repo.get_photos_by_ids(photo_ids)

        photo_map = {
            photo.id: photo
            for photo in photos
        }

        results = []

        for match in matches:

            photo = photo_map.get(match["photo_id"])

            if photo is None:
                continue

            results.append(
                {
                    "photo_id": photo.id,
                    "similarity": match["score"],
                    "confidence": self.confidence(match["score"]),
                    "image_url": "/" + photo.file_path.replace("\\", "/"),
                    "original_name": photo.original_name,
                }
            )

        # Return only the best 20 matches
        return results[:20]

    @staticmethod
    def confidence(score: float) -> str:
        """
        Convert similarity score into a confidence label.
        """

        if score >= 0.85:
            return "Very High"

        if score >= 0.75:
            return "High"

        if score >= 0.65:
            return "Medium"

        return "Low"