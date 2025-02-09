import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/widgets/item_tile_portrait.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'item_library_view_model.dart';

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
        child: Column(
          children: [
            buildCategorySelector(
              context: context,
              viewModel: viewModel,
              onCategorySelected: viewModel.selectCategory,
            ),
            _buildSearchAndFilterRow(viewModel),
            Expanded(
              child: StreamBuilder<List<ItemUIModel>>(
                stream: viewModel.itemsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }
                  final items = snapshot.data ?? [];
                  return items.isEmpty
                      ? _buildEmptyState()
                      : _buildItemGrid(context, items);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: viewModel.isScrollingDown ? const Offset(0, 2) : Offset.zero,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.blueGrey[800],
          foregroundColor: Colors.white,
          onPressed: () => _navigateToAddNewItemScreen(context),
          icon: const Icon(Icons.add),
          label: const Text('Create Item'),
        ),
      ),
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

  Widget _buildItemGrid(BuildContext context, List<ItemUIModel> items) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        final viewModel = context.read<ItemLibraryViewModel>();
        if (scrollInfo is UserScrollNotification) {
          viewModel.setScrollDirection(
              scrollInfo.direction == ScrollDirection.reverse);
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ItemPortraitTile(
            item: item,
            onTap: () =>
                context.pushWithParams(AppRouter.itemDetailsRoute, [item.key]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddNewItemScreen(BuildContext context) {
    context.push<ItemUIModel>(AppRouter.addNewItemRoute);
  }
}

Widget buildCategorySelector({
  required BuildContext context,
  required ItemLibraryViewModel viewModel,
  required Function(String?) onCategorySelected,
}) {
  return ValueListenableBuilder<List<String>>(
    valueListenable: viewModel.fetchCategoriesCommand,
    builder: (context, categories, _) {
      final List<Widget> categoryButtons = [
        CategoryButton(
          label: "All",
          isSelected: viewModel.selectedCategory == null,
          onTap: () => onCategorySelected(null),
        ),
      ];

      if (viewModel.fetchCategoriesCommand.isExecuting.value) {
        categoryButtons.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      } else {
        categoryButtons.addAll(
          categories.map(
            (category) => CategoryButton(
              label: category,
              isSelected: viewModel.selectedCategory == category,
              onTap: () => onCategorySelected(category),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: categoryButtons),
      );
    },
  );
}

class CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
