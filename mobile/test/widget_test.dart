// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:camera/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/observation.dart';
import 'package:mobile/data/services/inventory_service.dart';
import 'package:mobile/main.dart';

import 'fake_camera_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const CameraDescription testCamera = CameraDescription(
    name: 'Test Camera',
    lensDirection: CameraLensDirection.back,
    sensorOrientation: 0,
  );

  late FakeCameraPlatform fakeCameraPlatform;

  setUp(() {
    fakeCameraPlatform = FakeCameraPlatform(
      cameras: const <CameraDescription>[testCamera],
    );
    CameraPlatform.instance = fakeCameraPlatform;
  });

  tearDown(() async {
    await fakeCameraPlatform.disposePlatform();
  });

  group('Stone & Resin Inventory App Tests', () {
    testWidgets('Main app loads with bottom navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(cameras: const <CameraDescription>[testCamera]),
      );
      await tester.pumpAndSettle();

      // Verify that we have a bottom navigation bar
      expect(find.byType(NavigationBar), findsOneWidget);

      // Verify navigation destinations
      expect(find.text('Scan'), findsOneWidget);
      expect(find.text('Inventory'), findsOneWidget);
      expect(find.text('Locations'), findsOneWidget);
      expect(find.text('Jobs'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('Can navigate to inventory screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MyApp(cameras: const <CameraDescription>[testCamera]),
      );
      await tester.pumpAndSettle();

      // Tap on Inventory tab
      await tester.tap(find.text('Inventory'));
      await tester.pumpAndSettle();

      // Should see inventory screen
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Inventory'),
        ),
        findsOneWidget,
      );
      expect(find.text('Search items...'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('Camera screen shows proper UI elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CameraScreen(cameras: <CameraDescription>[testCamera]),
      ));

      // Allow the FutureBuilder to settle after initialization.
      await tester.pumpAndSettle();

      // Should show scan items title
      expect(find.text('Scan Items'), findsOneWidget);

      // Should show the log item button
      expect(find.text('Log Item'), findsOneWidget);

      // Should show QR code button
      expect(find.text('QR Code'), findsOneWidget);

      // Should show the camera preview once initialization succeeds.
      expect(find.byType(CameraPreview), findsOneWidget);
      expect(find.text('Camera preview unavailable on this device.'),
          findsNothing);

      // Dispose the camera screen to clean up the controller.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });

  group('Inventory Service Tests', () {
    test('Inventory service provides sample items', () {
      final service = InventoryService();

      expect(service.items.isNotEmpty, true);
      expect(service.items.length, greaterThan(3));

      // Check that we have items from different categories
      final categories = service.items.map((item) => item.category).toSet();
      expect(categories.contains('Tools'), true);
      expect(categories.contains('PPE'), true);
      expect(categories.contains('Materials'), true);
    });

    test('Can search items by name and SKU', () {
      final service = InventoryService();

      // Search by name
      final drillResults = service.searchItems('drill');
      expect(drillResults.isNotEmpty, true);
      expect(drillResults.first.name.toLowerCase().contains('drill'), true);

      // Search by SKU
      final skuResults = service.searchItems('CD-001');
      expect(skuResults.isNotEmpty, true);
      expect(skuResults.first.sku, 'CD-001');
    });

    test('Can filter items by category', () {
      final service = InventoryService();

      final toolItems = service.getItemsByCategory('Tools');
      expect(toolItems.isNotEmpty, true);

      for (final item in toolItems) {
        expect(item.category, 'Tools');
      }
    });

    test('Can add and retrieve observations', () {
      final service = InventoryService();

      final initialCount = service.observations.length;

      // Add a test observation
      final observation = Observation(
        id: 'test-1',
        itemId: '1',
        timestamp: DateTime.parse('2024-01-01'),
        quantity: 5,
        method: ObservationMethod.scan,
      );

      service.addObservation(observation);

      expect(service.observations.length, initialCount + 1);
      expect(service.observations.last.id, 'test-1');
      expect(service.observations.last.quantity, 5);
    });
  });
}
