import 'dart:io';

import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/collection_repository.dart';
import 'package:accollect/ui/widgets/loading_border_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_collection_view_model.dart';

class CreateCollectionScreen extends StatelessWidget {
  final ICollectionRepository collectionRepository;
  final ICategoryRepository categoryRepository;

  const CreateCollectionScreen({
    super.key,
    required this.collectionRepository,
    required this.categoryRepository,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateCollectionViewModel(
        collectionRepository: collectionRepository,
        categoryRepository: categoryRepository,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<CreateCollectionViewModel>(
              builder: (context, viewModel, _) => Form(
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
                      const SizedBox(height: 24),
                      _buildButtons(viewModel, context),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
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

  Widget _buildButtons(CreateCollectionViewModel viewModel,
      BuildContext context,) {
    return LoadingBorderButton(
      title: 'Save Collection',
      color: Colors.blue,
      isExecuting: viewModel.saveCollectionCommand.isExecuting,
      onPressed: () => viewModel.saveCollectionCommand.execute(),
    );
  }
}
