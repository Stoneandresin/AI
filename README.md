# Stone & Resin Inventory App

This repository contains a cross‑platform mobile application designed to streamline the tracking of tools and materials in the field. The app uses on‑device computer vision to recognise items, records observations with location and metadata, and syncs data via Firebase. It is structured to support an offline‑first workflow with eventual sync, modular architecture and extensible ML pipeline.

## Contents

- **mobile/** – Flutter application code.
- **ml/** – Dataset, training scripts and exported TFLite models for on‑device detection.
- **serverless/** – Cloud Functions and scripts for scheduled tasks such as daily exports and low‑stock alerts.
- **ops/** – CI configuration and Codex task recipes.
- **docs/** – Architecture, data model and roadmap documentation.

For a high‑level overview of the product vision, features and roadmap, consult the files in the `docs/` directory.
