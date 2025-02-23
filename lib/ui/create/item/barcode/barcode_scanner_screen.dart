import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'barcode_scanner_view_model.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onProductFetched;

  const BarcodeScannerScreen({super.key, required this.onProductFetched});

  @override
  BarcodeScannerScreenState createState() => BarcodeScannerScreenState();
}

class BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late BarcodeScannerViewModel viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel = Provider.of<BarcodeScannerViewModel>(context, listen: false);
      viewModel.startScanningCommand.execute();
    });
  }

  @override
  void dispose() {
    viewModel.disposeScanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = context.watch<BarcodeScannerViewModel>();

    return Scaffold(
      appBar: CloseableAppBar(title: 'Scan Barcode'),
      body: Column(
        children: [
          Expanded(
            child: viewModel.cameraController != null &&
                    viewModel.cameraController!.value.isInitialized
                ? OrientationBuilder(
                    builder: (context, orientation) {
                      return orientation == Orientation.portrait
                          ? RotatedBox(
                              quarterTurns: 1,
                              child: CameraPreview(viewModel.cameraController!),
                            )
                          : CameraPreview(viewModel.cameraController!);
                    },
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: viewModel.scanBarcode,
            child: const Text("Scan Barcode"),
          ),
          ValueListenableBuilder<Map<String, dynamic>>(
            valueListenable: viewModel.fetchProductDetailsCommand,
            builder: (context, product, _) {
              if (product.isNotEmpty) {
                Future.delayed(Duration.zero, () {
                  widget.onProductFetched(product);
                  context.pop();
                });
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        product['title'] ?? "Unknown Item",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}
