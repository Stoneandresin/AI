# Prioritized Backlog

This backlog enumerates deliverables required to build the Stone & Resin Inventory app.

## Epic A — Live Scan & Recognition (MVP)

1. **Camera stream & on‑device detector**\
   *Implement a live camera stream in Flutter with bounding‑box overlays. Integrate ML Kit Object Detection or a custom TensorFlow Lite detector. Provide a responsive UI that allows the user to tap detections, confirm an item and save an observation.*

2. **Low‑confidence guardrail**\
   *When recognition confidence is below a configurable threshold or items look similar, require the user to confirm via a tap or fallback to scanning a QR code.*

3. **Quantity & notes**\
   *Add UI controls for incrementing/decrementing quantity and capturing optional text notes or voice‑to‑text.*

4. **OCR for labels/lot**\
   *Integrate OCR (e.g., ML Kit Text Recognition) to capture part or lot numbers from labels where available.*

## Epic B — Locations (MVP)

5. **GPS geofences**\
   *Record GPS coordinates for outdoor observations. Implement geofences to attach site labels automatically.*

6. **QR shelf labels**\
   *Generate and manage QR codes for indoor shelves, bins or van zones. Provide an interface to print labels from the app.*

7. **Last‑seen view**\
   *Expose a view showing the last known location, timestamp and observer for each item.*

## Epic C — Inventory & Search (MVP)

8. **Inventory listing & filtering**\
   *Implement a searchable list of items with category chips and a pill showing last‑seen information.*

9. **CSV export & low‑stock alerts**\
   *Develop a Cloud Function to export inventory changes to Google Sheets daily. Trigger notifications when quantities fall below reorder thresholds.*

## Epic D — Offline‑first & Sync (MVP)

10. **Local cache & sync**\
    *Introduce a local SQLite cache to ensure full functionality offline. Implement a reliable retry queue and conflict resolution for syncing with Firestore.*

## Epic E — Job checkout/return (Version 2)

11. **Job management**\
    *Allow users to create jobs, assign items and track check‑outs with due dates. Provide a return workflow highlighting missing items.*

## Epic F — Accuracy loop (Version 2)

12. **In‑app data capture**\
    *Enable capturing additional images for new SKUs through the app. Queue data for training and integrate with a serverless training pipeline.*

## Epic G — Find mode + BLE (Version 2)

13. **Find mode**\
    *Implement map/AR view showing last‑seen location; integrate optional BLE tag support to “ring” items.*

---

Each backlog item should be turned into a GitHub issue with appropriate labels (e.g., `epic-a`, `mvp`, `ml`) and acceptance criteria. Acceptance criteria for the MVP are defined as:

- *From opening the app to saving an observation requires no more than four taps and five seconds on average.*
- *Recognition accuracy for the top 30 SKUs is at least 90% with human verification.*
- *GPS locations are accurate within 10 m; indoor locations are resolved through QR codes.*
- *The app functions fully offline and no data is lost upon crash or force‑quit.*
- *A daily CSV export includes item, quantity delta, last‑seen location and timestamp.*
