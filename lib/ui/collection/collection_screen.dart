import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
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
      expandedHeight: 150,
      leading: BackButton(color: theme.colorScheme.onSurface),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
          onPressed: () => _showMoreMenu(context, viewModel, theme),
        ),
      ],
      flexibleSpace: collectionHeader(viewModel, theme),
    );
  }

  Widget collectionHeader(CollectionViewModel viewModel, ThemeData theme) {
    final placeholderPath =
        viewModel.placeholderAsset(viewModel.collection.category);
    return LayoutBuilder(
        builder: (context, constraints) => FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 42, bottom: 4, top: 4),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  circularImageWidget(
                    viewModel.collection.imageUrl,
                    size: 45,
                    placeholderAsset: placeholderPath,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.collection.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (viewModel.collection.category?.isNotEmpty == true)
                        Text(
                          viewModel.collection.category!,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(color: theme.colorScheme.onSurface),
                        ),
                    ],
                  ),
                ],
              ),
            ));
  }

  void _showMoreMenu(
      BuildContext context, CollectionViewModel viewModel, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.edit, color: theme.colorScheme.onSurface),
            title: const Text('Edit collection'),
            onTap: () {
              viewModel.editCollectionCommand.execute();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: theme.colorScheme.onSurface),
            title: const Text('Delete collection'),
            onTap: () {
              viewModel.deleteCollectionCommand.execute();
            },
          ),
        ],
      ),
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
          );
        },
      ),
    );
  }

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

  void _navigateToAddOrSelectItemScreen(
      BuildContext context, CollectionViewModel viewModel) {
    context.pushWithParams(
      AppRouter.addOrSelectItemRoute,
      [viewModel.collection.key, viewModel.collection.name],
    );
  }
}
