import 'package:accollect/core/app_router.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/item/add_or_select_item_view_model.dart';
import 'package:accollect/ui/widgets/empty_state.dart';
import 'package:accollect/ui/widgets/item_tile_portrait.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AddOrSelectItemScreen extends StatelessWidget {
  final String? collectionKey; // Optional for library mode
  final String? collectionName; // Optional for library mode

  const AddOrSelectItemScreen({
    super.key,
    this.collectionKey,
    this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddOrSelectItemViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Add to Collection',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, viewModel),
            if (viewModel.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (viewModel.errorMessage != null)
              _buildErrorState(viewModel.errorMessage!)
            else
              _buildItemList(viewModel),
            _buildActionButtons(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AddOrSelectItemViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            collectionName ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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

  Widget _buildItemList(AddOrSelectItemViewModel viewModel) {
    final availableItemsByCategory =
        viewModel.getAvailableItemsGroupedByCategory();

    if (availableItemsByCategory.isEmpty) {
      return const Expanded(
        child: EmptyStateWidget(
          title: 'No available items',
          description: 'Create a new item to get started.',
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: availableItemsByCategory.length,
        itemBuilder: (context, index) {
          final category = availableItemsByCategory.keys.elementAt(index);
          final items = availableItemsByCategory[category]!;

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
                GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.75,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, itemIndex) {
                    final item = items[itemIndex];
                    final isSelected = viewModel.isSelected(item.key);

                    return ItemPortraitTile(
                      item: item,
                      isSelected: isSelected,
                      onTap: () =>
                          viewModel.toggleItemSelection(item.key, !isSelected),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, AddOrSelectItemViewModel viewModel) {
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
              onPressed: () => Navigator.pop(context),
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
                Navigator.pop(context, true);
              },
              child: const Text('Add Items'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Expanded(
      child: Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _navigateToAddNewItemScreen(
      BuildContext context, AddOrSelectItemViewModel viewModel) async {
    final newItem = await context.push<ItemUIModel>(AppRouter.addNewItemRoute);
    if (newItem != null) {
      await viewModel.createItem(newItem);
    }
  }
}