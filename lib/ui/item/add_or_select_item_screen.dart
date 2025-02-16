import 'package:accollect/core/app_router.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/item/add_or_select_item_view_model.dart';
import 'package:accollect/ui/widgets/empty_state.dart';
import 'package:accollect/ui/widgets/item_tile_portrait.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AddOrSelectItemScreen extends StatelessWidget {
  final String? collectionKey;
  final String? collectionName;

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
        title: const Text('Add to Collection',
            style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context, viewModel),
                Expanded(
                  child: StreamBuilder<List<ItemUIModel>>(
                    stream: viewModel.itemsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _buildErrorState(snapshot.error.toString());
                      }
                      final availableItems = snapshot.data ?? [];
                      if (availableItems.isEmpty) {
                        return const EmptyStateWidget(
                          title: 'No available items',
                          description: 'Create a new item to get started.',
                        );
                      }
                      return _buildItemList(viewModel, availableItems);
                    },
                  ),
                ),
                _buildActionButtons(context, viewModel),
              ],
            ),
            StreamBuilder<bool>(
              stream: viewModel.loadingStream,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox.shrink();
              },
            ),
            StreamBuilder<String?>(
              stream: viewModel.errorStream,
              initialData: null,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.all(8),
                      child: Text(snapshot.data!,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
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
          Text(collectionName ?? '',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
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
                  onChanged: viewModel.filterItemsCommand,
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

  Widget _buildItemList(
      AddOrSelectItemViewModel viewModel, List<ItemUIModel> items) {
    final availableItemsByCategory = _groupItemsByCategory(items);
    return ListView.builder(
      itemCount: availableItemsByCategory.length,
      itemBuilder: (context, index) {
        final category = availableItemsByCategory.keys.elementAt(index);
        final categoryItems = availableItemsByCategory[category]!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(category,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
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
                itemCount: categoryItems.length,
                itemBuilder: (context, itemIndex) {
                  final item = categoryItems[itemIndex];
                  final isSelected = viewModel.isSelected(item.key);
                  return ItemPortraitTile(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => viewModel.toggleItemSelectionCommand(
                        item.key, !isSelected),
                  );
                },
              ),
            ],
          ),
        );
      },
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
              onPressed: () async {
                viewModel.addSelectedItemsCommand();
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(errorMessage,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center),
      ),
    );
  }

  void _navigateToAddNewItemScreen(
      BuildContext context, AddOrSelectItemViewModel viewModel) async {
    final newItem = await context.push<ItemUIModel>(AppRouter.addNewItemRoute);
    if (newItem != null) {
      await viewModel.createItemCommand(newItem);
    }
  }

  Map<String, List<ItemUIModel>> _groupItemsByCategory(
      List<ItemUIModel> items) {
    final Map<String, List<ItemUIModel>> groupedItems = {};
    for (final item in items) {
      final category = item.category;
      groupedItems.putIfAbsent(category, () => []).add(item);
    }
    return groupedItems;
  }
}
