import 'package:accollect/core/data/item_repository.dart';
import 'package:accollect/core/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class ItemViewModel extends ChangeNotifier {
  final IItemRepository repository;
  final String collectionKey;

  List<ItemUIModel> availableItems = [];
  Map<String, List<ItemUIModel>> groupedItems = {};
  Set<String> selectedItems = {};
  bool isLoading = false;
  String? errorMessage;

  ItemViewModel({required this.repository, required this.collectionKey}) {
    _loadAvailableItems();
  }

  Future<void> _loadAvailableItems() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      availableItems = await repository.fetchAvailableItems();
      _groupItemsByCategory();
    } catch (e) {
      errorMessage = 'Failed to load items';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _groupItemsByCategory() {
    groupedItems.clear();
    for (final item in availableItems) {
      final category = item.category;
      groupedItems.putIfAbsent(category, () => []).add(item);
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

  Future<void> addSelectedItems() async {
    try {
      isLoading = true;
      notifyListeners();

      for (final itemKey in selectedItems) {
        await repository.addItemToCollection(collectionKey, itemKey);
      }

      selectedItems.clear();
      await _loadAvailableItems();
    } catch (e) {
      errorMessage = 'Failed to add selected items to collection';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAndAddItem(ItemUIModel newItem) async {
    try {
      isLoading = true;
      notifyListeners();

      final createdItem = await repository.createItem(newItem);
      await repository.addItemToCollection(collectionKey, createdItem.key);

      await _loadAvailableItems();
    } catch (e) {
      errorMessage = 'Failed to create and add item';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterItems(String query) {
    availableItems = availableItems
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _groupItemsByCategory();
    notifyListeners();
  }
}
