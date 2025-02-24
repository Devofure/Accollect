import 'package:accollect/ui/create/item/ai/multi_item_scanner_view_model.dart';
import 'package:accollect/ui/create/item/ai/scanner_utils.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:provider/provider.dart';

class MultiItemScannerScreen extends StatefulWidget {
  const MultiItemScannerScreen({super.key});

  @override
  MultiItemScannerScreenState createState() => MultiItemScannerScreenState();
}

class MultiItemScannerScreenState extends State<MultiItemScannerScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isDetecting = false;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final String _scannedData = "";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
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
      final InputImage inputImage = convertCameraImageToInputImage(
          image, _cameras!.first.sensorOrientation);
      final List<Barcode> barcodes =
          await _barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        final viewModel = context.read<MultiItemScannerViewModel>();
        for (final barcode in barcodes) {
          final String? rawValue = barcode.rawValue;
          if (rawValue != null) {
            viewModel.addBarcode(rawValue);
          }
        }
      } else {
        debugPrint("🚫 No barcodes detected.");
      }
    } catch (e, s) {
      debugPrint("❌ Error processing image: $e, $s");
    } finally {
      _isDetecting = false;
    }
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    _cameraController?.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return RotatedBox(
      quarterTurns: 1,
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildScannedItemsOverlay() {
    final viewModel = context.watch<MultiItemScannerViewModel>();
    if (viewModel.scannedItems.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        height: 150,
        child: ListView.builder(
          itemCount: viewModel.scannedItems.length,
          itemBuilder: (context, index) {
            final item = viewModel.scannedItems[index];
            return ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.white),
              title: Text(
                item.barcode,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                item.details != null ? item.details!['title'] ?? "" : "",
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () {
                // Navigate to your multi-step create item screen, passing item details.
                context.push('/create-item', extra: item);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloseableAppBar(title: "Multi-Item Scanner"),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildCameraPreview()),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Scanned Data:\n$_scannedData",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          _buildScannedItemsOverlay(),
        ],
      ),
    );
  }
}
