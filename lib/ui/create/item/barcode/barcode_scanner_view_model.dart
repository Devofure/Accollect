import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerViewModel extends ChangeNotifier {
  late Command<void, String?> startScanningCommand;
  CameraController? cameraController;
  BarcodeScanner? _barcodeScanner;
  bool _isScanning = false;
  String? scannedBarcode;

  BarcodeScannerViewModel() {
    _setupCommands();
  }

  void _setupCommands() {
    startScanningCommand =
        Command.createAsyncNoParam<String?>(_startScanning, initialValue: null);
  }

  Future<String?> _startScanning() async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    cameraController = CameraController(camera, ResolutionPreset.medium);
    await cameraController!.initialize();

    _barcodeScanner = BarcodeScanner();
    _isScanning = true;
    notifyListeners();

    return _scanBarcode();
  }

  Future<String?> _scanBarcode() async {
    if (!_isScanning || cameraController == null) return null;

    cameraController!.startImageStream((CameraImage image) async {
      if (!_isScanning) return;

      final WriteBuffer allBytes = WriteBuffer();
      for (var plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final InputImage inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final barcodes = await _barcodeScanner!.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        _isScanning = false;
        scannedBarcode = barcodes.first.rawValue;
        notifyListeners();
      }
    });

    return scannedBarcode;
  }

  void disposeScanner() {
    cameraController?.dispose();
    _barcodeScanner?.close();
    _isScanning = false;
  }
}
