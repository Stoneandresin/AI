"""Google Sheets client helper."""
from __future__ import annotations

from datetime import datetime
from typing import Iterable, List, Optional

import gspread

from ..models.inventory import InventoryItem


class GoogleSheetsClient:
    """Wrapper around gspread to manage inventory sheets."""

    def __init__(
        self,
        credentials_path: str,
        sheet_id: str,
        inventory_tab: str = "Inventory",
        catalog_tab: Optional[str] = None,
    ) -> None:
        self.gc = gspread.service_account(filename=credentials_path)
        self.sheet = self.gc.open_by_key(sheet_id)
        self.inventory_sheet = self.sheet.worksheet(inventory_tab)
        self.catalog_sheet = self.sheet.worksheet(catalog_tab) if catalog_tab else None

    def fetch_inventory(self) -> List[InventoryItem]:
        rows = self.inventory_sheet.get_all_records()
        return [InventoryItem.from_row(row) for row in rows if any(row.values())]

    def fetch_catalog(self) -> List[InventoryItem]:
        if not self.catalog_sheet:
            return []
        rows = self.catalog_sheet.get_all_records()
        items: List[InventoryItem] = []
        for row in rows:
            if not any(row.values()):
                continue
            item = InventoryItem(
                name=row.get("Name") or row.get("Item") or "",
                sku=row.get("SKU") or row.get("Sku") or None,
                aliases=[alias.strip() for alias in (row.get("Aliases") or "").split("|") if alias.strip()],
                quantity=int(row.get("Quantity") or 0),
                min_quantity=int(row.get("Min Quantity") or row.get("MinQuantity") or 0),
                location=row.get("Location") or None,
            )
            items.append(item)
        return items

    def _row_index_by_name(self, name: str) -> Optional[int]:
        values = self.inventory_sheet.get_all_values()
        if not values:
            return None
        header = values[0]
        name_idx = header.index("Name") if "Name" in header else None
        if name_idx is None:
            return None
        for idx, row in enumerate(values[1:], start=2):
            if len(row) > name_idx and row[name_idx].strip().lower() == name.strip().lower():
                return idx
        return None

    def upsert_inventory_item(self, item: InventoryItem) -> None:
        row_index = self._row_index_by_name(item.name)
        if row_index:
            self.inventory_sheet.update(f"A{row_index}:G{row_index}", [list(item.to_row().values())])
        else:
            self.inventory_sheet.append_row(list(item.to_row().values()))

    def update_inventory_items(self, items: Iterable[InventoryItem]) -> int:
        updated = 0
        for item in items:
            self.upsert_inventory_item(item)
            updated += 1
        return updated

    def record_detection_timestamp(self, item: InventoryItem, timestamp: datetime) -> None:
        item.last_detected_at = timestamp
        self.upsert_inventory_item(item)


__all__ = ["GoogleSheetsClient"]
