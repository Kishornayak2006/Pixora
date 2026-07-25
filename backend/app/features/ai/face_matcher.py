import numpy as np


class FaceMatcher:

    @staticmethod
    def bytes_to_embedding(data: bytes):
        # Make a writable copy
        return np.frombuffer(data, dtype=np.float32).copy()

    @staticmethod
    def cosine_similarity(embedding1, embedding2):
        embedding1 = np.asarray(embedding1, dtype=np.float32).copy()
        embedding2 = np.asarray(embedding2, dtype=np.float32).copy()

        norm1 = np.linalg.norm(embedding1)
        norm2 = np.linalg.norm(embedding2)

        if norm1 == 0 or norm2 == 0:
            return 0.0

        embedding1 = embedding1 / norm1
        embedding2 = embedding2 / norm2

        return float(np.dot(embedding1, embedding2))