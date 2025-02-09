import 'package:accollect/ui/item/add_new_item_viewmodel.dart';
import 'package:accollect/ui/widgets/loading_border_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNewItemScreen extends StatelessWidget {
  const AddNewItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddNewItemViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: viewModel.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTextInput(
                    label: 'Item Name',
                    hint: 'Enter item name',
                    onSaved: viewModel.setTitle,
                    validator: viewModel.validateTitle,
                  ),
                  const SizedBox(height: 16),
                  _buildTextInput(
                    label: 'Description',
                    hint: 'Enter item description',
                    onSaved: viewModel.setDescription,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(viewModel),
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
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Add New Item',
      style: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
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
            ),
          ),
          validator: validator,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(AddNewItemViewModel viewModel) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: viewModel.fetchCategoriesCommand,
      builder: (context, categories, _) {
        return DropdownButtonFormField<String>(
          value: categories.isNotEmpty ? viewModel.selectedCategory : null,
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: categories.map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: viewModel.setCategory,
        );
      },
    );
  }

  Widget _buildImageUpload(AddNewItemViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: viewModel.uploadedImage != null
            ? FileImage(viewModel.uploadedImage!)
            : null,
        child: viewModel.uploadedImage == null
            ? const Icon(Icons.photo_camera, color: Colors.white, size: 36)
            : null,
      ),
    );
  }

  Widget _buildButtons(AddNewItemViewModel viewModel, BuildContext context) {
    return LoadingBorderButton(
      title: 'Save Item',
      color: Colors.blue,
      isExecuting: viewModel.saveItemCommand.isExecuting,
      onPressed: () async {
        final newItemKey = await viewModel.saveItemCommand.executeWithFuture();
        if (newItemKey != null && context.mounted) {
          Navigator.pop(context, newItemKey);
        }
      },
    );
  }
}