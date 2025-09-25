"""Application configuration management."""
from __future__ import annotations

import os
from functools import lru_cache
from typing import List, Optional

from pydantic import BaseSettings, Field, validator


class Settings(BaseSettings):
    """Runtime configuration loaded from environment variables."""

    google_service_account_json: str = Field(
        ..., env="GOOGLE_SERVICE_ACCOUNT_JSON", description="Path to Google service account JSON file"
    )
    google_sheets_inventory_sheet_id: str = Field(
        ..., env="GOOGLE_SHEETS_INVENTORY_SHEET_ID", description="Google Sheet ID containing the inventory tab"
    )
    google_sheets_inventory_tab: str = Field(
        "Inventory", env="GOOGLE_SHEETS_INVENTORY_TAB", description="Tab name for the inventory list"
    )
    google_sheets_catalog_tab: str = Field(
        "Catalog", env="GOOGLE_SHEETS_CATALOG_TAB", description="Tab name containing canonical catalog definitions"
    )
    google_application_credentials: Optional[str] = Field(
        default=None,
        env="GOOGLE_APPLICATION_CREDENTIALS",
        description="Optional path for Vision API credentials; defaults to service account json path",
    )
    zapier_webhook_secret: Optional[str] = Field(
        default=None,
        env="ZAPIER_WEBHOOK_SECRET",
        description="Optional shared secret for authenticating incoming Zapier requests",
    )
    default_min_quantity: int = Field(1, env="DEFAULT_MIN_QUANTITY", description="Fallback minimum quantity when upserting")
    restock_quantity: int = Field(
        10, env="RESTOCK_QUANTITY", description="Quantity to set when auto-inserting unknown items"
    )
    allow_unknown_labels: bool = Field(
        True,
        env="ALLOW_UNKNOWN_LABELS",
        description="Whether to insert new rows for labels not found in the catalog",
    )
    server_host: str = Field("0.0.0.0", env="SERVER_HOST")
    server_port: int = Field(8000, env="SERVER_PORT")

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

    @validator("google_application_credentials", pre=True, always=True)
    def default_credentials(cls, value: Optional[str], values: dict[str, str]) -> str:
        if value:
            return value
        return values.get("google_service_account_json", "")


@lru_cache()
def get_settings() -> Settings:
    """Return cached settings instance."""

    settings = Settings()
    if settings.google_application_credentials:
        os.environ.setdefault("GOOGLE_APPLICATION_CREDENTIALS", settings.google_application_credentials)
    return settings


__all__ = ["get_settings", "Settings"]
