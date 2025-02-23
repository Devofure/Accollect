import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'barcode_scanner_view_model.dart';

class BarcodeScannerScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onProductFetched;

  const BarcodeScannerScreen({super.key, required this.onProductFetched});

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
                  viewModel.fetchProductDetailsCommand.execute(barcode);
                });
              }
              return Container();
            },
          ),
          ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: viewModel.fetchProductDetailsCommand,
            builder: (context, product, _) {
              if (product.isNotEmpty) {
                Future.delayed(Duration.zero, () {
                  onProductFetched(product);
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