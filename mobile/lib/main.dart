import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'data/models/observation.dart';
import 'data/services/inventory_service.dart';
import 'features/scan/observation_list_screen.dart';
import 'features/scan/observation_input_dialog.dart';
import 'features/inventory/inventory_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  List<CameraDescription> cameras = const [];
  if (kIsWeb || Platform.isAndroid || Platform.isIOS) {
    try {
      cameras = await availableCameras();
    } catch (_) {
      // ignore
    }
  }

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.cameras});

  /// A list of cameras available on the device. Passed down to
  /// screens that need camera access.
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stone & Resin Inventory',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: MainScreen(cameras: cameras),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CameraScreen(cameras: widget.cameras),
      const InventoryScreen(),
      const LocationsScreen(),
      const JobsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on),
            label: 'Locations',
          ),
          NavigationDestination(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
        ],
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late Future<void> _init;
  final InventoryService _inventoryService = InventoryService();

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(widget.cameras.first, ResolutionPreset.medium);
      _init = _controller!.initialize();
    } else {
      _init = Future.value();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _logObservation() async {
    final observation = await showDialog<Observation>(
      context: context,
      builder: (context) => const ObservationInputDialog(),
    );
    
    if (observation != null) {
      _inventoryService.addObservation(observation);
      final item = _inventoryService.getItemById(observation.itemId);
      final itemName = item?.name ?? 'Unknown Item';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logged ${observation.quantity}x $itemName'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ObservationListScreen(observations: _inventoryService.observations),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_controller == null || !_controller!.value.isInitialized) {
            return const Center(child: Text('Camera not available on this platform.'));
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(_controller!),
              CustomPaint(painter: CrosshairPainter()),
              Positioned(
                left: 0, right: 0, bottom: 80,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Center the tool/material in the crosshair, then tap Log.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _logObservation,
                            icon: const Icon(Icons.add),
                            label: const Text('Log Item'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Add QR scan functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('QR scan coming soon')),
                              );
                            },
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('QR Code'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Placeholder screen for locations management
class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Location Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'GPS tracking and QR location labels\ncoming soon!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder screen for jobs management
class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Job Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Track item check-ins and check-outs\nfor different job sites.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFFFFFFFF).withOpacity(0.9);

    final w = size.width, h = size.height;
    final rect = Rect.fromCenter(
      center: Offset(w / 2, h / 2),
      width: w * 0.6,
      height: h * 0.35,
    );
    canvas.drawRect(rect, p);

    const tick = 18.0;
    canvas.drawLine(Offset(rect.center.dx, rect.top),
                    Offset(rect.center.dx, rect.top + tick), p);
    canvas.drawLine(Offset(rect.center.dx, rect.bottom - tick),
                    Offset(rect.center.dx, rect.bottom), p);
    canvas.drawLine(Offset(rect.left, rect.center.dy),
                    Offset(rect.left + tick, rect.center.dy), p);
    canvas.drawLine(Offset(rect.right - tick, rect.center.dy),
                    Offset(rect.right, rect.center.dy), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
