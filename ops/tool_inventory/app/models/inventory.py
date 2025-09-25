"""Domain models for inventory processing."""
from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from typing import List, Optional


@dataclass
class InventoryItem:
    """Represents an inventory row from Google Sheets."""

    name: str
    sku: Optional[str]
    aliases: List[str]
    quantity: int
    min_quantity: int
    location: Optional[str] = None
    last_detected_at: Optional[datetime] = None

    @classmethod
    def from_row(cls, row: dict[str, str]) -> "InventoryItem":
        aliases = [alias.strip() for alias in (row.get("Aliases") or "").split("|") if alias.strip()]
        name = row.get("Name") or row.get("Item") or row.get("Product") or ""
        sku = row.get("SKU") or row.get("Sku") or None
        quantity = int(row.get("Quantity") or 0)
        min_quantity = int(row.get("Min Quantity") or row.get("MinQuantity") or 0)
        location = row.get("Location") or None
        last_detected = row.get("Last Detected At") or row.get("LastDetectedAt")
        timestamp = datetime.fromisoformat(last_detected) if last_detected else None
        return cls(
            name=name,
            sku=sku,
            aliases=aliases,
            quantity=quantity,
            min_quantity=min_quantity,
            location=location,
            last_detected_at=timestamp,
        )

    def to_row(self) -> dict[str, str]:
        """Convert the inventory item back to a Google Sheets row."""

        return {
            "Name": self.name,
            "SKU": self.sku or "",
            "Aliases": "|".join(self.aliases),
            "Quantity": str(self.quantity),
            "Min Quantity": str(self.min_quantity),
            "Location": self.location or "",
            "Last Detected At": self.last_detected_at.isoformat() if self.last_detected_at else "",
        }


@dataclass
class VisionDetection:
    """Represents an object detected in an image."""

    label: str
    score: float
    count: int = 1


@dataclass
class ProcessedImageResult:
    """Return payload for API consumers such as Zapier."""

    detected_items: List[str] = field(default_factory=list)
    upserted_items: List[str] = field(default_factory=list)
    restock_items: List[str] = field(default_factory=list)
    updated_rows: int = 0


__all__ = ["InventoryItem", "VisionDetection", "ProcessedImageResult"]
