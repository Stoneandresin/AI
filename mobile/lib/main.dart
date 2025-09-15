import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'data/models/observation.dart';
import 'features/scan/observation_list_screen.dart';

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
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stone & Resin Inventory',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: CameraScreen(cameras: cameras),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late Future<void> _init;
  final List<Observation> _observations = [];

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

  void _logObservation() {
    setState(() {
      _observations.add(Observation(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        itemId: 'UNKNOWN',
        locationId: null,
        timestamp: DateTime.now(),
        quantity: 1,
        method: ObservationMethod.scan,
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Observation logged')),
    );
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
                builder: (_) => ObservationListScreen(observations: _observations),
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
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.black45,
                  child: const Text(
                    'Center the tool/material in the crosshair, then tap Log.',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logObservation,
        icon: const Icon(Icons.add),
        label: const Text('Log Item'),
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
