import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/core/widgets/empty_state.dart';
import 'package:accollect/core/widgets/item_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/navigation/app_router.dart';
import '../../core/widgets/collection_tile.dart';
import 'home_repository.dart';
import 'home_view_model.dart';

class HomeScreen extends StatelessWidget {
  final IHomeRepository repository;

  const HomeScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(repository: repository),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Consumer<HomeViewModel>(
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

              final collections = viewModel.collections;
              final latestItems = viewModel.latestItems;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(context)),
                    SliverToBoxAdapter(child: const SizedBox(height: 8)),
                    if (collections.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyStateWidget(
                          message: 'No Collections Yet',
                          actionMessage: 'Start adding your collections.',
                          onPressed: () {
                            context.push(AppRouter.createCollectionRoute);
                          },
                        ),
                      )
                    else ...[
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final collection = collections[index];
                            return CollectionTile(
                              collection: collection,
                              onTap: () {
                                context.pushWithParams(
                                  AppRouter.collectionRoute,
                                  [collection.key],
                                );
                              },
                            );
                          },
                          childCount: collections.length,
                        ),
                      ),
                      SliverToBoxAdapter(child: const SizedBox(height: 24)),
                      SliverToBoxAdapter(child: _buildLatestAddedTitle()),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = latestItems[index];
                            return ItemTile(
                              item: item,
                              onTap: () {
                                context.pushWithParams(
                                  AppRouter.itemDetailsRoute,
                                  [item.key],
                                );
                              },
                            );
                          },
                          childCount: latestItems.length,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, _) {
        final currentUser = viewModel.currentUser;
        final photoUrl = currentUser?.photoURL;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[700],
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentUser?.displayName ?? 'User',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  context.push(AppRouter.settingsRoute);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLatestAddedTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Latest Added Items',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
