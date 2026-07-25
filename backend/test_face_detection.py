import cv2

from app.features.ai.face_detector import FaceDetector

IMAGE_PATH = "uploads/photos/Kishor Passport.jpeg"

image = cv2.imread(IMAGE_PATH)

if image is None:
    raise FileNotFoundError(f"Could not read image: {IMAGE_PATH}")

detector = FaceDetector()

faces = detector.detect(image)

print(f"Faces detected: {len(faces)}")

for i, face in enumerate(faces, start=1):
    print(f"\nFace {i}")
    print("Bounding Box:", face.bbox)
    print("Confidence:", face.det_score)