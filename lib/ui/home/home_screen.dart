import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/widgets/collection_tile.dart';
import 'package:accollect/ui/widgets/empty_state.dart';
import 'package:accollect/ui/widgets/latest_added_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            final groupedItems = viewModel.groupedLatestItems;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  SliverToBoxAdapter(child: _buildTitleRow(context)),
                  SliverToBoxAdapter(child: const SizedBox(height: 8)),
                  if (collections.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateWidget(
                        title: 'No Collections Yet',
                        description: 'Start adding your collections.',
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
                    ..._buildLatestItemsList(groupedItems),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  static List<Widget> _buildLatestItemsList(
      Map<String, List<ItemUIModel>> groupedItems) {
    List<Widget> slivers = [];

    groupedItems.forEach((date, items) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              DateFormat('MMMM dd, yyyy').format(DateTime.parse(date)),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: LatestAddedItemTile(
                  item: item,
                  onTap: () {
                    context
                        .pushWithParams(AppRouter.itemDetailsRoute, [item.key]);
                  },
                ),
              );
            },
            childCount: items.length,
          ),
        ),
      );
    });

    return slivers;
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      onPressed: () {
        context.push(AppRouter.itemLibraryRoute);
      },
      child: const Icon(Icons.library_books),
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
        'New collected items',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Collections',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              // Different color for contrast
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              _navigateToCreateCollection(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToCreateCollection(BuildContext context) async {
    await context.push(AppRouter.createCollectionRoute);
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
    viewModel.retryFetchingData();
  }
}
