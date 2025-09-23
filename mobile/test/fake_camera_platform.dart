import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A simple fake camera platform that immediately completes initialization
/// without delegating to the native plugins.
class FakeCameraPlatform extends CameraPlatform {
  FakeCameraPlatform({
    List<CameraDescription>? cameras,
    this.previewSize = const Size(1280, 720),
  })  : _cameras = List<CameraDescription>.unmodifiable(
          cameras ??
              const <CameraDescription>[
                CameraDescription(
                  name: 'Fake Camera 0',
                  lensDirection: CameraLensDirection.back,
                  sensorOrientation: 0,
                ),
              ],
        ),
        _deviceOrientationController = _createOrientationController();

  final List<CameraDescription> _cameras;
  final Map<int, StreamController<CameraInitializedEvent>>
      _cameraInitializedControllers =
      <int, StreamController<CameraInitializedEvent>>{};
  final StreamController<DeviceOrientationChangedEvent>
      _deviceOrientationController;
  final Map<int, Widget> _previewWidgets = <int, Widget>{};
  final Size previewSize;
  int _nextCameraId = 0;

  /// Cameras exposed by this fake implementation.
  List<CameraDescription> get cameras => List<CameraDescription>.unmodifiable(
        _cameras,
      );

  @override
  Future<List<CameraDescription>> availableCameras() async => cameras;

  @override
  Future<int> createCameraWithSettings(
    CameraDescription cameraDescription,
    MediaSettings mediaSettings,
  ) async {
    final int cameraId = _nextCameraId++;
    _cameraInitializedControllers[cameraId] =
        StreamController<CameraInitializedEvent>.broadcast();
    _previewWidgets[cameraId] = const ColoredBox(color: Color(0xFF000000));
    return cameraId;
  }

  @override
  Future<void> initializeCamera(
    int cameraId, {
    ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown,
  }) async {
    final StreamController<CameraInitializedEvent>? controller =
        _cameraInitializedControllers[cameraId];
    if (controller == null || controller.isClosed) {
      return;
    }

    controller.add(
      CameraInitializedEvent(
        cameraId,
        previewSize.width,
        previewSize.height,
        ExposureMode.auto,
        false,
        FocusMode.auto,
        false,
      ),
    );
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) =>
      _cameraInitializedControllers
          .putIfAbsent(
            cameraId,
            () => StreamController<CameraInitializedEvent>.broadcast(),
          )
          .stream;

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() =>
      _deviceOrientationController.stream;

  @override
  Widget buildPreview(int cameraId) =>
      _previewWidgets[cameraId] ?? const SizedBox.shrink();

  @override
  Future<void> dispose(int cameraId) async {
    await _cameraInitializedControllers.remove(cameraId)?.close();
    _previewWidgets.remove(cameraId);
  }

  /// Releases any resources held by the fake platform itself.
  Future<void> disposePlatform() async {
    await Future.wait<void>(
      _cameraInitializedControllers.values.map(
        (StreamController<CameraInitializedEvent> controller) async {
          if (!controller.isClosed) {
            await controller.close();
          }
        },
      ),
    );
    _cameraInitializedControllers.clear();
    _previewWidgets.clear();
    if (!_deviceOrientationController.isClosed) {
      await _deviceOrientationController.close();
    }
  }
}

StreamController<DeviceOrientationChangedEvent> _createOrientationController() {
  late final StreamController<DeviceOrientationChangedEvent> controller;
  controller = StreamController<DeviceOrientationChangedEvent>.broadcast(
    onListen: () {
      controller.add(
        const DeviceOrientationChangedEvent(DeviceOrientation.portraitUp),
      );
    },
  );
  return controller;
}
