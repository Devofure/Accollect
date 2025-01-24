import 'package:accollect/core/data/item_repository.dart';
import 'package:accollect/core/models/item_ui_model.dart';
import 'package:accollect/core/navigation/app_router.dart';
import 'package:accollect/core/widgets/empty_state.dart';
import 'package:accollect/core/widgets/item_tile.dart';
import 'package:accollect/features/item/add_or_select_item_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

enum ItemScreenMode { collection, library }

class AddOrSelectItemScreen extends StatelessWidget {
  final String? collectionKey; // Optional for library mode
  final String? collectionName; // Optional for library mode
  final IItemRepository repository;
  final ItemScreenMode mode;

  const AddOrSelectItemScreen({
    super.key,
    this.collectionKey,
    this.collectionName,
    required this.repository,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemViewModel(
        repository: repository,
        collectionKey: collectionKey,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            mode == ItemScreenMode.collection ? 'Add to Collection' : 'Library',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Consumer<ItemViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.errorMessage != null) {
                return _buildErrorState(viewModel.errorMessage!);
              }

              final availableItemsByCategory =
                  viewModel.getAvailableItemsGroupedByCategory();

              return Column(
                children: [
                  _buildHeader(context, viewModel),
                  if (availableItemsByCategory.isEmpty)
                    const Expanded(
                      child: EmptyStateWidget(
                        title: 'No available items',
                        description: 'Create a new item to get started.',
                      ),
                    )
                  else
                    _buildItemList(availableItemsByCategory, viewModel),
                  if (mode == ItemScreenMode.collection)
                    _buildActionButtons(context, viewModel),
                ],
              );
            },
          ),
        ),
        floatingActionButton: mode == ItemScreenMode.library
            ? Consumer<ItemViewModel>(
                builder: (context, viewModel, _) => FloatingActionButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  onPressed: () =>
                      _navigateToAddNewItemScreen(context, viewModel),
                  child: const Icon(Icons.add),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ItemViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mode == ItemScreenMode.collection)
            Text(
              collectionName ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (mode == ItemScreenMode.collection) const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Filter items...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: viewModel.filterItems,
                ),
              ),
              const SizedBox(width: 8),
              if (mode == ItemScreenMode.collection)
                ElevatedButton(
                  onPressed: () =>
                      _navigateToAddNewItemScreen(context, viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('New Item'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(
    Map<String, List<ItemUIModel>> itemsByCategory,
    ItemViewModel viewModel,
  ) {
    return Expanded(
      child: ListView.builder(
        itemCount: itemsByCategory.length,
        itemBuilder: (context, index) {
          final category = itemsByCategory.keys.elementAt(index);
          final items = itemsByCategory[category]!;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ItemTile(
                      item: item,
                      onTap: () {
                        if (mode == ItemScreenMode.collection) {
                          viewModel.toggleItemSelection(
                              item.key, !viewModel.isSelected(item.key));
                        }
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ItemViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go(AppRouter.homeRoute);
                }
              },
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                viewModel.addSelectedItems();
                Navigator.of(context).pop(true);
              },
              child: const Text('Add Items'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Text(
        errorMessage,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  void _navigateToAddNewItemScreen(
    BuildContext context,
    ItemViewModel viewModel,
  ) async {
    final newItem = await context.push<ItemUIModel>(AppRouter.addNewItemRoute);
    if (newItem != null) {
      await viewModel.createItem(newItem);
    }
  }
}
