from datetime import datetime
import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parents[1]))

from app.models.inventory import InventoryItem, ProcessedImageResult, VisionDetection
from app.services.inventory_service import InventoryService


class DummySheetsClient:
    def __init__(self, items, catalog=None):
        self._items = items
        self._catalog = catalog or []
        self.upserted = []

    def fetch_inventory(self):
        return list(self._items)

    def fetch_catalog(self):
        return list(self._catalog)

    def update_inventory_items(self, items):
        self.upserted.extend(items)
        return len(items)


class DummyVisionClient:
    def __init__(self, detections):
        self._detections = detections

    def detect_from_url(self, image_url, min_score=0.5):
        return self._detections


def test_process_image_matches_aliases():
    inventory = [
        InventoryItem(
            name="Impact Driver",
            sku="123",
            aliases=["driver", "drill"],
            quantity=5,
            min_quantity=2,
        )
    ]

    sheets = DummySheetsClient(inventory)
    detections = [VisionDetection(label="drill", score=0.9, count=2)]
    service = InventoryService(sheets_client=sheets, vision_client=DummyVisionClient(detections))

    result = service.process_image("http://example.com/photo.jpg")

    assert isinstance(result, ProcessedImageResult)
    assert result.detected_items == ["drill"]
    assert result.updated_rows == 1
    assert result.restock_items == ["Impact Driver"]
    assert sheets.upserted[0].quantity == 2


def test_process_image_flags_restock():
    inventory = [
        InventoryItem(
            name="Safety Gloves",
            sku="glove-001",
            aliases=["glove", "gloves"],
            quantity=5,
            min_quantity=3,
        )
    ]

    sheets = DummySheetsClient(inventory)
    detections = [VisionDetection(label="glove", score=0.8, count=2)]
    service = InventoryService(sheets_client=sheets, vision_client=DummyVisionClient(detections))

    result = service.process_image("http://example.com/photo.jpg")

    assert "Safety Gloves" in result.restock_items

def test_process_image_uses_catalog_for_unknown_label():
    inventory = []
    catalog = [
        InventoryItem(
            name="Hex Key Set",
            sku="hex-007",
            aliases=["allen key", "hex key"],
            quantity=0,
            min_quantity=4,
            location="Tool Wall",
        )
    ]

    sheets = DummySheetsClient(inventory, catalog=catalog)
    detections = [VisionDetection(label="allen key", score=0.92, count=3)]
    service = InventoryService(sheets_client=sheets, vision_client=DummyVisionClient(detections))

    result = service.process_image("http://example.com/photo.jpg")

    assert result.upserted_items == ["Hex Key Set"]
    assert sheets.upserted[0].min_quantity == 4
