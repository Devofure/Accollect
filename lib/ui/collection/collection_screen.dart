import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/widgets/common.dart';
import 'package:accollect/ui/widgets/item_tile_portrait.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'collection_view_model.dart';

class CollectionScreen extends StatelessWidget {
  final String collectionKey;

  const CollectionScreen({super.key, required this.collectionKey});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CollectionViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildCollectionHeader(viewModel),
            Expanded(
              child: StreamBuilder<List<ItemUIModel>>(
                stream: viewModel.itemsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingGrid();
                  }
                  if (snapshot.hasError) {
                    return buildErrorState(snapshot.error.toString());
                  }
                  final items = snapshot.data ?? [];
                  return items.isEmpty
                      ? buildEmptyState(
                          title: 'No items in your collection.',
                          description: 'Start by adding your first item!',
                        )
                      : _buildItemGrid(items, viewModel);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _navigateToAddOrSelectItemScreen(context, viewModel),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Item", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCollectionHeader(CollectionViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          circularImageWidget(viewModel.collectionImageUrl, size: 90),
          // ✅ Reused
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewModel.collectionName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.category ?? "No category",
                  style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid(
      List<ItemUIModel> items, CollectionViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: () async {
        viewModel.refreshData();
      },
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ItemPortraitTile(
            item: item,
            onTap: () {
              context.pushWithParams(AppRouter.itemDetailsRoute, [item.key]);
            },
            menuOptions: [
              PopupMenuItem(
                value: 'remove',
                child: const Text('Remove from collection'),
                onTap: () {
                  _confirmRemoveItem(context, viewModel, item.key);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  void _confirmRemoveItem(
      BuildContext context, CollectionViewModel viewModel, String itemKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text("Remove Item", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to remove this item from the collection?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              viewModel.removeItemFromCollection(itemKey);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToAddOrSelectItemScreen(
      BuildContext context, CollectionViewModel viewModel) {
    context.pushWithParams(AppRouter.addOrSelectItemRoute,
        [collectionKey, viewModel.collectionName]);
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: const Text('Collection', style: TextStyle(color: Colors.white)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          context.go(AppRouter.homeRoute);
        },
      ),
    );
  }
}
