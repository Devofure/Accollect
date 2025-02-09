import 'package:accollect/ui/settings/collection_settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryManagementBottomSheet extends StatefulWidget {
  const CategoryManagementBottomSheet({super.key});

  @override
  _CategoryManagementBottomSheetState createState() =>
      _CategoryManagementBottomSheetState();
}

class _CategoryManagementBottomSheetState
    extends State<CategoryManagementBottomSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CollectionManagementViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'New Category',
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.addCategory(_controller.text);
              Navigator.pop(context);
            },
            child: const Text('Add Category'),
          ),
        ],
      ),
    );
  }
}
