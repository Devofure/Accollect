import 'package:flutter/cupertino.dart';

import '../models/item_ui_model.dart';
import 'in_memory_database.dart';

abstract class IItemRepository {
  Future<List<ItemUIModel>> fetchAvailableItems();

  Future<List<ItemUIModel>> fetchLatestItems();

  Future<List<ItemUIModel>> fetchItems(String collectionKey);

  Future<ItemUIModel> createItem(ItemUIModel item);

  Future<void> addItemToCollection(String collectionKey, String itemKey);
}

class ItemRepository implements IItemRepository {
  final InMemoryDatabase _database = InMemoryDatabase();

  @override
  Future<List<ItemUIModel>> fetchLatestItems() async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      final allItems = _database
          .getAllItems()
          .where((item) =>
              item.collectionKey != null) // Filter items with a collectionKey
          .toList();

      allItems
          .sort((a, b) => b.addedOn.compareTo(a.addedOn)); // Sort by date added
      return allItems.take(5).toList(); // Return the top 5 items
    });
  }

  @override
  Future<List<ItemUIModel>> fetchAvailableItems() async {
    final items = _database
        .getAllItems()
        .where((item) => item.collectionKey == null)
        .toList();
    debugPrint('Repository Available Items: ${items.length}');
    return items;
  }

  @override
  Future<List<ItemUIModel>> fetchItems(String collectionKey) async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      return _database.getItemsForCollection(collectionKey);
    });
  }

  @override
  Future<ItemUIModel> createItem(ItemUIModel item) async {
    _database.addItem(item);
    return item;
  }

  @override
  Future<void> addItemToCollection(String collectionKey, String itemKey) async {
    final item = _database.allItems[itemKey];
    if (item != null) {
      final updatedItem = item.copyWith(collectionKey: collectionKey);
      _database.updateItem(updatedItem); // Update the item in the database
    }
  }
}
