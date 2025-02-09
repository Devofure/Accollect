import 'package:accollect/ui/settings/settings_collections_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionManagementScreen extends StatelessWidget {
  const CollectionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CollectionManagementViewModel(
        categoryRepository: context.read(),
      ),
      child: Scaffold(
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
          child: Consumer<CollectionManagementViewModel>(
            builder: (context, viewModel, _) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCategoryManagementSection(context, viewModel),
                  const SizedBox(height: 24),
                  _buildDangerZone(context, viewModel),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryManagementSection(
      BuildContext context, CollectionManagementViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manage Collection Categories',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 8),
        _buildAddCategoryField(context, viewModel),
        const SizedBox(height: 8),
        _buildCategoryList(viewModel),
      ],
    );
  }

  Widget _buildAddCategoryField(
      BuildContext context, CollectionManagementViewModel viewModel) {
    final TextEditingController categoryController = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: categoryController,
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
        ValueListenableBuilder<bool>(
          valueListenable: viewModel.addCategoryCommand.isExecuting,
          builder: (context, isExecuting, child) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: isExecuting
                  ? null
                  : () {
                      final newCategory = categoryController.text.trim();
                      if (newCategory.isNotEmpty) {
                        viewModel.addCategoryCommand.execute(newCategory);
                        categoryController.clear();
                      }
                    },
              child: isExecuting
                  ? const CircularProgressIndicator()
                  : const Text('Add'),
            );
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
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return ListTile(
              title:
                  Text(category, style: const TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () =>
                    viewModel.deleteCategoryCommand.execute(category),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDangerZone(
      BuildContext context, CollectionManagementViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Danger Zone',
          style: TextStyle(color: Colors.redAccent, fontSize: 18),
        ),
        const SizedBox(height: 8),
        _buildDangerButton(
          context,
          title: 'Delete All Collections',
          color: Colors.redAccent,
          onPressed: () => viewModel.deleteAllCollectionsCommand.execute(),
        ),
        const SizedBox(height: 8),
        _buildDangerButton(
          context,
          title: 'Delete All Data',
          color: Colors.red,
          onPressed: () => viewModel.deleteAllDataCommand.execute(),
        ),
      ],
    );
  }

  Widget _buildDangerButton(BuildContext context,
      {required String title,
      required Color color,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(title),
    );
  }
}
