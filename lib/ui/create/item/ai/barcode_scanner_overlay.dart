import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerOverlay extends StatefulWidget {
  final CameraController controller;
  final Function(Barcode?) onBarcodeDetected;

  const BarcodeScannerOverlay(
      {required this.controller, required this.onBarcodeDetected, super.key});

  @override
  _BarcodeScannerOverlayState createState() => _BarcodeScannerOverlayState();
}

class _BarcodeScannerOverlayState extends State<BarcodeScannerOverlay> {
  final barcodeScanner = BarcodeScanner();
  bool isProcessing = false;
  String debugText = "Waiting for barcode...";
  Barcode? lastDetectedBarcode;

  @override
  void initState() {
    super.initState();
    _processCameraStream();
  }

  void _processCameraStream() {
    widget.controller.startImageStream((CameraImage image) async {
      if (isProcessing) return;
      isProcessing = true;

      final InputImage inputImage = _convertCameraImageToInputImage(image);
      final barcodes = await barcodeScanner.processImage(inputImage);

      setState(() {
        if (barcodes.isNotEmpty) {
          lastDetectedBarcode = barcodes.first;
          debugText = "Detected: ${barcodes.first.rawValue}";
          widget.onBarcodeDetected(barcodes.first);
        } else {
          debugText = "No barcode detected";
        }
      });

      isProcessing = false;
    });
  }

  InputImage _convertCameraImageToInputImage(CameraImage image) {
    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (lastDetectedBarcode != null)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.black54,
              child: Text(debugText, style: TextStyle(color: Colors.white)),
            ),
          ),
      ],
    );
  }
}
