import 'dart:math' as math;

import 'package:accollect/core/app_router.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  BarcodeScannerScreenState createState() => BarcodeScannerScreenState();
}

class BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _foundBarcode = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _disableScreenSleep();
  }

  /// Prevents screen from sleeping while scanning
  Future<void> _disableScreenSleep() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = "No available camera.";
        });
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _cameraController!
          .lockCaptureOrientation(); // ✅ Fixes landscape issue

      if (!mounted) return;

      setState(() {
        _isCameraReady = true;
      });

      _startImageStream();
    } catch (e) {
      setState(() {
        _errorMessage = "Error initializing camera: $e";
      });
    }
  }

  /// ✅ Start continuous scanning from the camera stream
  void _startImageStream() {
    if (!_isCameraReady || _cameraController == null) return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessing || _foundBarcode)
        return; // ✅ Avoid processing multiple frames at once

      setState(() {
        _isProcessing = true;
      });

      try {
        final InputImage inputImage = _convertCameraImage(image);
        final barcodes = await _barcodeScanner.processImage(inputImage);

        if (barcodes.isNotEmpty) {
          _foundBarcode = true;
          HapticFeedback.mediumImpact(); // ✅ Adds haptic feedback
          _showToast("Scanned: ${barcodes.first.rawValue}"); // ✅ Show toast
          _returnResult(barcodes.first.rawValue);
        }
      } catch (e) {
        debugPrint("Error scanning barcode: $e");
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  /// ✅ Convert `CameraImage` to `InputImage` for processing
  InputImage _convertCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final Uint8List bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation90deg,
        // ✅ Ensures portrait mode is handled
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  /// ✅ Show a toast with the barcode
  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  void _returnResult(String? barcodeValue) {
    if (!mounted) return;

    if (barcodeValue != null && barcodeValue.isNotEmpty) {
      _cameraController?.stopImageStream();
      context.pop(Result(content: barcodeValue, status: Status.ok));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloseableAppBar(title: 'Scan Barcode'),
      body: Stack(
        children: [
          // Camera preview with correct orientation
          Positioned.fill(
            child: _isCameraReady
                ? OrientationBuilder(
                    builder: (context, orientation) {
                      return Transform.rotate(
                        angle: orientation == Orientation.portrait
                            ? 0
                            : math.pi / 2,
                        // ✅ Rotate preview
                        child: CameraPreview(_cameraController!),
                      );
                    },
                  )
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!,
                            style: TextStyle(color: Colors.red, fontSize: 16)),
                      )
                    : const Center(child: CircularProgressIndicator()),
          ),

          // Overlay with square scan box
          Positioned.fill(
            child: _buildSquareOverlay(),
          ),

          // Bottom Action Buttons
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildActionButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareOverlay() {
    return IgnorePointer(
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            width: 200, // ✅ Now a perfect square
            height: 200, // ✅ Square scan area
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            _cameraController?.stopImageStream();
            context.pop(Result(status: Status.fail)); // ✅ User manually exits
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
