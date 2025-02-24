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

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint("No cameras found.");
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

  /// Processes camera frames and detects barcodes using ML Kit.
  Future<void> _processImage(CameraImage image) async {
    try {
      final InputImage inputImage = convertCameraImageToInputImage(
        image,
        _cameras!.first.sensorOrientation,
      );
      final List<Barcode> barcodes =
          await _barcodeScanner.processImage(inputImage);
      if (barcodes.isNotEmpty) {
        final viewModel = context.read<MultiItemScannerViewModel>();
        for (final barcode in barcodes) {
          final String? rawValue = barcode.rawValue;
          final String barcodeType = barcode.format.name; // Track barcode type
          if (rawValue != null) {
            await viewModel.addBarcode(rawValue, barcodeType);
          }
        }
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
        height: 220,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: viewModel.scannedItems.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white38),
          itemBuilder: (context, index) {
            final item = viewModel.scannedItems[index];
            return ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.white),
              title: Text(
                item.barcode,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Type: ${item.barcodeType}\n" +
                    (item.details != null
                        ? item.details!['title'] ?? "No title"
                        : "No details"),
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () {
                context.push('/create-item', extra: item);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    final viewModel = context.watch<MultiItemScannerViewModel>();
    return viewModel.scannedItems.isNotEmpty
        ? FloatingActionButton.extended(
            onPressed: () => viewModel.clearAll(),
            label: const Text("Clear Scans"),
            icon: const Icon(Icons.delete_forever),
            backgroundColor: Colors.redAccent,
          )
        : const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CloseableAppBar(title: "Multi-Item Scanner"),
      body: Column(
        children: [
          Expanded(
              flex: 7,
              child: Stack(children: [
                _buildCameraPreview(),
              ])),
          // **Restored camera layout**
          Expanded(flex: 3, child: _buildScannedItemsOverlay()),
          // 30% list overlay
        ],
      ),
      floatingActionButton: _buildClearButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
