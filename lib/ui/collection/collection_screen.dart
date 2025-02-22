import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/widgets/adaptive_header_widget.dart';
import 'package:accollect/ui/widgets/common.dart';
import 'package:accollect/ui/widgets/item_tile_portrait.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'collection_view_model.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<CollectionViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, theme, viewModel),
        ],
        body: _buildCollectionItems(viewModel, theme),
      ),
      floatingActionButton:
          _buildFloatingActionButton(context, viewModel, theme),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, ThemeData theme, CollectionViewModel viewModel) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      leading: BackButton(color: theme.colorScheme.onSurface),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
          onPressed: () {
            // Handle your "More" action here:
            showModalBottomSheet(
              context: context,
              builder: (context) => _buildMoreMenu(context, viewModel, theme),
            );
          },
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final currentHeight = constraints.biggest.height;
          final double minHeight = kToolbarHeight;
          final double maxHeight = 200;
          final double expandedPercentage =
              ((currentHeight - minHeight) / (maxHeight - minHeight))
                  .clamp(0.0, 1.0);
          return FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            centerTitle: false,
            titlePadding: const EdgeInsets.only(left: 48, bottom: 8),
            title: AdaptiveHeader(
              expandedPercentage: expandedPercentage,
              theme: theme,
              title: viewModel.collection.name,
              subTitle: viewModel.collection.category,
              imageUrl: viewModel.collection.imageUrl,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoreMenu(
    BuildContext context,
    CollectionViewModel viewModel,
    ThemeData theme,
  ) {
    return Wrap(
      children: [
        ListTile(
          leading: Icon(Icons.edit, color: theme.colorScheme.onSurface),
          title: const Text('Edit collection'),
          onTap: () {
            // ...
          },
        ),
        ListTile(
          leading: Icon(Icons.delete, color: theme.colorScheme.onSurface),
          title: const Text('Delete collection'),
          onTap: () {
            // ...
          },
        ),
      ],
    );
  }

  Widget _buildCollectionItems(CollectionViewModel viewModel, ThemeData theme) {
    return StreamBuilder<List<ItemUIModel>>(
      stream: viewModel.itemsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingGrid(theme);
        }
        if (snapshot.hasError) {
          return buildErrorState(snapshot.error.toString());
        }
        final items = snapshot.data ?? [];
        return items.isEmpty
            ? buildEmptyState(
                context: context,
                title: 'No items in your collection.',
                description: 'Start by adding your first item!',
              )
            : _buildItemGrid(items, viewModel, theme);
      },
    );
  }

  Widget _buildItemGrid(
      List<ItemUIModel> items, CollectionViewModel viewModel, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: viewModel.refreshData,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ItemPortraitTile(
            item: item,
            onTap: () => context.push(AppRouter.itemDetailsRoute, extra: item),
            menuOptions: [
              PopupMenuItem(
                value: 'remove',
                child: const Text('Remove from collection'),
                onTap: () =>
                    _confirmRemoveItem(context, viewModel, item.key, theme),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the loading grid
  Widget _buildLoadingGrid(ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }

  /// Builds the floating action button for adding items
  Widget _buildFloatingActionButton(
      BuildContext context, CollectionViewModel viewModel, ThemeData theme) {
    return FloatingActionButton.extended(
      backgroundColor: theme.colorScheme.primary,
      onPressed: () => _navigateToAddOrSelectItemScreen(context, viewModel),
      icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
      label: Text("Add Item",
          style: TextStyle(color: theme.colorScheme.onPrimary)),
    );
  }

  /// Confirmation dialog before removing an item
  void _confirmRemoveItem(BuildContext context, CollectionViewModel viewModel,
      String itemKey, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text("Remove Item", style: theme.textTheme.titleMedium),
        content: Text(
          "Are you sure you want to remove this item from the collection?",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: theme.colorScheme.primary)),
          ),
          TextButton(
            onPressed: () {
              viewModel.removeItemFromCollection(itemKey);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text("Remove",
                style: TextStyle(color: theme.colorScheme.onError)),
          ),
        ],
      ),
    );
  }

  void _navigateToAddOrSelectItemScreen(
      BuildContext context, CollectionViewModel viewModel) {
    context.pushWithParams(
      AppRouter.addOrSelectItemRoute,
      [viewModel.collection.key, viewModel.collection.name],
    );
  }
}
