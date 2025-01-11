import 'package:accollect/core/navigation/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/features/home/collection_tile.dart';
import 'package:accollect/features/home/home_view_model.dart';
import 'package:accollect/features/home/latest_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Consumer<HomeViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.errorMessage != null) {
                return Center(
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              final collections = viewModel.collections;
              final latestItems = viewModel.latestItems;

              final isCollectionEmpty = collections.isEmpty;

              return CustomScrollView(
                slivers: [
                  // 1) Header (User + Settings)
                  SliverToBoxAdapter(child: _buildHeader(context)),

                  // 2) "Collections" title row
                  SliverToBoxAdapter(child: _buildTitleRow(context)),
                  SliverToBoxAdapter(child: const SizedBox(height: 8)),

                  // 3) If collections are empty, show empty placeholder
                  if (isCollectionEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else ...[
                    // 4) SliverList of collections
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final collection = collections[index];
                          return CollectionTile(
                            collection: collection,
                            onTap: () {
                              context.pushWithParams(
                                AppRouter.collectionRoute,
                                [collection.id],
                              );
                            },
                          );
                        },
                        childCount: collections.length,
                      ),
                    ),

                    SliverToBoxAdapter(child: const SizedBox(height: 24)),
                      SliverToBoxAdapter(child: _buildLatestAddedTitle()),
                      SliverToBoxAdapter(child: const SizedBox(height: 8)),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final item = latestItems[index];
                            return LatestItemTile(
                              item: item,
                              onTap: () {
                                context.pushWithParams(
                                  AppRouter.itemDetailsRoute,
                                  [item.id],
                                );
                              },
                            );
                          },
                          childCount: latestItems.length,
                        ),
                      ),
                    ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------------
  // UI Sections
  // ----------------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);
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
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              context.push(AppRouter.createCollectionRoute);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Collections Yet',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start adding your collections by\n'
            'clicking the "Create" button above.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
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
