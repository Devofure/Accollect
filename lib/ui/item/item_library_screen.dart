import 'package:accollect/core/app_router.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:accollect/ui/widgets/common.dart';
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
            _buildCategoryDropdown(context, viewModel),
            Expanded(
              child: StreamBuilder<List<ItemUIModel>>(
                stream: viewModel.itemsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }
                  if (snapshot.hasError) {
                    return buildErrorState(snapshot.error.toString());
                  }
                  final items = snapshot.data ?? [];
                  return items.isEmpty
                      ? buildEmptyState(
                          title: 'No items found',
                          description: 'Create a new item to get started',
                          onActionPressed: () =>
                              _navigateToAddNewItemScreen(context),
                          actionLabel: 'Create Item',
                        )
                      : _buildItemGrid(context, items, viewModel);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(viewModel, context),
    );
  }

  Widget _buildCategoryDropdown(
      BuildContext context, ItemLibraryViewModel viewModel) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: viewModel.fetchCategoriesCommand,
      builder: (context, categories, _) {
        final uniqueCategories = ['All Items', ...categories.toSet()];

        return Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            value: viewModel.categoryFilter ?? "All Items",
            items: uniqueCategories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child:
                    Text(category, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (newCategory) {
              viewModel.selectCategoryCommand
                  .execute(newCategory == "All Items" ? null : newCategory);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            dropdownColor: Colors.grey[900],
          ),
        );
      },
    );
  }

  Widget _buildItemGrid(BuildContext context, List<ItemUIModel> items,
      ItemLibraryViewModel viewModel) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is UserScrollNotification) {
          if (scrollNotification.direction == ScrollDirection.reverse) {
            viewModel.setScrollDirection(true);
          } else if (scrollNotification.direction == ScrollDirection.forward) {
            viewModel.setScrollDirection(false);
          }
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
                  context.push(AppRouter.itemDetailsRoute, extra: item));
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          const Text("Loading items...", style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(
      ItemLibraryViewModel viewModel, BuildContext context) {
    return AnimatedSlide(
      offset: viewModel.isScrollingDown ? const Offset(0, 2) : Offset.zero,
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        onPressed: () => _navigateToAddNewItemScreen(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Item'),
      ),
    );
  }

  void _navigateToAddNewItemScreen(BuildContext context) {
    context.push<ItemUIModel>(AppRouter.createNewItemRoute);
  }
}
