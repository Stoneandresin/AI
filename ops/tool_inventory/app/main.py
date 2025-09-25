"""FastAPI application entrypoint."""
from __future__ import annotations

from fastapi import Depends, FastAPI, Header, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from .config import Settings, get_settings
from .clients.google_sheets import GoogleSheetsClient
from .services.inventory_service import InventoryService

app = FastAPI(title="Vision Inventory Automation", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ProcessImageRequest(BaseModel):
    image_url: str
    allow_unknown: bool | None = None


class ProcessImageResponse(BaseModel):
    detected_items: list[str]
    upserted_items: list[str]
    restock_items: list[str]
    updated_rows: int


async def get_inventory_service(settings: Settings = Depends(get_settings)) -> InventoryService:
    sheets = GoogleSheetsClient(
        credentials_path=settings.google_service_account_json,
        sheet_id=settings.google_sheets_inventory_sheet_id,
        inventory_tab=settings.google_sheets_inventory_tab,
        catalog_tab=settings.google_sheets_catalog_tab,
    )
    return InventoryService(
        sheets_client=sheets,
        default_min_quantity=settings.default_min_quantity,
    )


@app.post("/ingest", response_model=ProcessImageResponse)
async def ingest_image(
    payload: ProcessImageRequest,
    service: InventoryService = Depends(get_inventory_service),
    zapier_hook_secret: str | None = Header(default=None, alias="x-zapier-secret"),
    settings: Settings = Depends(get_settings),
) -> ProcessImageResponse:
    if settings.zapier_webhook_secret and zapier_hook_secret != settings.zapier_webhook_secret:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid Zapier secret")

    allow_unknown = (
        payload.allow_unknown if payload.allow_unknown is not None else settings.allow_unknown_labels
    )
    result = service.process_image(payload.image_url, allow_unknown=allow_unknown)
    return ProcessImageResponse(**result.__dict__)


@app.get("/healthz")
async def healthcheck() -> dict[str, str]:
    return {"status": "ok"}


__all__ = ["app"]
