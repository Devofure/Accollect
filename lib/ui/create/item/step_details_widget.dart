import 'package:accollect/domain/models/category_attributes_model.dart';
import 'package:accollect/ui/create/item/multi_step_create_item_view_model.dart';
import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StepDetailsWidget extends StatelessWidget {
  const StepDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MultiStepCreateItemViewModel>();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Form(
        key: viewModel.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextInput(
                label: 'Item Name',
                hint: 'Enter item name',
                onSaved: viewModel.setTitle,
                validator: viewModel.validateTitle,
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'Description',
                hint: 'Enter item description',
                onSaved: viewModel.setDescription,
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'Original Price',
                hint: 'Enter original price',
                onSaved: viewModel.setOriginalPrice,
              ),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'Notes',
                hint: 'Enter additional notes',
                onSaved: viewModel.setNotes,
              ),
              const SizedBox(height: 24),
              FutureBuilder<CategoryAttributesModel?>(
                future: viewModel.getCategoryAttributes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  final catAttributes = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Attributes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...catAttributes.attributes.map((attr) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CustomTextInput(
                            label: attr.label,
                            hint: attr.placeholder ?? '',
                            onSaved: (value) {
                              viewModel.setAdditionalAttribute(
                                  attr.field, value);
                            },
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Review all details before tapping "Finish". You can edit them later if needed.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
