import 'package:accollect/core/app_router.dart';
import 'package:accollect/core/utils/extensions.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/widgets/item_tile_portrait.dart';
import 'package:flutter/material.dart';
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
            _buildCategorySelector(context, viewModel),
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

  Widget _buildCategorySelector(
      BuildContext context, ItemLibraryViewModel viewModel) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: viewModel.fetchCategoriesCommand,
      builder: (context, categories, _) {
        final List<Widget> categoryButtons = [
          _CategoryButton(
            label: "All",
            isSelected: viewModel.categoryFilter == null,
            onTap: () => viewModel.selectCategoryCommand.execute(null),
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
              (category) => _CategoryButton(
                label: category,
                isSelected: viewModel.categoryFilter == category,
                onTap: () => viewModel.selectCategoryCommand.execute(category),
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

  Widget _buildItemGrid(BuildContext context, List<ItemUIModel> items) {
    return NotificationListener<ScrollNotification>(
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

class _CategoryButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
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
