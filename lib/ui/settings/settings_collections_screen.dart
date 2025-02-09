import 'package:accollect/ui/settings/settings_collections_viewmodel.dart';
import 'package:accollect/ui/widgets/loading_border_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionManagementScreen extends StatefulWidget {
  const CollectionManagementScreen({super.key});

  @override
  State<CollectionManagementScreen> createState() =>
      _CollectionManagementScreenState();
}

class _CollectionManagementScreenState
    extends State<CollectionManagementScreen> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CollectionManagementViewModel>();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Collection Management',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCategoryManagementSection(viewModel),
            const SizedBox(height: 24),
            _buildDangerZone(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryManagementSection(
      CollectionManagementViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manage Collection Categories',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        _buildAddCategoryField(viewModel),
        const SizedBox(height: 8),
        _buildCategoryList(viewModel),
      ],
    );
  }

  Widget _buildAddCategoryField(CollectionManagementViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _categoryController,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addCategory(viewModel),
            decoration: InputDecoration(
              hintText: 'Enter category name...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<bool>(
          valueListenable: viewModel.addCategoryCommand.isExecuting,
          builder: (context, isExecuting, child) {
            final isDisabled =
                _categoryController.text.trim().isEmpty || isExecuting;
            return LoadingBorderButton(
              title: 'Add',
              color: isDisabled ? Colors.grey[600]! : Colors.blueGrey[700]!,
              isExecuting: viewModel.addCategoryCommand.isExecuting,
              onPressed: isDisabled ? null : () => _addCategory(viewModel),
            );
          },
        ),
      ],
    );
  }

  void _addCategory(CollectionManagementViewModel viewModel) {
    final newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty) {
      viewModel.addCategoryCommand.execute(newCategory);
      _categoryController.clear();
    }
  }

  Widget _buildCategoryList(CollectionManagementViewModel viewModel) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: viewModel.fetchEditableCategoriesCommand,
      builder: (context, categories, child) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];

            return ValueListenableBuilder<bool>(
              valueListenable: viewModel.deleteCategoryCommand.isExecuting,
              builder: (context, isExecuting, child) {
                return ListTile(
                  title: Text(category,
                      style: const TextStyle(color: Colors.white)),
                  trailing: isExecuting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon:
                              const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () =>
                              viewModel.deleteCategoryCommand.execute(category),
                        ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDangerZone(CollectionManagementViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danger Zone',
          style: TextStyle(color: Colors.redAccent, fontSize: 18),
        ),
        const SizedBox(height: 8),
        LoadingBorderButton(
          title: 'Delete All Collections',
          color: Colors.redAccent,
          isExecuting: viewModel.deleteAllCollectionsCommand.isExecuting,
          onPressed: () =>
              _confirmDeleteAll(context, viewModel, isDeleteAllData: false),
        ),
        const SizedBox(height: 8),
        LoadingBorderButton(
          title: 'Delete All Data',
          color: Colors.red,
          isExecuting: viewModel.deleteAllDataCommand.isExecuting,
          onPressed: () =>
              _confirmDeleteAll(context, viewModel, isDeleteAllData: true),
        ),
      ],
    );
  }

  void _confirmDeleteAll(
      BuildContext context, CollectionManagementViewModel viewModel,
      {required bool isDeleteAllData}) {
    final title =
        isDeleteAllData ? 'Delete All Data' : 'Delete All Collections';
    final content = isDeleteAllData
        ? 'Are you sure you want to delete ALL data (collections and items)? This action is irreversible.'
        : 'Are you sure you want to delete all collections? This action is irreversible.';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Text(content, style: const TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isDeleteAllData) {
                  viewModel.deleteAllDataCommand.execute();
                } else {
                  viewModel.deleteAllCollectionsCommand.execute();
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
