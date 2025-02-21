import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/widgets/common.dart';
import 'package:accollect/ui/widgets/empty_state.dart';
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
                      ? _buildEmptyState(context)
                      : _buildItemGrid(items, viewModel);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.white,
        onPressed: () => _navigateToAddOrSelectItemScreen(context, viewModel),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text("Add Item", style: TextStyle(color: Colors.black)),
      ),
    );
  }

  Widget _buildCollectionHeader(CollectionViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.black,
        boxShadow: [BoxShadow(color: Colors.white10, blurRadius: 4)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: viewModel.collectionImageUrl != null
                ? NetworkImage(viewModel.collectionImageUrl!)
                : null,
            child: viewModel.collectionImageUrl == null
                ? const Icon(Icons.image, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              viewModel.collectionName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
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
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
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

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStateWidget(
      title: 'No items in your collection.',
      description: 'Start by adding your first item!',
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
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
        title: const Text("Remove Item"),
        content: const Text(
            "Are you sure you want to remove this item from the collection?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              viewModel.removeItemFromCollection(itemKey);
              Navigator.pop(context);
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToAddOrSelectItemScreen(BuildContext context,
      CollectionViewModel viewModel) {
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
