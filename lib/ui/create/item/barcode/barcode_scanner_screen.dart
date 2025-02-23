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
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _foundBarcode = false;
  bool _isFlashOn = false;
  String? _errorMessage;
  int _sensorOrientation = 0;

  // Animation for scanning line
  late final AnimationController _lineAnimationController;
  late final Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _disableScreenSleep();
    _initializeCamera();

    _lineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _lineAnimation =
        Tween<double>(begin: 0, end: 200).animate(_lineAnimationController);
  }

  Future<void> _disableScreenSleep() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = "No available camera.");
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _sensorOrientation = camera.sensorOrientation;

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _cameraController!
          .lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (!mounted) return;
      setState(() => _isCameraReady = true);

      _startImageStream();
    } catch (e) {
      setState(() => _errorMessage = "Error initializing camera: $e");
    }
  }

  void _startImageStream() {
    if (!_isCameraReady || _cameraController == null) return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (_isProcessing || _foundBarcode) return;
      _isProcessing = true;

      try {
        final inputImage = _convertCameraImage(image);
        final barcodes = await _barcodeScanner.processImage(inputImage);

        if (barcodes.isNotEmpty) {
          debugPrint("Found barcode: ${barcodes.first.rawValue}");
          _foundBarcode = true;
          HapticFeedback.mediumImpact();
          _showToast("Scanned: ${barcodes.first.rawValue}");
          _returnResult(barcodes.first.rawValue);
        }
      } catch (e, s) {
        debugPrint('Error scanning barcode: $e\nStacktrace: $s');
      } finally {
        Future.delayed(const Duration(milliseconds: 500), () {
          _isProcessing = false;
        });
      }
    });
  }

  InputImage _convertCameraImage(CameraImage image) {
    final Uint8List nv21Bytes = convertYUV420ToNV21(image);

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final InputImageRotation rotation = _getImageRotation();

    final InputImageFormat format = InputImageFormat.nv21;

    final int bytesPerRow = image.width;
    debugPrint(
        'Converted image to NV21 - size: $imageSize, rotation: $rotation, format: $format, bytesPerRow: $bytesPerRow');

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: rotation,
      format: format,
      bytesPerRow: bytesPerRow,
    );

    return InputImage.fromBytes(bytes: nv21Bytes, metadata: metadata);
  }

  Uint8List convertYUV420ToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int ySize = width * height;
    final int uvSize = ySize ~/ 2;
    final Uint8List nv21 = Uint8List(ySize + uvSize);

    final Plane yPlane = image.planes[0];
    for (int row = 0; row < height; row++) {
      final int rowStart = row * yPlane.bytesPerRow;
      nv21.setRange(row * width, row * width + width, yPlane.bytes, rowStart);
    }
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

  InputImageRotation _getImageRotation() {
    switch (_sensorOrientation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

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
    if (!mounted || barcodeValue == null || barcodeValue.isEmpty) return;
    _cameraController?.stopImageStream();
    context.pop(Result(content: barcodeValue, status: Status.ok));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _barcodeScanner.close();
    _lineAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloseableAppBar(title: 'Scan Barcode'),
      body: Stack(
        children: [
          Positioned.fill(child: _buildCameraPreview()),
          Positioned.fill(child: _buildSquareOverlay()),
          _buildFlashToggle(),
          _buildInstructionText(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraReady) {
      return _errorMessage != null
          ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : const Center(child: CircularProgressIndicator());
    }

    return RotatedBox(
      quarterTurns: _sensorOrientation == 90
          ? 1
          : _sensorOrientation == 270
              ? 3
              : 0,
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildSquareOverlay() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _lineAnimationController,
                builder: (context, child) {
                  return Positioned(
                    top: _lineAnimation.value,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: Colors.redAccent,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionText() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          "Align barcode within the frame",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
          ),
        ),
      ),
    );
  }

  Widget _buildFlashToggle() {
    return Positioned(
      top: 40,
      right: 20,
      child: IconButton(
        icon: Icon(
          _isFlashOn ? Icons.flash_on : Icons.flash_off,
          color: Colors.white,
          size: 28,
        ),
        onPressed: () async {
          if (_cameraController == null) return;
          _isFlashOn = !_isFlashOn;
          await _cameraController!
              .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          _cameraController?.stopImageStream();
          context.pop(Result(status: Status.fail));
        },
        child: const Text(
          "Cancel",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
