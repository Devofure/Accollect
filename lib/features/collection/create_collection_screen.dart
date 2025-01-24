import 'package:accollect/core/data/collection_repository.dart';
import 'package:accollect/core/navigation/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_collection_view_model.dart';

class CreateCollectionScreen extends StatelessWidget {
  final ICollectionRepository repository;

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
              radius: 50,
              backgroundImage: viewModel.uploadedImage != null
                  ? FileImage(viewModel.uploadedImage!) as ImageProvider
                  : null,
              child: viewModel.uploadedImage == null
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
  }

  Widget _buildButtons(
      CreateCollectionViewModel viewModel, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              if (viewModel.isLoading) return;
              final newCollectionKey = await viewModel.saveCollection();
              if (newCollectionKey != null && context.mounted) {
                context.goWithParams(
                    AppRouter.collectionRoute, [newCollectionKey]);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: viewModel.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Save Collection',
                    style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}