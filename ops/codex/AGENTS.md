# Codex Task Recipes

Codex operates in a sandboxed environment to run automated tasks against your repository. Tasks are defined in this file and referenced by your CI pipeline or triggered manually.

## Task: run tests & lint

Runs all unit tests and static analysis on the mobile app. It uses Flutter’s test runner and Dart’s analyzer.

```
# codex
run:
  steps:
    - cmd: flutter test
    - cmd: dart analyze
  description: "Execute all tests and lint checks for the mobile app."
  repo_path: mobile
  fail_if: true
```

## Task: generate scan feature skeleton

Generates a skeleton implementation of the scan feature including platform channels for camera stream, detection glue code and overlay widgets. It should compile successfully and include golden tests for the overlay.

```
# codex
gen:
  description: "Scaffold the scan feature in /mobile/lib/features/scan."
  prompts:
    - "Create Flutter code under /mobile/lib/features/scan implementing a live camera preview with bounding box overlay. Use platform channels for native camera access and call a placeholder detection service. Include widget tests for the overlay and ensure it passes dart analyze."
  output:
    commit: true
```
