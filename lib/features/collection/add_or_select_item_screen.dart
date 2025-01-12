import 'package:accollect/core/widgets/empty_state.dart';
import 'package:accollect/features/collection/add_or_select_item_view_model.dart';
import 'package:accollect/features/collection/data/item_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_new_item_screen.dart';

class AddOrSelectItemScreen extends StatelessWidget {
  final String collectionKey;
  final String collectionName;
  final IItemRepository repository;

  const AddOrSelectItemScreen({
    super.key,
    required this.collectionKey,
    required this.collectionName,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ItemViewModel(repository: repository, collectionKey: collectionKey),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Add to Collection',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Consumer<ItemViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.errorMessage != null) {
                return Center(
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              final availableItemsByCategory =
                  viewModel.getAvailableItemsGroupedByCategory();

              return Column(
                children: [
                  // Title and Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          collectionName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Filter items...',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.grey[800],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: viewModel.filterItems,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _navigateToAddNewItemScreen(
                                  context, viewModel),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
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
                  ),

                  // Available Items List
                  if (availableItemsByCategory.isEmpty)
                    Expanded(
                      child: EmptyStateWidget(
                        message: 'No available items',
                        actionMessage: 'Create a new item to get started.',
                        onPressed: () =>
                            _navigateToAddNewItemScreen(context, viewModel),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView(
                        children: availableItemsByCategory.entries.map((entry) {
                          final category = entry.key;
                          final items = entry.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...items.map((item) {
                                  return ListTile(
                                    title: Text(
                                      item.title,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    trailing: Checkbox(
                                      value: viewModel.isSelected(item.key),
                                      onChanged: (isSelected) {
                                        viewModel.toggleItemSelection(
                                            item.key, isSelected!);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => viewModel.addSelectedItems(),
                          child: const Text('Add Items'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _navigateToAddNewItemScreen(
      BuildContext context, ItemViewModel viewModel) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddNewItemScreen(
          onCreateItem: (newItem) => viewModel.createAndAddItem(newItem),
        ),
      ),
    );
  }
}
