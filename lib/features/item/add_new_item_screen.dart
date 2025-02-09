import 'dart:io';

import 'package:accollect/core/models/item_ui_model.dart';
import 'package:accollect/core/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class AddNewItemScreen extends StatefulWidget {
  /// Callback when the user completes creation of a new item.
  final Function(ItemUIModel) onCreateItem;

  const AddNewItemScreen({super.key, required this.onCreateItem});

  @override
  State<AddNewItemScreen> createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends State<AddNewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  String? _title;
  String? _description;
  String _selectedCategory = 'Other';
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _categories = ['Funko Pop', 'LEGO', 'Wine', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            // Ensures scroll in case fields exceed screen size / keyboard is open
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTextInput(
                    label: 'Item Name',
                    hint: 'Enter item name',
                    onSaved: (value) => _title = value,
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Please enter an item name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextInput(
                    label: 'Description',
                    hint: 'Enter item description',
                    onSaved: (value) => _description = value,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 24),
                  _buildImageUpload(),
                  const SizedBox(height: 24),
                  _buildButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI: AppBar
  // ---------------------------------------------------------------------------
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            // If there's nothing to pop, go back to Home
            context.go(AppRouter.homeRoute);
          }
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI: Header
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Add New Item',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Fill in the details to add a new item to your collection.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // UI: Text Field
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // UI: Category Dropdown
  // ---------------------------------------------------------------------------
  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
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
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
            }
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // UI: Image Upload
  // ---------------------------------------------------------------------------
  Widget _buildImageUpload() {
    return Center(
      child: GestureDetector(
        onTap: _isLoading ? null : _pickImage,
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  _imageFile != null ? FileImage(_imageFile!) : null,
              child: _imageFile == null
                  ? const Icon(
                      Icons.photo_camera,
                      color: Colors.white,
                      size: 36,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload Item Image',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI: Button Row (Cancel / Save)
  // ---------------------------------------------------------------------------
  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isLoading
                ? null
                : () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      context.go(AppRouter.homeRoute);
                    }
                  },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Save button
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLoading ? Colors.grey : Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _isLoading ? null : _saveItem,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Save Item',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Image picking from gallery
  // ---------------------------------------------------------------------------
  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Validate & Save the item
  // ---------------------------------------------------------------------------
  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      final newItem = ItemUIModel(
        key: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _title!,
        description: _description ?? '',
        category: _selectedCategory,
        addedOn: DateTime.now(),
        imageUrl: _imageFile?.path,
        // local path as example
        collectionKey: null,
      );

      debugPrint('New item created: ${newItem.title}');
      // Simulate time for a network save or DB write
      await Future.delayed(const Duration(seconds: 2));

      if (mounted && context.canPop()) {
        Navigator.pop(context, newItem);
      } else {
        debugPrint('Widget unmounted or no pop context; redirecting home.');
        if (mounted) {
          context.go(AppRouter.homeRoute);
        }
      }

      setState(() => _isLoading = false);
    }
  }
}
