import 'dart:async';
import 'package:camera/camera.dart';

class CameraManager {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  CameraController? get controller => _controller;

  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<String?> initialize() async {
    try {
      await _controller?.dispose();
      _controller = null;

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        return 'Nincs elérhető kamera';
      }

      final camera = _findBackCamera(_cameras!);

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      await _configureCameraSettings();

      return null;
    } catch (e) {
      return 'Nem sikerült a kamera inicializálása: $e';
    }
  }

  CameraDescription _findBackCamera(List<CameraDescription> cameras) {
    try {
      return cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    } catch (e) {
      return cameras.first;
    }
  }

  Future<void> _configureCameraSettings() async {
    if (!isInitialized) return;

    try {
      await _controller!.setFlashMode(FlashMode.off);
    } catch (e) {
      //Nincs error handling, mert nem kelll, csak silently lekezeli
    }

    try {
      await _controller!.setFocusMode(FocusMode.auto);
    } catch (e) {
      //Nincs error handling, mert nem kell, csak silently lekezeli
    }

    try {
      await _controller!.setExposureMode(ExposureMode.auto);
    } catch (e) {
      //Nincs error handling, mert nem kell, csak silently lekezeli
    }
  }

  Future<String?> captureImage() async {
    if (!isInitialized) {
      return null;
    }

    try {
      final XFile image = await _controller!.takePicture();
      return image.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _cameras = null;
  }
}
