import 'package:accollect/ui/settings/settings_collection_management_view_model.dart';
import 'package:accollect/ui/widgets/loading_border_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_command/flutter_command.dart';
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
        child: StreamBuilder<List<String>>(
          stream: viewModel.editableCategoriesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }
            final userCategories = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCategoryManagementSection(viewModel, userCategories),
                const SizedBox(height: 24),
                _buildDangerZone(viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(errorMessage, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryManagementSection(
      CollectionManagementViewModel viewModel, List<String> userCategories) {
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
        _buildCategoryList(viewModel, userCategories),
      ],
    );
  }

  Widget _buildAddCategoryField(CollectionManagementViewModel viewModel) {
    return StatefulBuilder(
      builder: (context, setStateLocal) {
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
                onChanged: (_) => setStateLocal(() {}),
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
      },
    );
  }

  void _addCategory(CollectionManagementViewModel viewModel) {
    final newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty) {
      viewModel.addCategoryCommand.execute(newCategory);
      _categoryController.clear();
      setState(() {});
    }
  }

  Widget _buildCategoryList(
      CollectionManagementViewModel viewModel, List<String> userCategories) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: userCategories.length,
      itemBuilder: (context, index) {
        final category = userCategories[index];

        return ValueListenableBuilder<bool>(
          valueListenable: viewModel.deleteCategoriesCommand.isExecuting,
          builder: (context, isExecuting, child) {
            return ListTile(
              title:
                  Text(category, style: const TextStyle(color: Colors.white)),
              trailing: isExecuting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () =>
                          viewModel.deleteCategoriesCommand.execute(category),
                    ),
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
        _buildDangerButton(
            'Delete All Categories', viewModel.deleteAllCategoriesCommand),
        _buildDangerButton(
            'Delete All Collections', viewModel.deleteAllCollectionsCommand),
        _buildDangerButton('Delete All Items', viewModel.deleteAllItemsCommand),
      ],
    );
  }

  Widget _buildDangerButton(String title, Command<void, void> command) {
    return LoadingBorderButton(
      title: title,
      color: Colors.red,
      isExecuting: command.isExecuting,
      onPressed: () => _confirmDeleteAction(context, title, command),
    );
  }

  void _confirmDeleteAction(
      BuildContext context, String title, Command<void, void> command) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: const Text('Are you sure? This action is irreversible.',
              style: TextStyle(color: Colors.grey)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                command.execute();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
