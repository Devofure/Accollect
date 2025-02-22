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
                  HeaderText(
                    title: 'Create a Collection',
                    subtitle:
                        'Fill in the details to start your new collection.',
                  ),
                  const SizedBox(height: 24),
                  CustomTextInput(
                    label: 'Collection Name',
                    hint: 'Enter collection name',
                    onSaved: viewModel.setCollectionName,
                    validator: viewModel.validateCollectionName,
                  ),
                  const SizedBox(height: 16),
                  CustomTextInput(
                    label: 'Description',
                    hint: 'Enter collection description',
                    onSaved: viewModel.setDescription,
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<List<String>>(
                    valueListenable: viewModel.fetchCategoriesCommand,
                    builder: (context, categories, _) {
                      return GestureDetector(
                        onTap: () {
                          showCategoryPickerDialog(
                            context: context,
                            categories: categories,
                            selectedCategory: viewModel.selectedCategory,
                            onCategorySelected: viewModel.setCategory,
                            getPlaceholderPath: (category) =>
                                viewModel.placeholderAsset(category),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.outline),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                viewModel.placeholderAsset(
                                    viewModel.selectedCategory),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  viewModel.selectedCategory ??
                                      "Select a category",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color:
                                            viewModel.selectedCategory == null
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                      ),
                                ),
                              ),
                              Icon(Icons.arrow_drop_down,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
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
      bottomNavigationBar: BottomActionButton(
        title: 'Save Collection',
        isExecuting: viewModel.saveCollectionCommand.isExecuting,
        onPressed: () async {
          if (viewModel.formKey.currentState!.validate()) {
            viewModel.formKey.currentState!.save();
            await viewModel.saveCollectionCommand.executeWithFuture();
          } else {
            debugPrint("Form validation failed, blocking save.");
          }
        },
      ),
    );
  }
}
