"""Google Vision client wrapper."""
from __future__ import annotations

from typing import List

import requests
from google.cloud import vision

from ..models.inventory import VisionDetection


class GoogleVisionClient:
    """Wrapper around Google Cloud Vision object localization."""

    def __init__(self) -> None:
        self.client = vision.ImageAnnotatorClient()

    def detect_from_url(self, image_url: str, min_score: float = 0.5) -> List[VisionDetection]:
        response = requests.get(image_url, timeout=20)
        response.raise_for_status()
        content = response.content

        image = vision.Image(content=content)
        objects = self.client.object_localization(image=image).localized_object_annotations

        detections: dict[str, VisionDetection] = {}
        for obj in objects:
            if obj.score < min_score:
                continue
            label = obj.name.lower()
            if label in detections:
                detections[label].count += 1
                detections[label].score = max(detections[label].score, obj.score)
            else:
                detections[label] = VisionDetection(label=label, score=obj.score, count=1)

        return list(detections.values())


__all__ = ["GoogleVisionClient"]
