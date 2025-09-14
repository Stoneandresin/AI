# Data Model

## Item

| Field      | Type    | Description                                               |
|-----------|---------|-----------------------------------------------------------|
| id        | string  | Unique identifier for the item.                           |
| name      | string  | Human‑readable name of the item.                          |
| category  | string  | Category tag (tool, material, PPE, etc.).                 |
| sku       | string  | Stock keeping unit or part number.                        |
| brand     | string  | Manufacturer or brand.                                    |
| variant   | string  | Size, colour or other variant description.                |
| reorder_min | number | Minimum quantity threshold triggering low‑stock alerts.    |
| image_ref | string  | Reference to the item image stored in Cloud Storage.      |

## Observation

| Field      | Type    | Description                                                        |
|-----------|---------|--------------------------------------------------------------------|
| id        | string  | Unique identifier for the observation.                             |
| item_id   | string  | Foreign key to the `Item` observed.                                 |
| user_id   | string  | User who captured the observation.                                  |
| ts        | DateTime| Timestamp of the observation.                                       |
| qty       | number  | Quantity observed.                                                  |
| confidence| float   | Confidence score of the recognition.                                |
| method    | enum    | Method of capture: `cv` (computer vision), `qr` (QR scan), `voice`. |
| notes     | string  | Optional notes or comments.                                         |

## Location

| Field     | Type    | Description                                                             |
|----------|---------|---------------------------------------------------------------------------|
| id       | string  | Unique identifier for the location.                                       |
| type     | enum    | Location type: `gps`, `qr`, `ar`, `ble`.                                  |
| label    | string  | Human‑readable label for the location.                                    |
| geo      | object  | Latitude/longitude for GPS locations.                                     |
| indoor_ref | string | Reference to indoor zone or shelf (for QR/AR locations).                 |
| anchor_id | string | Reference to AR anchor or BLE tag when applicable.                        |

## Job

| Field     | Type    | Description                                         |
|----------|---------|-----------------------------------------------------|
| id       | string  | Unique identifier for the job.                      |
| name     | string  | Job or project name.                                |
| site_geo | object  | Geolocation of the job site.                        |
| customer | string  | Customer information.                               |
| status   | string  | Current status (active, completed, invoiced, etc.). |

## Checkout

| Field      | Type    | Description                                        |
|-----------|---------|----------------------------------------------------|
| job_id    | string  | Foreign key to the associated job.                |
| item_id   | string  | Foreign key to the checked‑out item.              |
| qty       | number  | Quantity checked out.                             |
| out_ts    | DateTime| Timestamp when item was checked out.               |
| due_ts    | DateTime| Due date for returning the item.                   |
| returned_ts | DateTime| Timestamp when item was returned (optional).      |

A Cloud Function maintains a denormalised `lastSeen` collection mapping each `item_id` to its most recent `location_id`, timestamp and user.
