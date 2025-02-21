import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/widgets/collection_tile.dart';
import 'package:accollect/ui/widgets/common.dart';
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
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, viewModel),
            _buildTitleRow(context),
            Expanded(
              child: StreamBuilder<List<CollectionUIModel>>(
                stream: viewModel.collectionsStream,
                builder: (context, collectionSnapshot) {
                  if (!collectionSnapshot.hasData ||
                      collectionSnapshot.connectionState ==
                          ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (collectionSnapshot.hasError) {
                    return buildErrorState(collectionSnapshot.error.toString());
                  }
                  final collections = collectionSnapshot.data ?? [];

                  return StreamBuilder<Map<String, List<ItemUIModel>>>(
                    stream: viewModel.latestItemsStream,
                    builder: (context, latestItemsSnapshot) {
                      if (!latestItemsSnapshot.hasData ||
                          latestItemsSnapshot.connectionState ==
                              ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (latestItemsSnapshot.hasError) {
                        return buildErrorState(
                            latestItemsSnapshot.error.toString());
                      }
                      final groupedItems = latestItemsSnapshot.data ?? {};

                      return _buildContent(context, collections, groupedItems);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildContent(BuildContext context, List collections,
      Map<String, List<ItemUIModel>> groupedItems) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomScrollView(
        slivers: [
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
                      context.push(
                        AppRouter.collectionRoute,
                        extra: collection,
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
  }

  Widget _buildHeader(BuildContext context, HomeViewModel viewModel) {
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
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
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
  }
}
