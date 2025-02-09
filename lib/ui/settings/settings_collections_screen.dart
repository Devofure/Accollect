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
            decoration: InputDecoration(
              hintText: 'New category',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        LoadingBorderButton(
          title: 'Add Category',
          color: Colors.blueGrey[700]!,
          isExecuting: viewModel.addCategoryCommand.isExecuting,
          onPressed: () {
            final newCategory = _categoryController.text.trim();
            if (newCategory.isNotEmpty) {
              viewModel.addCategoryCommand.execute(newCategory);
              _categoryController.clear();
            }
          },
        ),
      ],
    );
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
          color: Colors.red,
          isExecuting: viewModel.deleteAllCollectionsCommand.isExecuting,
          onPressed: () => viewModel.deleteAllCollectionsCommand.execute(),
        ),
        const SizedBox(height: 8),
        LoadingBorderButton(
          title: 'Delete All Data',
          color: Colors.red,
          isExecuting: viewModel.deleteAllDataCommand.isExecuting,
          onPressed: () => viewModel.deleteAllDataCommand.execute(),
        ),
      ],
    );
  }
}
