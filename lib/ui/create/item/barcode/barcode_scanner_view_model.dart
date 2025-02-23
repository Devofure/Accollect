import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;

class BarcodeScannerViewModel extends ChangeNotifier {
  late Command<void, String?> startScanningCommand;
  late Command<String, Map<String, dynamic>> fetchProductDetailsCommand;

  CameraController? cameraController;
  late BarcodeScanner _barcodeScanner;
  bool _isScanning = false;
  String? scannedBarcode;
  Map<String, dynamic>? productDetails;

  BarcodeScannerViewModel() {
    _setupCommands();
  }

  void _setupCommands() {
    startScanningCommand =
        Command.createAsyncNoParam<String?>(_startScanning, initialValue: null);

    fetchProductDetailsCommand =
        Command.createAsync<String, Map<String, dynamic>>(
      _fetchProductDetails,
      initialValue: {},
    );
  }

  Future<String?> _startScanning() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("No available cameras.");
        return null;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController =
          CameraController(camera, ResolutionPreset.medium, enableAudio: false);
      await cameraController!.initialize();
      notifyListeners();

      _barcodeScanner = BarcodeScanner();
      _isScanning = true;

      return null; // Wait for manual trigger (e.g. Button tap)
    } catch (e) {
      debugPrint("Error initializing camera: $e");
      return null;
    }
  }

  Future<void> scanBarcode() async {
    if (!_isScanning || cameraController == null) return;

    try {
      final XFile file = await cameraController!.takePicture();

      final inputImage = InputImage.fromFilePath(file.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        _isScanning = false;
        scannedBarcode = barcodes.first.rawValue;
        notifyListeners();

        fetchProductDetailsCommand.execute(scannedBarcode!);
      }
    } catch (e) {
      debugPrint("Error scanning barcode: $e");
    }
  }

  Future<Map<String, dynamic>> _fetchProductDetails(String barcode) async {
    final Uri url =
        Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];

          // Ensure a valid image URL is always present
          String? imageUrl =
              (item['images'] != null && (item['images'] as List).isNotEmpty)
                  ? item['images'][0]
                  : "https://your-app.com/default_image.png";

          productDetails = {
            ...item,
            'image': imageUrl,
          };

          notifyListeners();
          return productDetails!;
        }
      }
    } catch (e) {
      debugPrint("Error fetching product details: $e");
    }

    return {};
  }

  void disposeScanner() {
    _isScanning = false;
    cameraController?.dispose();
    _barcodeScanner.close();
  }
}
