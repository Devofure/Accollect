import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class MultiItemScannerScreen extends StatefulWidget {
  const MultiItemScannerScreen({super.key});

  @override
  _MultiItemScannerScreenState createState() => _MultiItemScannerScreenState();
}

class _MultiItemScannerScreenState extends State<MultiItemScannerScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isDetecting = false;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  // List to store each scanned barcode info.
  final List<Barcode> _scannedBarcodes = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Initializes the camera.
  Future<void> _initializeCamera() async {
    debugPrint("📷 Initializing Camera...");
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint("🚨 No cameras found!");
        return;
      }
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {});
      debugPrint("✅ Camera initialized successfully.");

      // Start image stream.
      _cameraController!.startImageStream((CameraImage image) {
        if (!_isDetecting) {
          _isDetecting = true;
          _processImage(image);
        }
      });
    } catch (e) {
      debugPrint("❌ Camera initialization error: $e");
    }
  }

  /// Processes camera frames and detects barcodes.
  Future<void> _processImage(CameraImage image) async {
    debugPrint("🔍 Processing Camera Image...");
    try {
      final InputImage inputImage = _convertCameraImageToInputImage(image);
      final List<Barcode> barcodes =
          await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        debugPrint("✅ Barcodes detected: ${barcodes.length}");
        // Add each barcode that is not already in our list.
        for (final barcode in barcodes) {
          final String? rawValue = barcode.rawValue;
          if (rawValue != null &&
              !_scannedBarcodes.any((b) => b.rawValue == rawValue)) {
            setState(() {
              _scannedBarcodes.add(barcode);
            });
          }
        }
      } else {
        debugPrint("🚫 No barcodes detected.");
      }
    } catch (e) {
      debugPrint("❌ Error processing image: $e");
    } finally {
      _isDetecting = false;
    }
  }

  /// Converts a [CameraImage] (YUV420 format) to an [InputImage] using NV21 conversion.
  InputImage _convertCameraImageToInputImage(CameraImage image) {
    // Convert YUV420 image to NV21 format.
    final Uint8List nv21Bytes = convertYUV420ToNV21(image);

    // Use sensor orientation from the first camera.
    final int sensorOrientation = _cameras!.first.sensorOrientation;
    InputImageRotation rotation;
    if (sensorOrientation == 90) {
      rotation = InputImageRotation.rotation90deg;
    } else if (sensorOrientation == 180) {
      rotation = InputImageRotation.rotation180deg;
    } else if (sensorOrientation == 270) {
      rotation = InputImageRotation.rotation270deg;
    } else {
      rotation = InputImageRotation.rotation0deg;
    }

    // Create metadata with NV21 settings.
    final InputImageMetadata metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: InputImageFormat.nv21,
      bytesPerRow: image.width,
    );

    return InputImage.fromBytes(bytes: nv21Bytes, metadata: metadata);
  }

  /// Converts a YUV420 [CameraImage] to NV21 format.
  Uint8List convertYUV420ToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = ySize ~/ 2;
    final Uint8List nv21 = Uint8List(ySize + uvSize);

    // Copy Y plane.
    final Plane yPlane = image.planes[0];
    for (int row = 0; row < height; row++) {
      final int rowStart = row * yPlane.bytesPerRow;
      nv21.setRange(row * width, row * width + width, yPlane.bytes, rowStart);
    }

    // Interleave V and U planes. For NV21, V comes first, then U.
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];
    int uvOffset = ySize;
    for (int row = 0; row < height ~/ 2; row++) {
      final int uRowStart = row * uPlane.bytesPerRow;
      final int vRowStart = row * vPlane.bytesPerRow;
      for (int col = 0; col < width ~/ 2; col++) {
        nv21[uvOffset++] = vPlane.bytes[vRowStart + col];
        nv21[uvOffset++] = uPlane.bytes[uRowStart + col];
      }
    }
    return nv21;
  }

  @override
  void dispose() {
    debugPrint("🛑 Disposing resources...");
    _barcodeScanner.close();
    _cameraController?.dispose();
    super.dispose();
  }

  /// Rotates the camera preview based on sensor orientation.
  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    // Get sensor orientation.
    final int sensorOrientation = _cameras!.first.sensorOrientation;
    int quarterTurns;
    if (sensorOrientation == 90) {
      quarterTurns = 1;
    } else if (sensorOrientation == 270) {
      quarterTurns = 3;
    } else {
      quarterTurns = 0;
    }
    return RotatedBox(
      quarterTurns: quarterTurns,
      child: CameraPreview(_cameraController!),
    );
  }

  /// Builds an overlay list displaying each scanned item.
  Widget _buildScannedItemsOverlay() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        height: 150,
        child: ListView.builder(
          itemCount: _scannedBarcodes.length,
          itemBuilder: (context, index) {
            final barcode = _scannedBarcodes[index];
            return ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.white),
              title: Text(
                barcode.rawValue ?? "Unknown",
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                barcode.format.name,
                style: const TextStyle(color: Colors.white70),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Multi-Item Scanner")),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildCameraPreview()),
              // Optionally, display the list below the preview.
              // Alternatively, you can overlay it on the preview as shown below.
              // Container(
              //   height: 150,
              //   child: _buildScannedItemsOverlay(),
              // ),
            ],
          ),
          // Overlay the scanned items list on top of the preview.
          _buildScannedItemsOverlay(),
        ],
      ),
    );
  }
}
