import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class AddOrSelectItemViewModel extends ChangeNotifier {
  final IItemRepository repository;
  final String? collectionKey;

  Set<String> selectedItems = {};
  bool isLoading = false;
  String? errorMessage;
  String? _categoryFilter;

  Stream<List<ItemUIModel>>? _itemsStream;

  Stream<List<ItemUIModel>> get itemsStream => _itemsStream!;

  AddOrSelectItemViewModel({
    required this.repository,
    required this.collectionKey,
  }) {
    _itemsStream = repository.fetchItemsStream(_categoryFilter);
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
    if (collectionKey == null) {
      errorMessage = 'Collection key is missing';
      notifyListeners();
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      await Future.wait(selectedItems.map((itemKey) async {
        try {
          await repository.addItemToCollection(collectionKey!, itemKey);
        } catch (e) {
          debugPrint("❌ Failed to add item $itemKey to collection: $e");
        }
      }));

      selectedItems.clear();
    } catch (e) {
      errorMessage = 'Failed to add selected items to collection';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createItem(ItemUIModel newItem) async {
    try {
      isLoading = true;
      notifyListeners();
      await repository.createItem(newItem);
    } catch (e) {
      errorMessage = 'Failed to create and add item';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterItems(String query) {
    _categoryFilter = query.isEmpty ? null : query;
    _itemsStream = repository.fetchItemsStream(_categoryFilter);
    notifyListeners();
  }
}
