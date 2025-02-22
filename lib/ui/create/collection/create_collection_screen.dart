import 'dart:io';

import 'package:accollect/ui/widgets/create_common_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_collection_view_model.dart';

class CreateCollectionScreen extends StatelessWidget {
  const CreateCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<CreateCollectionViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: const CloseableAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: viewModel.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  HeaderText(
                    title: 'Create a Collection',
                    subtitle:
                        'Fill in the details to start your new collection.',
                  ),
                  const SizedBox(height: 24),

                  // Collection Name Input
                  CustomTextInput(
                    label: 'Collection Name',
                    hint: 'Enter collection name',
                    onSaved: viewModel.setCollectionName,
                    validator: viewModel.validateCollectionName,
                  ),
                  const SizedBox(height: 16),

                  // Description Input
                  CustomTextInput(
                    label: 'Description',
                    hint: 'Enter collection description',
                    onSaved: viewModel.setDescription,
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  ValueListenableBuilder<List<String>>(
                    valueListenable: viewModel.fetchCategoriesCommand,
                    builder: (context, categories, _) {
                      return CategoryDropdownField(
                        categories: categories,
                        selected:
                            categories.isNotEmpty ? categories.first : null,
                        onChanged: viewModel.setCategory,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Image Upload
                  ValueListenableBuilder<File?>(
                    valueListenable: viewModel.uploadImageCommand,
                    builder: (context, image, _) {
                      return ImageUploadField(
                        image: image,
                        onTap: viewModel.uploadImageCommand.execute,
                        label: 'Upload Collection Image',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // Save Button
      bottomNavigationBar: BottomActionButton(
        title: 'Save Collection',
        isExecuting: viewModel.saveCollectionCommand.isExecuting,
        onPressed: () async {
          await viewModel.saveCollectionCommand.executeWithFuture();
        },
      ),
    );
  }
}
