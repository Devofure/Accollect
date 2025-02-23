import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepOnlineImagesWidget extends StatelessWidget {
  const StepOnlineImagesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Online Images',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (viewModel.onlineImages == null || viewModel.onlineImages!.isEmpty)
          const Text("No online images found.")
        else
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: viewModel.onlineImages!.length,
            itemBuilder: (context, index) {
              final imageUrl = viewModel.onlineImages![index];
              return Stack(
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {
                        viewModel.removeOnlineImage(index);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}
