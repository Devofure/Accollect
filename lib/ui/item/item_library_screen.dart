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
        child: ValueListenableBuilder<List<ItemUIModel>>(
          valueListenable: viewModel.fetchLastAddedItemsCommand,
          builder: (context, items, _) {
            if (viewModel.fetchLastAddedItemsCommand.isExecuting.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.fetchLastAddedItemsCommand.value.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildContent(context, viewModel, items);
          },
        ),
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

  Widget _buildContent(BuildContext context, ItemLibraryViewModel viewModel,
      List<ItemUIModel> items) {
    return Column(
      children: [
        buildCategorySelector(
          context: context,
          viewModel: viewModel,
          onCategorySelected: viewModel.selectCategory,
        ),
        _buildSearchAndFilterRow(viewModel),
        Expanded(child: _buildItemList(items)),
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
                  onPressed: () => viewModel.filterItemsCommand.execute(""),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: viewModel.filterItemsCommand.execute,
      ),
    );
  }

  Widget _buildItemList(List<ItemUIModel> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied, color: Colors.grey, size: 64),
          SizedBox(height: 8),
          Text(
            "No items found",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  void _navigateToAddNewItemScreen(
    BuildContext context,
    ItemLibraryViewModel viewModel,
  ) async {
    context.push<ItemUIModel>(AppRouter.addNewItemRoute);
  }
}
