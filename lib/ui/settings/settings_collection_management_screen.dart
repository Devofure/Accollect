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
  final FocusNode _categoryFocusNode = FocusNode();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ValueNotifier<bool> _isInputNotEmpty = ValueNotifier<bool>(false);
  List<String> _categories = [];

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

            // Avoid unnecessary rebuilds when list is the same
            if (_categories.length != userCategories.length) {
              _categories = List.from(userCategories);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _listKey.currentState?.setState(() {});
              });
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCategoryManagementSection(viewModel),
                const SizedBox(height: 24),
                _buildCategoryList(viewModel),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.redAccent),
          textAlign: TextAlign.center,
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
      ],
    );
  }

  Widget _buildAddCategoryField(CollectionManagementViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _categoryController,
            focusNode: _categoryFocusNode,
            style: const TextStyle(color: Colors.white),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _addCategory(viewModel),
            onChanged: (text) =>
                _isInputNotEmpty.value = text.trim().isNotEmpty,
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
                      ? Colors.grey[600]!
                      : Colors.blueGrey[700]!,
                  isExecuting: viewModel.addCategoryCommand.isExecuting,
                  onPressed: !isNotEmpty || isExecuting
                      ? null
                      : () => _addCategory(viewModel),
                );
              },
            );
          },
        )
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

  Widget _buildCategoryList(CollectionManagementViewModel viewModel) {
    return _categories.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                "No categories available",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
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
                  title: Text(category,
                      style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () =>
                        _removeCategory(viewModel, category, index),
                  ),
                ),
              );
            },
          );
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

  Widget _buildDangerZone(CollectionManagementViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.white24, height: 24),
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
        final TextEditingController _confirmController =
            TextEditingController();

        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Type "DELETE" to confirm.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                if (_confirmController.text.trim().toUpperCase() == "DELETE") {
                  Navigator.of(context).pop();
                  command.execute();
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
