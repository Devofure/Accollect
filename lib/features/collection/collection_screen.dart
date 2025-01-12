import 'package:accollect/core/data/collection_repository.dart';
import 'package:accollect/core/data/item_repository.dart';
import 'package:accollect/core/navigation/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/empty_state.dart';
import '../../core/widgets/item_tile.dart';
import 'collection_view_model.dart';

class CollectionScreen extends StatelessWidget {
  final ICollectionRepository collectionRepository;
  final IItemRepository itemRepository;
  final String collectionKey;

  const CollectionScreen({
    super.key,
    required this.collectionKey,
    required this.collectionRepository,
    required this.itemRepository,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CollectionViewModel(
        collectionKey: collectionKey,
        collectionRepository: collectionRepository,
        itemRepository: itemRepository,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Consumer<CollectionViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: viewModel.retryFetchingData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final items = viewModel.items;
              final isCollectionEmpty = items.isEmpty;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCollectionHeader(viewModel),
                    const SizedBox(height: 16),
                    if (isCollectionEmpty)
                      EmptyStateWidget(
                        message: 'No items in your collection.',
                        actionMessage: 'Add a new item to get started.',
                        onPressed: () {
                          // TODO: Navigate to add item screen
                        },
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return ItemTile(
                              item: item,
                              onTap: () {
                                context.pushWithParams(
                                    AppRouter.itemDetailsRoute, [
                                  item.key,
                                ]);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: Consumer<CollectionViewModel>(
          builder: (context, viewModel, _) {
            return FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                context.pushWithParams(
                  AppRouter.addOrSelectItemRoute,
                  [collectionKey, viewModel.collectionName],
                );
              },
              child: const Icon(Icons.add, color: Colors.black),
            );
          },
        ),
      ),
    );
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
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(AppRouter.homeRoute);
          }
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
