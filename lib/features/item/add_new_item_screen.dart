import 'package:accollect/core/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/item_ui_model.dart';

class AddNewItemScreen extends StatefulWidget {
  final Function(ItemUIModel) onCreateItem;

  const AddNewItemScreen({super.key, required this.onCreateItem});

  @override
  State<AddNewItemScreen> createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends State<AddNewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            const Text('Add New Item', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextInput(
                  label: 'Title',
                  onSaved: (value) => _title = value,
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a title'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextInput(
                  label: 'Description',
                  onSaved: (value) => _description = value,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required String label,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSaved: onSaved,
          validator: validator,
        ),
      ],
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newItem = ItemUIModel(
        key: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _title!,
        description: _description ?? '',
        category: '',
        addedOn: DateTime.now(),
        imageUrl: null,
        collectionKey: null,
      );

      debugPrint('New item created: ${newItem.title}');
      if (context.canPop()) {
        context.pop(newItem);
      } else {
        debugPrint('Navigation stack empty. Redirecting to home.');
        context.go(AppRouter.homeRoute);
      }
    }
  }
}
