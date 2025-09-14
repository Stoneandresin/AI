# Architecture Overview

The application follows a modular architecture with a clear separation between the front‑end mobile app, on‑device machine‑learning models, and backend services. Key components:

## Mobile (Flutter)

- **Core**: Dependency injection, logging and error handling.
- **Data**: Repository layer which abstracts data sources (local SQLite and remote Firestore).
- **Models**: Data classes representing `Item`, `Observation`, `Location`, `Job`, and `Checkout`.
- **Sources**: Local and remote implementations of the data repositories.
- **Features**: Individual modules for scanning, inventory management, location management, finding items, and job check‑in/out. Each feature exposes a consistent interface and isolates UI, state management and business logic.

## Machine Learning

The ML directory hosts the dataset used for training, scripts to export custom YOLO models to TensorFlow Lite, and the resulting TFLite models. The app bundles a lightweight detector model which is updated via an over‑the‑air mechanism.

## Serverless Backend

Cloud Functions power scheduled jobs such as CSV export to Google Sheets and low‑stock alerts. Firestore is used as the primary database with Cloud Storage storing cropped training images. Functions maintain a materialised `lastSeen` collection to allow efficient queries for “last seen” information.

## DevOps

The repository includes CI workflows to lint, test and build the mobile app. Codex task recipes live under `ops/codex` and describe automated tasks for the Codex agent to run when integrated.
