# Vision-Powered Inventory Automation

This package delivers a code-first workflow that connects Google Vision, Google Sheets, and Zapier to maintain an always-on inventory ledger from photos of your shelves or tool crib. Drop a new image into your Zapier automation and the system will identify the tools/materials, upsert them into Sheets, and trigger restock alerts.

## Architecture

```
Zapier (New photo trigger)
        ↓ Webhook POST /ingest
FastAPI service (Render or local Docker)
        ↓
Google Vision AI — object localization
        ↓
Inventory logic — alias matching, restock thresholding
        ↓
Google Sheets — canonical catalog & stock ledger
        ↓
Zapier — downstream actions (Slack/Email/Tasks)
```

* **`/ingest` API** – Accepts an image URL from Zapier and returns detected items, upserted rows, and items needing restock.
* **Google Vision AI** – Performs object localization to count occurrences of known tools/materials.
* **Google Sheets** – Stores your catalog in the `Catalog` tab and live stock levels in the `Inventory` tab (columns described below).
* **Zapier** – Orchestrates the workflow end-to-end. Use the webhook trigger to hit `/ingest`, then branch on `restock_items` to fan out alerts.

## Google Sheets Setup

1. Create a Google Sheet with two tabs: `Inventory` and `Catalog` (names configurable via env vars).
2. Configure headers:
   - **Inventory:** `Name | SKU | Aliases | Quantity | Min Quantity | Location | Last Detected At`
   - **Catalog:** `Name | Aliases | SKU | Min Quantity | Location`
3. Populate catalog rows with canonical names and alias keywords (pipe-delimited). The service will match Vision labels against aliases.
4. Share the sheet with the service account email (from the credentials JSON) with edit permissions.

## Google Cloud Setup

1. Create a Google Cloud project with the **Vision API** and **Google Sheets API** enabled.
2. Create a Service Account with access to both APIs and download the JSON key.
3. Store the JSON securely and reference it through `GOOGLE_SERVICE_ACCOUNT_JSON`.

## Environment Variables

Copy `.env.example` to `.env` and provide project-specific values:

```bash
cp .env.example .env
```

| Variable | Description |
| --- | --- |
| `GOOGLE_SERVICE_ACCOUNT_JSON` | Absolute path to the service account JSON credentials |
| `GOOGLE_SHEETS_INVENTORY_SHEET_ID` | Sheet ID (the string between `/d/` and `/edit` in the URL) |
| `GOOGLE_SHEETS_INVENTORY_TAB` | Inventory tab name (default `Inventory`) |
| `GOOGLE_SHEETS_CATALOG_TAB` | Catalog tab name (default `Catalog`) |
| `ZAPIER_WEBHOOK_SECRET` | Optional shared secret header (`x-zapier-secret`) |
| `DEFAULT_MIN_QUANTITY` | Fallback minimum quantity when upserting unknown items |
| `RESTOCK_QUANTITY` | Quantity used when auto-creating new rows |
| `ALLOW_UNKNOWN_LABELS` | Toggle automatic creation of rows for unseen labels |

## Local Development

### 1. Create a virtual environment

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Export environment variables

```bash
export $(grep -v '^#' .env | xargs)
```

### 3. Run the service

```bash
uvicorn app.main:app --reload
```

### 4. Test the ingestion endpoint

```bash
curl -X POST http://localhost:8000/ingest \
  -H "Content-Type: application/json" \
  -d '{"image_url": "https://example.com/photo.jpg"}'
```

The response will include `restock_items` you can feed into Zapier filters.

### 5. Run automated tests

```bash
pytest
```

## Docker

A Dockerfile is provided for consistent deployments (local or Render).

```bash
docker build -t vision-inventory ops/tool_inventory

docker run --rm -p 8000:8000 \
  -v $(pwd)/service_account.json:/app/service_account.json \
  -e GOOGLE_SERVICE_ACCOUNT_JSON=/app/service_account.json \
  -e GOOGLE_SHEETS_INVENTORY_SHEET_ID=your_sheet_id \
  vision-inventory
```

## Deploy to Render

1. Commit the contents of `ops/tool_inventory` to your repository.
2. Create a **Render Web Service** and point it at the repo.
3. Set the build command to `pip install -r requirements.txt`.
4. Set the start command to `uvicorn app.main:app --host 0.0.0.0 --port $PORT`.
5. Add environment variables in the Render dashboard (same as `.env`).
6. Upload the service account JSON as a private file or use Render secrets.

A `render.yaml` blueprint is included for one-click deployment.

## Zapier Integration

1. **Trigger** – e.g. Google Drive "New File in Folder" when a photo is dropped into a monitoring folder.
2. **Action** – Webhooks by Zapier → POST to `https://your-service/ingest` with payload `{ "image_url": "{{File:DirectDownloadUrl}}" }`. Include `x-zapier-secret` header if configured.
3. **Filter/Path** – Use `restock_items` array. If not empty, send Slack/Email or create purchase order tasks.
4. Optionally log successful updates back into Google Sheets using Zapier's Google Sheets connector (append to audit log tab).

## Folder Structure

```
ops/tool_inventory/
├── app/
│   ├── clients/
│   ├── models/
│   ├── services/
│   └── main.py
├── deployment/
├── requirements.txt
├── Dockerfile
├── render.yaml
└── README.md
```

## Notes & Extensions

- The inventory matching uses alias keywords. Fine-tune the `Catalog` tab to make matching robust (e.g., `impact driver|drill|driver`).
- Extend `InventoryService.process_image` to include location inference or custom restock thresholds per site.
- Add tests under `tests/` for deterministic matching using mocked Vision responses.

