import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
                  onProductFetched(product);
                  context.pop();
                });

                return Column(
                  children: [
                    CachedNetworkImage(
                      imageUrl: product['image'] ??
                          "https://your-app.com/default_image.png",
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image),
                    ),
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
