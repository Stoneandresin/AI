# Roadmap

## MVP (Version 1)

- **Live scanning with confirmation** – Implement camera stream with on‑device detection using ML Kit or custom TFLite model; enable rapid confirm & save flow.
- **Low‑confidence guardrail** – Require user confirmation or QR scan when recognition confidence is below threshold.
- **Quantity & notes** – Provide UI controls for incrementing/decrementing quantity and capturing optional notes.
- **GPS + QR locations** – Associate observations with GPS coordinates outdoors and QR codes indoors; print QR labels from the app.
- **Inventory list & search** – Provide searchable inventory listing with filters and last‑seen information.
- **CSV export & low‑stock alerts** – Schedule daily exports to Google Sheets and trigger alerts when item quantities drop below `reorder_min`.
- **Offline first & sync** – Persist data locally using SQLite, queue writes and sync with Firestore when network is available.

## Version 2

- **Job checkout/return** – Enable assigning items to jobs, tracking what is out and due, and streamlining return flow.
- **Accuracy loop** – Support capturing additional training data in the field; implement weekly model retraining pipeline.
- **Find mode with BLE support** – Provide map/AR view to locate items and optional BLE tag integration to ring tagged tools.

## Version 3

- **AR indoor mapping** – Integrate iOS RoomPlan or ARCore anchors for high‑fidelity indoor positioning and pick‑path guidance.
- **Predictive re‑ordering & maintenance** – Use usage history to predict re‑order points and schedule maintenance based on hours in the field.

This roadmap serves as a guide; adjust priorities based on user feedback and business needs.
