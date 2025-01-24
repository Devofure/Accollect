import 'package:accollect/core/data/item_repository.dart';
import 'package:accollect/core/models/item_ui_model.dart';
import 'package:accollect/core/navigation/app_router.dart';
import 'package:accollect/core/widgets/empty_state.dart';
import 'package:accollect/core/widgets/item_tile.dart';
import 'package:accollect/features/item/item_library_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ItemLibraryScreen extends StatelessWidget {
  final IItemRepository repository;

  const ItemLibraryScreen({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItemLibraryViewModel(repository: repository),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Library', style: TextStyle(color: Colors.white)),
        ),
        body: SafeArea(
          child: Consumer<ItemLibraryViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.errorMessage != null) {
                return _buildErrorState(viewModel.errorMessage!);
              }

              final itemsByCategory =
                  viewModel.getAvailableItemsGroupedByCategory();

              return Column(
                children: [
                  _buildCategorySelector(viewModel),
                  _buildSearchAndFilterRow(viewModel),
                  if (itemsByCategory.isEmpty)
                    const Expanded(
                      child: EmptyStateWidget(
                        title: 'No items found',
                        description: 'Try adding or searching for an item.',
                      ),
                    )
                  else
                    _buildItemList(itemsByCategory),
                ],
              );
            },
          ),
        ),
        floatingActionButton: Consumer<ItemLibraryViewModel>(
          builder: (context, viewModel, _) => FloatingActionButton.extended(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            onPressed: () => _navigateToAddNewItemScreen(context, viewModel),
            icon: const Icon(Icons.add),
            label: const Text('Create Item'),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildCategorySelector(ItemLibraryViewModel viewModel) {
    final categories = ['All', 'Funko Pop', 'LEGO', 'Wine', 'Other'];
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = viewModel.selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ChoiceChip(
              label: Text(category),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              selected: isSelected,
              onSelected: (_) => viewModel.selectCategory(category),
              selectedColor: Colors.white,
              backgroundColor: Colors.grey[800],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterRow(ItemLibraryViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Filter...',
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
          DropdownButton<String>(
            value: viewModel.sortOrder,
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
            items: ['Year', 'Name']
                .map((order) => DropdownMenuItem(
                      value: order,
                      child: Text(order),
                    ))
                .toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                viewModel.sortItems(newValue);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(Map<String, List<ItemUIModel>> itemsByCategory) {
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
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ItemTile(item: item),
                  ),
                ),
              ],
            ),
          );
        },
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
    ItemLibraryViewModel viewModel,
  ) async {
    final newItem = await context.push<ItemUIModel>(AppRouter.addNewItemRoute);
    if (newItem != null) {
      await viewModel.createItem(newItem);
    }
  }
}
