import 'dart:io';

import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepImagesWidget extends StatefulWidget {
  const StepImagesWidget({super.key});

  @override
  State<StepImagesWidget> createState() => _StepImagesWidgetState();
}

class _StepImagesWidgetState extends State<StepImagesWidget> {
  static const int _maxSlots = 8;
  static const int _initialSlots = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Item Images',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        _buildImageGrid(viewModel, theme),
        const SizedBox(height: 8),
        Text(
          'Tap to upload an image. Long-press and drag to reorder.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid(
      MultiStepCreateItemViewModel viewModel, ThemeData theme) {
    final currentCount = viewModel.uploadedImages.length;
    final maxSlots = currentCount < _maxSlots ? currentCount + 1 : _maxSlots;
    final slots = (maxSlots < _initialSlots) ? _initialSlots : maxSlots;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final imageFile = (index < viewModel.uploadedImages.length)
            ? viewModel.uploadedImages[index]
            : null;

        return LayoutBuilder(
          builder: (context, constraints) {
            final tileSize = constraints.biggest;
            return LongPressDraggable<int>(
              data: index,
              feedback: Material(
                elevation: 6,
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: tileSize.width,
                    maxHeight: tileSize.height,
                  ),
                  child: Opacity(
                    opacity: 0.8,
                    child: _buildImageTile(viewModel, theme, imageFile, index),
                  ),
                ),
              ),
              childWhenDragging: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: DragTarget<int>(
                onMove: (DragTargetDetails<int> details) {
                  final oldIndex = details.data;
                  if (oldIndex < viewModel.uploadedImages.length &&
                      index < viewModel.uploadedImages.length &&
                      oldIndex != index) {
                    viewModel.reorderImages(oldIndex, index);
                    setState(() {});
                  }
                },
                onAcceptWithDetails: (DragTargetDetails<int> details) {
                  setState(() {});
                },
                builder: (context, candidateData, rejectedData) {
                  final isHighlighted = candidateData.isNotEmpty;
                  return Container(
                    decoration: BoxDecoration(
                      border: isHighlighted
                          ? Border.all(
                              color: theme.colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: _buildImageTile(viewModel, theme, imageFile, index),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageTile(
    MultiStepCreateItemViewModel viewModel,
    ThemeData theme,
    File? imageFile,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _pickImage(viewModel, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          image: (imageFile != null)
              ? DecorationImage(
                  image: FileImage(imageFile),
                  fit: BoxFit.cover,
                )
              : null,
          border: Border.all(
            color: (imageFile == null)
                ? theme.colorScheme.onSurfaceVariant
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            if (imageFile == null)
              Center(
                child: Icon(
                  Icons.add_photo_alternate,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 32,
                ),
              ),
            if (imageFile != null)
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => _removeImage(viewModel, index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.close,
                      color: theme.colorScheme.onPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(
      MultiStepCreateItemViewModel viewModel, int index) async {
    if (index < viewModel.uploadedImages.length) {
      await viewModel.pickImage(index);
    } else {
      await viewModel.pickMultipleImages();
    }
    setState(() {});
  }

  void _removeImage(MultiStepCreateItemViewModel viewModel, int index) {
    viewModel.removeImageAt(index);
    setState(() {});
  }
}
