import 'package:accollect/core/navigation/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_collection_view_model.dart';
import 'data/create_collection_repository.dart';

class CreateCollectionScreen extends StatelessWidget {
  final ICreateCollectionRepository repository;

  const CreateCollectionScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CreateCollectionViewModel(repository: repository),
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
                      _buildSaveButton(viewModel, context),
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
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Start collecting',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Create a new collection by filling in the details below.',
          style: TextStyle(color: Colors.grey, fontSize: 14),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category',
            style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: viewModel.category,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
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
          items: viewModel.categories
              .map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          onChanged: viewModel.setCategory,
        ),
      ],
    );
  }

  Widget _buildImageUpload(CreateCollectionViewModel viewModel) {
    return Center(
      child: GestureDetector(
        onTap: viewModel.uploadImage,
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: viewModel.uploadedImage != null
                  ? NetworkImage(viewModel.uploadedImage!)
                  : null,
              child: viewModel.uploadedImage == null
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.photo_camera,
                          color: Colors.white, size: 32),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            const Text('Upload Image',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(
      CreateCollectionViewModel viewModel, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () async {
          final newCollectionKey = await viewModel.saveCollection();
          if (newCollectionKey != null && context.mounted) {
            context.goWithParams(
              AppRouter.collectionRoute,
              [newCollectionKey],
            );
          }
        },
        child: const Text('Save Collection'),
      ),
    );
  }
}
