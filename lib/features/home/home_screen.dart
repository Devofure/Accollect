// lib/features/home/home_screen.dart

import 'package:accollect/core/navigation/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/features/collection/collection_model.dart';
import 'package:accollect/features/collection/item_model.dart';
import 'package:accollect/features/home/collection_tile.dart';
import 'package:accollect/features/home/latest_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final String? photoUrl;
  final List<CollectionModel> collections;
  final List<ItemModel> latestItems;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.photoUrl,
    required this.collections,
    required this.latestItems,
  });

  @override
  Widget build(BuildContext context) {
    final isCollectionEmpty = collections.isEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1) Header (User + Settings)
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),

            // 2) "Collections" title row
            SliverToBoxAdapter(child: _buildTitleRow(context)),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),

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
                        context.goWithParams(
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
              SliverToBoxAdapter(child: const SizedBox(height: 8)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = latestItems[index];
                    return LatestItemTile(
                      item: item,
                      onTap: () {
                        // Example: pass an item key/ID to item details
                        context.go('${AppRouter.itemDetailsRoute}/${item.key}');
                      },
                    );
                  },
                  childCount: latestItems.length,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------------
  // UI Sections
  // ----------------------------------------------------------------------------

  /// Top user row: user avatar + name, and settings icon
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Display the user's profile picture if available, otherwise show a default icon
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[700],
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
                child: photoUrl == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      )
                    : null, // Show default icon if no photoURL
              ),
              const SizedBox(width: 8),
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              context.push(AppRouter.settingsRoute); // Use push instead of go
            },
          )
        ],
      ),
    );
  }

  /// "Collections" title + "Create" button
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
              fontSize: 24,
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
              context.go(AppRouter.createCollectionRoute);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  /// Empty state if there are no collections
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
            child: const Center(
              child: Icon(
                Icons.inbox,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Collections Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start adding your collections by\n'
            'clicking the "Create" button above.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Title for "Latest Added Item" section
  Widget _buildLatestAddedTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Latest Added Item',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
