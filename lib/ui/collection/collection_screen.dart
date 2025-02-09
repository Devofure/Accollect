import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) context.go(AppRouter.homeRoute);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: viewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : viewModel.errorMessage != null
                  ? _buildErrorState(viewModel)
                  : _buildContent(context, viewModel),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () => _navigateToAddOrSelectItemScreen(context, viewModel),
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildErrorState(CollectionViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(viewModel.errorMessage!,
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: viewModel.retryFetchingData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, CollectionViewModel viewModel) {
    final items = viewModel.items;
    final isCollectionEmpty = items.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCollectionHeader(viewModel),
          const SizedBox(height: 16),
          if (isCollectionEmpty)
            Expanded(
              child: Center(
                child: EmptyStateWidget(
                  title: 'No items in your collection.',
                  description: 'Add a new item to get started.',
                ),
              ),
            )
          else
            Expanded(
              child: GridView.builder(
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
                    isSelected: false,
                    onTap: () {
                      context.pushWithParams(
                          AppRouter.itemDetailsRoute, [item.key]);
                    },
                    menuOptions: [
                      PopupMenuItem(
                        value: 'remove',
                        child: const Text('Remove from collection'),
                        onTap: () {
                          viewModel.removeItemFromCollection(
                              item.key, item.collectionKey);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToAddOrSelectItemScreen(
      BuildContext context, CollectionViewModel viewModel) async {
    final result = await context.pushWithParams(
      AppRouter.addOrSelectItemRoute,
      [collectionKey, viewModel.collectionName],
    );
    if (result == true) {
      viewModel.refreshData();
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: const Text(
        'Collection',
        style: TextStyle(color: Colors.white),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          context.go(AppRouter.homeRoute);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {
            // TODO: Implement menu options
          },
        ),
      ],
    );
  }

  Widget _buildCollectionHeader(CollectionViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            viewModel.collectionName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        CircleAvatar(
          radius: 40,
          backgroundImage: viewModel.collectionImageUrl != null
              ? NetworkImage(viewModel.collectionImageUrl!)
              : null,
          child: viewModel.collectionImageUrl == null
              ? const Icon(Icons.image, color: Colors.white)
              : null,
        ),
      ],
    );
  }
}
