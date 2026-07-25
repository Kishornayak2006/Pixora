from pathlib import Path

import cv2
import onnxruntime as ort
from insightface.app import FaceAnalysis


class FaceDetector:
    def __init__(self):
        # Available ONNX Runtime providers
        self.available_providers = ort.get_available_providers()

        # Prefer GPU, fallback to CPU
        providers = []

        if "CUDAExecutionProvider" in self.available_providers:
            providers.append("CUDAExecutionProvider")

        providers.append("CPUExecutionProvider")

        self.app = FaceAnalysis(
            name="buffalo_l",
            providers=providers,
        )

        self.app.prepare(
            ctx_id=0 if "CUDAExecutionProvider" in providers else -1,
            det_size=(640, 640),
        )

        print("\n========== Face Detector ==========")
        print("ONNX Providers :", self.available_providers)
        print("Using Providers:", providers)

        print("\nInsightFace Models")
        for name, model in self.app.models.items():
            print(
                f"{name:<15} -> "
                f"{model.session.get_providers()}"
            )

        print("===================================\n")

    def detect(self, image_path: str | Path):
        """
        Detect all faces in an image.

        Returns:
            List[Face]
        """

        image_path = Path(image_path)

        if not image_path.exists():
            raise FileNotFoundError(
                f"Image not found: {image_path}"
            )

        image = cv2.imread(str(image_path))

        if image is None:
            raise ValueError(
                "Unable to read image."
            )

        faces = self.app.get(image)

        return faces