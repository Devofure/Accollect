import 'package:accollect/core/app_router.dart';
import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/widgets/collection_tile.dart';
import 'package:accollect/ui/widgets/common.dart';
import 'package:accollect/ui/widgets/empty_state.dart';
import 'package:accollect/ui/widgets/latest_added_item_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(BuildContext context, HomeViewModel viewModel) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: StreamBuilder<User?>(
        stream: viewModel.userChanges,
        builder: (context, snapshot) {
          final user = snapshot.data;
          final photoUrl = user?.photoURL;
          final displayName = user?.displayName ?? 'User';

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? Icon(Icons.person,
                            size: 24, color: theme.iconTheme.color)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    displayName,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.settings, color: theme.iconTheme.color),
                onPressed: () => context.push(AppRouter.settingsRoute),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Collections',
            style: theme.textTheme.headlineLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          FloatingActionButton.extended(
            onPressed: () => context.push(AppRouter.createCollectionRoute),
            label: const Text('Create'),
            icon: const Icon(Icons.add),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      backgroundColor: theme.colorScheme.secondary,
      foregroundColor: theme.colorScheme.onSecondary,
      elevation: 4,
      onPressed: () => context.push(AppRouter.itemLibraryRoute),
      child: const Icon(Icons.library_books),
    );
  }

  Widget _buildContent(BuildContext context, List collections,
      Map<String, List<ItemUIModel>> groupedItems) {
    final theme = Theme.of(context);

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
                    onTap: () => context.push(
                      AppRouter.collectionRoute,
                      extra: collection,
                    ),
                  );
                },
                childCount: collections.length,
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            SliverToBoxAdapter(child: _buildLatestAddedTitle(theme)),
            ..._buildLatestItemsList(groupedItems, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildLatestAddedTitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'New collected items',
        style:
            theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  static List<Widget> _buildLatestItemsList(
      Map<String, List<ItemUIModel>> groupedItems, ThemeData theme) {
    List<Widget> slivers = [];

    groupedItems.forEach((date, items) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              DateFormat('MMMM dd, yyyy').format(DateTime.parse(date)),
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
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
                  onTap: () =>
                      context.push(AppRouter.itemDetailsRoute, extra: item),
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
}
