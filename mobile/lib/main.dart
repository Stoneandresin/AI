import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Entry point for the Stone & Resin Inventory application.
///
/// This app demonstrates a minimal implementation of a live camera
/// preview which will serve as the foundation for future on‑device
/// object detection and logging. When launched, it requests access
/// to the first available camera and displays its preview. The
/// navigation structure can be expanded to include additional
/// features such as inventory lists, location management and job
/// check‑outs.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fetch the available cameras before running the app. This
  // ensures that the cameras list is populated prior to the
  // CameraController being created.
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

/// Root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.cameras}) : super(key: key);

  /// A list of cameras available on the device. Passed down to
  /// screens that need camera access.
  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stone & Resin Inventory',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CameraScreen(cameras: cameras),
    );
  }
}

/// A screen that displays the live camera feed. This widget manages
/// initialization and disposal of the [CameraController].
class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Use the first available camera. In future versions, you may
    // select a specific camera (e.g., rear facing) or provide
    // configuration options to the user.
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Items')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Once the controller is initialised, display the camera preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, show a loading spinner.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}