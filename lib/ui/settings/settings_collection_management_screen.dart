import 'package:accollect/ui/settings/settings_collection_management_view_model.dart';
import 'package:accollect/ui/widgets/common.dart';
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
  final FocusNode _categoryFocusNode = FocusNode();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ValueNotifier<bool> _isInputNotEmpty = ValueNotifier<bool>(false);
  List<String> _categories = [];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CollectionManagementViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title:
            Text('Collection Management', style: theme.textTheme.headlineSmall),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
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
              return buildErrorState(snapshot.error.toString());
            }
            final userCategories = snapshot.data ?? [];

            if (_categories.length != userCategories.length) {
              _categories = List.from(userCategories);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _listKey.currentState?.setState(() {});
              });
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCategoryManagementSection(viewModel, theme),
                const SizedBox(height: 24),
                _buildCategoryList(viewModel, theme),
                const SizedBox(height: 24),
                _buildDangerZone(viewModel, theme),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryManagementSection(
      CollectionManagementViewModel viewModel, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Manage Collection Categories',
            style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildAddCategoryField(viewModel, theme),
      ],
    );
  }

  Widget _buildAddCategoryField(
      CollectionManagementViewModel viewModel, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _categoryController,
            focusNode: _categoryFocusNode,
            style: theme.textTheme.bodyLarge,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addCategory(viewModel),
            onChanged: (text) =>
                _isInputNotEmpty.value = text.trim().isNotEmpty,
            decoration: InputDecoration(
              hintText: 'Enter category name...',
              hintStyle:
                  theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<bool>(
          valueListenable: _isInputNotEmpty,
          builder: (context, isNotEmpty, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: viewModel.addCategoryCommand.isExecuting,
              builder: (context, isExecuting, child) {
                return LoadingBorderButton(
                  title: 'Add',
                  color: !isNotEmpty || isExecuting
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.primary,
                  isExecuting: viewModel.addCategoryCommand.isExecuting,
                  onPressed: !isNotEmpty || isExecuting
                      ? null
                      : () => _addCategory(viewModel),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryList(
      CollectionManagementViewModel viewModel, ThemeData theme) {
    return _categories.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text("No custom categories available",
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.hintColor)),
            ),
          )
        : AnimatedList(
            key: _listKey,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            initialItemCount: _categories.length,
            itemBuilder: (context, index, animation) {
              if (index < 0 || index >= _categories.length) {
                return const SizedBox.shrink();
              }
              final category = _categories[index];
              return SizeTransition(
                sizeFactor: animation,
                child: ListTile(
                  title: Text(category, style: theme.textTheme.bodyLarge),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: theme.colorScheme.error),
                    onPressed: () =>
                        _removeCategory(viewModel, category, index),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildDangerZone(
      CollectionManagementViewModel viewModel, ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: theme.colorScheme.onErrorContainer, size: 24),
                const SizedBox(width: 8),
                Text('Danger Zone',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.onErrorContainer)),
              ],
            ),
            const SizedBox(height: 12),
            _buildDangerButton(
                'Delete All Categories',
                'Removes all user-defined categories. Items remain intact.',
                Icons.category,
                viewModel.deleteAllCategoriesCommand,
                theme),
            const SizedBox(height: 8),
            _buildDangerButton(
                'Delete All Collections',
                'Removes all collections, but keeps individual items.',
                Icons.folder_open,
                viewModel.deleteAllCollectionsCommand,
                theme),
            const SizedBox(height: 8),
            _buildDangerButton(
                'Delete All Items',
                'Permanently deletes all items from your collections.',
                Icons.delete_forever,
                viewModel.deleteAllItemsCommand,
                theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerButton(String title, String description, IconData icon,
      Command<void, void> command, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(description,
            style:
                theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: Icon(icon, color: theme.colorScheme.onError),
            label: const Text('Delete',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () => command.execute(),
          ),
        ),
      ],
    );
  }

  void _addCategory(CollectionManagementViewModel viewModel) {
    final newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty) {
      viewModel.addCategoryCommand.execute(newCategory);
      _categoryController.clear();
      _categoryFocusNode.requestFocus(); // Keep focus after adding

      if (!_categories.contains(newCategory)) {
        _categories.insert(0, newCategory);
        _listKey.currentState?.insertItem(0);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "$newCategory" added!'),
          backgroundColor: Colors.green,
        ),
      );

      _isInputNotEmpty.value = false; // Reset button state
    }
  }

  void _removeCategory(
      CollectionManagementViewModel viewModel, String category, int index) {
    if (index < 0 || index >= _categories.length) return;

    viewModel.deleteCategoriesCommand.execute(category);

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        child: ListTile(
          title: Text(category, style: const TextStyle(color: Colors.white)),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );

    _categories.removeAt(index);

    if (_categories.isEmpty) {
      setState(() {}); // Ensure UI updates when list is empty
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Category "$category" deleted!'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
