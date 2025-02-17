import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepImagesWidget extends StatefulWidget {
  const StepImagesWidget({super.key});

  @override
  State<StepImagesWidget> createState() => _StepImagesWidgetState();
}

class _StepImagesWidgetState extends State<StepImagesWidget> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Item Images',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _pickImages(viewModel),
                  child: const Text('Pick Images'),
                ),
              ),
              const SizedBox(width: 12),
              if (viewModel.uploadedImages.isNotEmpty)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _clearAllImages(viewModel),
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildImageGrid(viewModel),
          const SizedBox(height: 8),
          const Text(
            'Tip: You can pick multiple images to showcase different angles.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  /// **📸 Image Grid Display**
  Widget _buildImageGrid(MultiStepCreateItemViewModel viewModel) {
    final images = viewModel.uploadedImages;
    if (images.isEmpty) {
      return const Center(
        child: Text(
          'No images selected',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (context, index) {
        final file = images[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.file(file, fit: BoxFit.cover),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(viewModel, index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// **📥 Pick Multiple Images**
  Future<void> _pickImages(MultiStepCreateItemViewModel viewModel) async {
    await viewModel.pickMultipleImages();
    setState(() {});
  }

  /// **❌ Remove a Single Image**
  void _removeImage(MultiStepCreateItemViewModel viewModel, int index) {
    viewModel.removeImageAt(index);
    setState(() {});
  }

  /// **🗑️ Clear All Images**
  void _clearAllImages(MultiStepCreateItemViewModel viewModel) {
    viewModel.clearAllImages();
    setState(() {});
  }
}
