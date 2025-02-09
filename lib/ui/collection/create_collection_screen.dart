import 'dart:io';

import 'package:accollect/ui/widgets/loading_border_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'create_collection_view_model.dart';

class CreateCollectionScreen extends StatelessWidget {
  const CreateCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateCollectionViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: viewModel.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTextInput(
                    label: 'Collection Name',
                    hint: 'Enter collection name',
                    onSaved: viewModel.setCollectionName,
                    validator: viewModel.validateCollectionName,
                  ),
                  const SizedBox(height: 16),
                  _buildTextInput(
                    label: 'Description',
                    hint: 'Enter collection description',
                    onSaved: viewModel.setDescription,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownInput(viewModel),
                  const SizedBox(height: 24),
                  _buildImageUpload(viewModel),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(viewModel, context),
    );
  }

  Widget _buildBottomButton(CreateCollectionViewModel viewModel,
      BuildContext context,) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: LoadingBorderButton(
          title: 'Save Collection',
          color: Colors.blue,
          isExecuting: viewModel.saveCollectionCommand.isExecuting,
          onPressed: () async {
            await viewModel.saveCollectionCommand.executeWithFuture();
            if (context.mounted) {
              context.pop(true);
            }
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create a Collection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Fill in the details to start your new collection.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTextInput({
    required String label,
    required String hint,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
          ),
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildDropdownInput(CreateCollectionViewModel viewModel) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: viewModel.fetchCategoriesCommand,
      builder: (context, categories, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: categories.isNotEmpty ? categories.first : null,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: categories
                  .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: viewModel.setCategory,
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageUpload(CreateCollectionViewModel viewModel) {
    return ValueListenableBuilder<File?>(
      valueListenable: viewModel.uploadImageCommand,
      builder: (context, image, child) {
        return Center(
          child: GestureDetector(
            onTap: viewModel.uploadImageCommand.execute,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      image != null ? FileImage(image) as ImageProvider : null,
                  child: image == null
                      ? const Icon(Icons.photo_camera,
                          color: Colors.white, size: 36)
                      : null,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload Collection Image',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
