"""Core orchestration for inventory updates."""
from __future__ import annotations

from collections import defaultdict
from datetime import datetime, timezone
from typing import Dict, Iterable, List, Optional

from ..clients.google_sheets import GoogleSheetsClient
from ..clients.google_vision import GoogleVisionClient
from ..models.inventory import InventoryItem, ProcessedImageResult


class InventoryService:
    """Coordinates Vision detections with Google Sheets inventory updates."""

    def __init__(
        self,
        sheets_client: GoogleSheetsClient,
        vision_client: Optional[GoogleVisionClient] = None,
        default_min_quantity: int = 1,
    ) -> None:
        self.sheets = sheets_client
        self.vision = vision_client or GoogleVisionClient()
        self.default_min_quantity = default_min_quantity

    def _build_alias_lookup(self, items: Iterable[InventoryItem]) -> Dict[str, InventoryItem]:
        lookup: Dict[str, InventoryItem] = {}
        for item in items:
            aliases = set(alias.lower() for alias in item.aliases)
            aliases.add(item.name.lower())
            if item.sku:
                aliases.add(item.sku.lower())
            for alias in aliases:
                lookup[alias] = item
        return lookup

    def process_image(self, image_url: str, allow_unknown: bool = True) -> ProcessedImageResult:
        detections = self.vision.detect_from_url(image_url)
        inventory_items = self.sheets.fetch_inventory()
        catalog_items = self.sheets.fetch_catalog()
        alias_lookup = self._build_alias_lookup(inventory_items)
        catalog_lookup = self._build_alias_lookup(catalog_items)

        detected_counts: Dict[str, int] = defaultdict(int)
        for detection in detections:
            detected_counts[detection.label] += detection.count

        processed = ProcessedImageResult(detected_items=list(detected_counts.keys()))
        timestamp = datetime.now(timezone.utc)

        updated_items: List[InventoryItem] = []

        for label, count in detected_counts.items():
            matched_item = alias_lookup.get(label.lower())
            if matched_item:
                matched_item.quantity = count
                matched_item.last_detected_at = timestamp
                updated_items.append(matched_item)
            elif allow_unknown:
                catalog_match = catalog_lookup.get(label.lower())
                if catalog_match:
                    new_item = InventoryItem(
                        name=catalog_match.name,
                        sku=catalog_match.sku,
                        aliases=catalog_match.aliases or [label],
                        quantity=count,
                        min_quantity=catalog_match.min_quantity or self.default_min_quantity,
                        location=catalog_match.location,
                        last_detected_at=timestamp,
                    )
                else:
                    new_item = InventoryItem(
                        name=label.title(),
                        sku=None,
                        aliases=[label],
                        quantity=count,
                        min_quantity=self.default_min_quantity,
                        location=None,
                        last_detected_at=timestamp,
                    )
                processed.upserted_items.append(new_item.name)
                updated_items.append(new_item)

        if updated_items:
            processed.updated_rows = self.sheets.update_inventory_items(updated_items)

        restock_needed: List[str] = []
        for item in updated_items:
            if item.quantity <= item.min_quantity:
                restock_needed.append(item.name)
        processed.restock_items = restock_needed

        return processed


__all__ = ["InventoryService"]
