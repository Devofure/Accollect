import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class AddOrSelectItemViewModel extends ChangeNotifier {
  final IItemRepository repository;
  final String? collectionKey;

  List<ItemUIModel> availableItems = [];
  Map<String, List<ItemUIModel>> groupedItems = {};
  Set<String> selectedItems = {};
  bool isLoading = false;
  String? errorMessage;
  bool _disposed = false; // Track disposal

  AddOrSelectItemViewModel(
      {required this.repository, required this.collectionKey}) {
    _loadAvailableItems();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _loadAvailableItems() async {
    try {
      isLoading = true;
      errorMessage = null;
      _safeNotifyListeners();

      availableItems = await repository.fetchItemsStream(null).first;
      debugPrint('Fetched Available Items: ${availableItems.length}');
      _groupItemsByCategory();

      debugPrint(
          'Available Items: ${availableItems.map((e) => e.title).toList()}');
    } catch (e) {
      errorMessage = 'Failed to load items';
    } finally {
      isLoading = false;
      _safeNotifyListeners();
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
    debugPrint("Selected Items: $selectedItems");
    _safeNotifyListeners();
  }

  bool isSelected(String itemKey) => selectedItems.contains(itemKey);

  Future<void> addSelectedItems() async {
    if (collectionKey == null) {
      errorMessage = 'Collection key is missing';
      _safeNotifyListeners();
      return;
    }

    try {
      isLoading = true;
      _safeNotifyListeners();

      // Process items in parallel to improve performance
      await Future.wait(selectedItems.map((itemKey) async {
        try {
          await repository.addItemToCollection(collectionKey!, itemKey);
        } catch (e) {
          debugPrint("❌ Failed to add item $itemKey to collection: $e");
        }
      }));

      selectedItems.clear();
      await _loadAvailableItems();
    } catch (e) {
      errorMessage = 'Failed to add selected items to collection';
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> createItem(ItemUIModel newItem) async {
    try {
      isLoading = true;
      _safeNotifyListeners();
      await repository.createItem(newItem);
      await _loadAvailableItems();
    } catch (e) {
      errorMessage = 'Failed to create and add item';
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  void filterItems(String query) {
    availableItems = availableItems
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _groupItemsByCategory();
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
