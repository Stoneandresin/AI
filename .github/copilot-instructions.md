# Copilot Repository Instructions

Welcome to the Stone & Resin AI repository. This project is a cross-platform Flutter mobile application designed to streamline the tracking of tools and materials in the field. The app uses on-device computer vision to recognize items, records observations with location and metadata, and syncs data via Firebase.

## Architecture Overview

- **mobile/** – Flutter application code with modular feature-based architecture
- **ml/** – Dataset, training scripts and exported TFLite models for on-device detection
- **serverless/** – Cloud Functions and scripts for scheduled tasks
- **ops/** – CI configuration and Codex task recipes
- **docs/** – Architecture, data model and roadmap documentation

## Local Development

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Android Studio or VS Code with Flutter extensions
- For iOS development: Xcode and CocoaPods

### Getting Started
- Navigate to the `mobile/` directory for all Flutter commands
- Run `flutter pub get` to install dependencies
- Use `flutter run` to start the app on a connected device/emulator
- Run `flutter test` to execute all unit and widget tests
- Use `flutter analyze` to run static analysis and linting
- Build with `flutter build apk` (Android) or `flutter build ios` (iOS)

### Build and Test Commands
- **Install dependencies**: `flutter pub get`
- **Run app**: `flutter run`
- **Run tests**: `flutter test`
- **Lint/analyze**: `flutter analyze`
- **Format code**: `dart format .`
- **Build for Android**: `flutter build apk`
- **Build for iOS**: `flutter build ios`

## Coding Conventions

### Flutter/Dart Standards
- Write functional widgets where possible; use StatefulWidget only when necessary
- Keep widgets small and focused on a single responsibility
- Use proper Flutter directory structure under `lib/`
- Follow Dart naming conventions (camelCase for variables, PascalCase for classes)
- Use explicit types for function parameters and return values
- Prefer `const` constructors and widgets for better performance

### Project Structure
- **Core**: Dependency injection, logging and error handling (`lib/core/`)
- **Data**: Repository layer, models, and data sources (`lib/data/`)
- **Features**: Individual modules for scanning, inventory, location management (`lib/features/`)
- Each feature should have its own `models/`, `screens/`, `widgets/`, and `services/` subdirectories

### Business Domain Guidelines
- Our business involves tracking tools and materials for resin-bound surface installations
- The app title should consistently be "Stone & Resin Inventory" (with spaces and ampersand)
- Focus on offline-first functionality with eventual Firebase sync
- Computer vision features should be optimized for on-device inference using TensorFlow Lite
- Location tracking should respect user privacy and battery life
- Inventory management should support barcode/QR scanning and manual entry
- Use Material 3 design system with teal color scheme (`colorSchemeSeed: Colors.teal`)

### Code Quality
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Implement proper error handling with user-friendly messages
- Write unit tests for business logic and widget tests for UI components
- Ensure accessibility with proper semantics and screen reader support

## Suitable Tasks for Copilot

Copilot works best on well-scoped, discrete tasks such as:

### UI/Widget Development
- Creating new screens or widgets for inventory management features
- Implementing form validation and input handling
- Adding responsive layouts and improving accessibility
- Building reusable UI components and custom widgets

### Data and State Management
- Implementing repository patterns for data access
- Creating model classes and serialization logic
- Adding local SQLite database operations
- Integrating Firebase Firestore sync functionality

### Feature Implementation
- Adding camera integration and barcode scanning
- Implementing offline data storage and sync
- Creating search and filtering functionality
- Building location tracking and GPS features

### Testing and Quality
- Writing unit tests for business logic
- Creating widget tests for UI components
- Adding integration tests for complete user flows
- Fixing linting issues and improving code quality

### Documentation and Maintenance
- Updating README files and code documentation
- Refactoring components for better maintainability
- Optimizing performance and reducing bundle size
- Updating dependencies and fixing deprecation warnings

## Tasks to Avoid Assigning Directly to Copilot

### Complex Architecture Changes
- Major refactoring spanning multiple features or modules
- Changes to core dependency injection or app architecture
- Database migration scripts or schema changes
- CI/CD pipeline modifications or deployment configuration

### Platform-Specific Integration
- Native Android/iOS code or platform channels
- Camera or hardware integration requiring platform-specific knowledge
- Push notification setup or deep linking configuration
- App store submission or release management

### Business Logic and Domain Knowledge
- Complex inventory algorithms or business rules
- Integration with external APIs or third-party services
- ML model training, optimization, or deployment
- Security implementation or authentication flows

### Design and UX Decisions
- Major UI/UX design changes or design system decisions
- Accessibility compliance for complex interactions
- Performance optimization requiring profiling or benchmarking
- User research insights or A/B testing implementation

## Issue Guidelines

For each issue assigned to Copilot, include:

1. **Clear Problem Statement**: Describe what needs to be implemented or fixed
2. **Acceptance Criteria**: Define what constitutes a successful solution
3. **File References**: Point to relevant files, widgets, or features to modify
4. **Constraints**: Specify any limitations (maintain existing APIs, performance requirements, etc.)
5. **Testing Requirements**: Indicate what types of tests should be added or updated

### Example Issue Structure
```
**Problem**: Add search functionality to the inventory screen
**Acceptance Criteria**: 
- Users can search items by name or description
- Search results update in real-time as user types
- Clear search button to reset results
**Files to Modify**: 
- `lib/features/inventory/screens/inventory_screen.dart`
- `lib/features/inventory/widgets/search_bar.dart`
**Constraints**: 
- Maintain existing list performance with large datasets
- Follow existing design patterns for search UI
**Testing**: 
- Add widget tests for search functionality
- Ensure search works with mock data
```

## Development Workflow

1. **Start with Analysis**: Run `flutter analyze` to check for existing issues
2. **Install Dependencies**: Ensure `flutter pub get` completes successfully  
3. **Run Tests**: Execute `flutter test` to verify current test suite passes
4. **Make Changes**: Implement features following the coding conventions above
5. **Test Changes**: Add appropriate tests and verify they pass
6. **Format Code**: Run `dart format .` to ensure consistent formatting
7. **Final Validation**: Run full test suite and analysis before submitting

Always ensure that `flutter analyze` and `flutter test` complete successfully before submitting changes.