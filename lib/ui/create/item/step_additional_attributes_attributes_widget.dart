import 'package:accollect/domain/models/category_attributes_model.dart';
import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepAdditionalAttributesWidget extends StatelessWidget {
  const StepAdditionalAttributesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MultiStepCreateItemViewModel>();

    return FutureBuilder<CategoryAttributesModel?>(
      future: viewModel.getCategoryAttributes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text(
            'No additional attributes for this category.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          );
        }

        final attributes = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Attributes',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...attributes.attributes.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: entry.label,
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) {
                    viewModel.setAdditionalAttribute(entry.field, value);
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
