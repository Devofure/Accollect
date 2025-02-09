import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/item/item_library_view_model.dart';
import 'package:accollect/ui/widgets/categoy_selector_widget.dart';
import 'package:accollect/ui/widgets/item_tile_portrait.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ItemLibraryScreen extends StatelessWidget {
  const ItemLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ItemLibraryViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Library', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : viewModel.errorMessage != null
                ? _buildErrorState(context, viewModel.errorMessage!)
                : _buildContent(context, viewModel),
      ),
      floatingActionButton: AnimatedSlide(
        offset: viewModel.isScrollingDown ? const Offset(0, 2) : Offset.zero,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.blueGrey[800],
          foregroundColor: Colors.white,
          onPressed: () => _navigateToAddNewItemScreen(context, viewModel),
          icon: const Icon(Icons.add),
          label: const Text('Create Item'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent(BuildContext context, ItemLibraryViewModel viewModel) {
    final itemsByCategory = viewModel.getAvailableItemsGroupedByCategory();

    return Column(
      children: [
        buildCategorySelector(
          context: context,
          viewModel: viewModel,
          onCategorySelected: (category) {
            viewModel.selectCategory(category);
          },
        ),
        _buildSearchAndFilterRow(viewModel),
        if (itemsByCategory.isEmpty)
          _buildEmptyState(context)
        else
          _buildItemList(itemsByCategory),
      ],
    );
  }

  Widget _buildSearchAndFilterRow(ItemLibraryViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for items...',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[800],
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: viewModel.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: viewModel.clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: viewModel.filterItems,
      ),
    );
  }

  Widget _buildItemList(Map<String, List<ItemUIModel>> itemsByCategory) {
    return Expanded(
      child: ListView.builder(
        itemCount: itemsByCategory.length,
        itemBuilder: (context, index) {
          final category = itemsByCategory.keys.elementAt(index);
          final items = itemsByCategory[category]!;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildGridView(context, items),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(BuildContext context, List<ItemUIModel> items) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, itemIndex) {
        final item = items[itemIndex];

        return SizedBox(
          child: ItemPortraitTile(
            item: item,
            onTap: () {
              context.pushWithParams(AppRouter.itemDetailsRoute, [item.key]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sentiment_dissatisfied,
              color: Colors.grey, size: 64),
          const SizedBox(height: 8),
          const Text(
            "No items found",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToAddNewItemScreen(context, null),
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  void _navigateToAddNewItemScreen(
    BuildContext context,
    ItemLibraryViewModel? viewModel,
  ) async {
    final newItem = await context.push<ItemUIModel>(AppRouter.addNewItemRoute);
    if (newItem != null && viewModel != null) {
      await viewModel.createItem(newItem);
    }
  }
}
