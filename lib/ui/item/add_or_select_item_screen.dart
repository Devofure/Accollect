import 'package:accollect/core/app_router.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/item/add_or_select_item_view_model.dart';
import 'package:accollect/ui/widgets/common.dart';
import 'package:accollect/ui/widgets/empty_state.dart';
import 'package:accollect/ui/widgets/item_tile_portrait.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AddOrSelectItemScreen extends StatelessWidget {
  final String? collectionKey;
  final String? collectionName;

  const AddOrSelectItemScreen({
    super.key,
    this.collectionKey,
    this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<AddOrSelectItemViewModel>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Add to Collection',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context, viewModel),
                Expanded(
                  child: StreamBuilder<List<ItemUIModel>>(
                    stream: viewModel.itemsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return buildErrorState(snapshot.error.toString());
                      }
                      final availableItems = snapshot.data ?? [];
                      if (availableItems.isEmpty) {
                        return const EmptyStateWidget(
                          title: 'No available items',
                          description: 'Create a new item to get started.',
                        );
                      }
                      return _buildItemList(viewModel, availableItems, theme);
                    },
                  ),
                ),
                _buildActionButtons(context, viewModel, theme),
              ],
            ),
            StreamBuilder<bool>(
              stream: viewModel.loadingStream,
              initialData: false,
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox.shrink();
              },
            ),
            StreamBuilder<String?>(
              stream: viewModel.errorStream,
              initialData: null,
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: theme.colorScheme.errorContainer,
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        snapshot.data!,
                        style: TextStyle(color: theme.colorScheme.onError),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AddOrSelectItemViewModel viewModel) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            collectionName ?? '',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Filter items...',
                    hintStyle:
                        TextStyle(color: theme.colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: viewModel.filterItemsCommand,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () =>
                    _navigateToAddNewItemScreen(context, viewModel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('New Item'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(AddOrSelectItemViewModel viewModel,
      List<ItemUIModel> items, ThemeData theme) {
    final availableItemsByCategory = _groupItemsByCategory(items);
    return ListView.builder(
      itemCount: availableItemsByCategory.length,
      itemBuilder: (context, index) {
        final category = availableItemsByCategory.keys.elementAt(index);
        final categoryItems = availableItemsByCategory[category]!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  category,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.75,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoryItems.length,
                itemBuilder: (context, itemIndex) {
                  final item = categoryItems[itemIndex];
                  final isSelected = viewModel.isSelected(item.key);
                  return ItemPortraitTile(
                    item: item,
                    isSelected: isSelected,
                    onTap: () => viewModel.toggleItemSelectionCommand(
                        item.key, !isSelected),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context,
      AddOrSelectItemViewModel viewModel, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                viewModel.addSelectedItemsCommand();
                Navigator.pop(context, true);
              },
              child: const Text('Add Items'),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddNewItemScreen(
      BuildContext context, AddOrSelectItemViewModel viewModel) async {
    await context.push<ItemUIModel>(AppRouter.createNewItemRoute);
  }

  Map<String, List<ItemUIModel>> _groupItemsByCategory(
      List<ItemUIModel> items) {
    final Map<String, List<ItemUIModel>> groupedItems = {};
    for (final item in items) {
      final category = item.category ?? "Uncategorized";
      groupedItems.putIfAbsent(category, () => []).add(item);
    }
    return groupedItems;
  }
}
