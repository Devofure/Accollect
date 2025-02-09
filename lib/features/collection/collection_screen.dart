import 'package:accollect/core/data/collection_repository.dart';
import 'package:accollect/core/data/item_repository.dart';
import 'package:accollect/core/navigation/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/core/widgets/item_tile_portrait.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/empty_state.dart';
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
      child: WillPopScope(
        onWillPop: () async {
          context.go(AppRouter.homeRoute);
          return false; // Prevent the default back navigation
        },
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              // Adjust the number of items per row
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio:
                                  0.75, // Adjust for image proportions
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ItemPortraitTile(
                                item: item,
                                isSelected: false,
                                // Adjust based on selection logic
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
              },
            ),
          ),
          floatingActionButton: Consumer<CollectionViewModel>(
            builder: (context, viewModel, _) {
              return FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  _navigateToAddOrSelectItemScreen(context, viewModel);
                },
                child: const Icon(Icons.add, color: Colors.black),
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToAddOrSelectItemScreen(
      BuildContext context, CollectionViewModel viewModel) async {
    // Wait for navigation to complete
    final result = await context.pushWithParams(
      AppRouter.addOrSelectItemRoute,
      [collectionKey, viewModel.collectionName],
    );
    if (result == true) {
      viewModel.refreshData(); // Trigger data reload
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
