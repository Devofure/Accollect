import 'package:accollect/data/category_repository.dart';
import 'package:accollect/ui/settings/settings_collections_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionManagementScreen extends StatelessWidget {
  const CollectionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CollectionManagementViewModel(
        categoryRepository: CategoryRepository(),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Collection Management',
              style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Consumer<CollectionManagementViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.errorMessage != null) {
                return Center(
                  child: Text(viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.redAccent)),
                );
              }

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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (categoryController.text.isNotEmpty) {
              viewModel.addCategory(categoryController.text.trim());
              categoryController.clear();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildCategoryList(CollectionManagementViewModel viewModel) {
    return Column(
      children: viewModel.categories.map((category) {
        return ListTile(
          title: Text(category, style: const TextStyle(color: Colors.white)),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              viewModel.deleteCategory(category);
            },
          ),
        );
      }).toList(),
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
          onPressed: () => _showConfirmationDialog(
            context,
            title: 'Delete All Collections',
            content:
                'Are you sure you want to delete all collections? This action cannot be undone.',
            onConfirm: () => viewModel.deleteAllCollections(),
          ),
        ),
        const SizedBox(height: 8),
        _buildDangerButton(
          context,
          title: 'Delete All Data',
          color: Colors.red,
          onPressed: () => _showConfirmationDialog(
            context,
            title: 'Delete All Data',
            content:
                'Are you sure you want to delete ALL data (collections and items)? This action cannot be undone.',
            onConfirm: () => viewModel.deleteAllData(),
          ),
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

  void _showConfirmationDialog(BuildContext context,
      {required String title,
      required String content,
      required VoidCallback onConfirm}) {
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
                onConfirm();
                Navigator.of(context).pop();
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
