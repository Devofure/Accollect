import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'barcode_scanner_view_model.dart';

class BarcodeScannerScreen extends StatelessWidget {
  final Function(String) onBarcodeScanned;

  const BarcodeScannerScreen({super.key, required this.onBarcodeScanned});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BarcodeScannerViewModel>();

    return Scaffold(
      appBar: CloseableAppBar(title: 'Scan Barcode'),
      body: Column(
        children: [
          Expanded(
            child: viewModel.cameraController != null &&
                    viewModel.cameraController!.value.isInitialized
                ? CameraPreview(viewModel.cameraController!)
                : const Center(child: CircularProgressIndicator()),
          ),
          ValueListenableBuilder<String?>(
            valueListenable: viewModel.startScanningCommand,
            builder: (context, barcode, _) {
              if (barcode != null) {
                Future.delayed(Duration.zero, () {
                  onBarcodeScanned(barcode);
                  context.pop();
                });
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
