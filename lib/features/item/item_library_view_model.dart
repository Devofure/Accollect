import 'package:accollect/core/data/item_repository.dart';
import 'package:accollect/core/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class ItemLibraryViewModel extends ChangeNotifier {
  final IItemRepository repository;

  List<ItemUIModel> availableItems = [];
  Map<String, List<ItemUIModel>> groupedItems = {};
  Set<String> selectedItems = {};
  bool isLoading = false;
  String? errorMessage;

  // Additional fields for category filtering and sorting
  String selectedCategory = 'All';
  String sortOrder = 'Year';

  ItemLibraryViewModel({required this.repository}) {
    _loadAvailableItems();
  }

  Future<void> _loadAvailableItems() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      availableItems = await repository.fetchAvailableItems();
      debugPrint('Fetched Available Items: ${availableItems.length}');
      _applyFiltersAndGrouping();

      debugPrint(
          'Available Items: ${availableItems.map((e) => e.title).toList()}');
    } catch (e) {
      errorMessage = 'Failed to load items';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _applyFiltersAndGrouping() {
    // Apply category filter
    List<ItemUIModel> filteredItems = availableItems;
    if (selectedCategory != 'All') {
      filteredItems = filteredItems
          .where((item) => item.category == selectedCategory)
          .toList();
    }

    // Apply sorting
    if (sortOrder == 'Year') {
      filteredItems
          .sort((a, b) => b.addedOn.compareTo(a.addedOn)); // Descending by date
    } else if (sortOrder == 'Name') {
      filteredItems
          .sort((a, b) => a.title.compareTo(b.title)); // Alphabetically by name
    }

    // Group items by category
    groupedItems.clear();
    for (final item in filteredItems) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }
  }

  Map<String, List<ItemUIModel>> getAvailableItemsGroupedByCategory() {
    return groupedItems;
  }

  void toggleItemSelection(String itemKey, bool isSelected) {
    if (isSelected) {
      selectedItems.add(itemKey);
    } else {
      selectedItems.remove(itemKey);
    }
    notifyListeners();
  }

  bool isSelected(String itemKey) => selectedItems.contains(itemKey);

  Future<void> createItem(ItemUIModel newItem) async {
    try {
      isLoading = true;
      notifyListeners();
      await repository.createItem(newItem);
      await _loadAvailableItems();
    } catch (e) {
      errorMessage = 'Failed to create and add item';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterItems(String query) {
    final filtered = availableItems
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (selectedCategory != 'All') {
      groupedItems.clear();
      for (final item in filtered) {
        if (item.category == selectedCategory) {
          groupedItems.putIfAbsent(item.category, () => []).add(item);
        }
      }
    } else {
      groupedItems.clear();
      for (final item in filtered) {
        groupedItems.putIfAbsent(item.category, () => []).add(item);
      }
    }

    notifyListeners();
  }

  void selectCategory(String category) {
    selectedCategory = category;
    _applyFiltersAndGrouping();
    notifyListeners();
  }

  void sortItems(String order) {
    sortOrder = order;
    _applyFiltersAndGrouping();
    notifyListeners();
  }
}
