import '../../../core/data/in_memory_database.dart';
import '../../../core/models/item_ui_model.dart';

abstract class IItemRepository {
  Future<List<ItemUIModel>> fetchAvailableItems();

  Future<ItemUIModel> createItem(ItemUIModel item);

  Future<void> addItemToCollection(String collectionKey, String itemKey);
}

class ItemRepository implements IItemRepository {
  final InMemoryDatabase _database = InMemoryDatabase();

  @override
  Future<List<ItemUIModel>> fetchAvailableItems() async {
    return _database
        .getAllItems()
        .where((item) => item.collectionKey == null)
        .toList();
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
      _database.addItem(item.copyWith(collectionKey: collectionKey));
    }
  }
}
