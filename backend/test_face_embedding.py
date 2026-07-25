import cv2

from app.features.ai.face_detector import FaceDetector
from app.features.ai.face_matcher import FaceMatcher

IMAGE_PATH = "uploads/photos/93aeb2b7-7b88-4766-9e66-91982dff2ba9.jpeg"

image = cv2.imread(IMAGE_PATH)

if image is None:
    raise FileNotFoundError(IMAGE_PATH)

detector = FaceDetector()

faces = detector.detect(image)

print(f"Faces detected: {len(faces)}")

if len(faces) == 0:
    raise Exception("No face detected")

face = faces[0]

embedding = face.normed_embedding

print("Embedding shape:", embedding.shape)
print("Embedding dtype:", embedding.dtype)

embedding_bytes = FaceMatcher.embedding_to_bytes(embedding)

print("Bytes length:", len(embedding_bytes))

restored = FaceMatcher.bytes_to_embedding(embedding_bytes)

print("Restored shape:", restored.shape)

print("Embeddings equal:", (embedding == restored).all())