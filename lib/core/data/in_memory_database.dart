import 'package:accollect/core/models/collection_ui_model.dart';
import 'package:accollect/core/models/item_ui_model.dart';

class InMemoryDatabase {
  static final InMemoryDatabase _instance = InMemoryDatabase._internal();

  factory InMemoryDatabase() => _instance;

  InMemoryDatabase._internal();

  // Storage for collections and items
  final Map<String, CollectionUIModel> _collections = {};
  final Map<String, ItemUIModel> _items = {};

  Map<String, ItemUIModel> get allItems => _items;

  // Add a collection
  void addCollection(CollectionUIModel collection) {
    _collections[collection.key] = collection;
  }

  // Get a collection by key
  CollectionUIModel? getCollection(String collectionKey) {
    return _collections[collectionKey];
  }

  // Get all collections
  List<CollectionUIModel> getAllCollections() {
    return _collections.values.toList();
  }

  // Add an item
  void addItem(ItemUIModel item) {
    _items[item.key] = item;
    final collectionKey = item.collectionKey;
    if (collectionKey != null && _collections[collectionKey] != null) {
      final collection = _collections[collectionKey]!;
      final updatedCount =
          _items.values.where((i) => i.collectionKey == collectionKey).length;
      _collections[collectionKey] =
          collection.copyWith(itemCount: updatedCount);
    }
  }

  // Get all items
  List<ItemUIModel> getAllItems() {
    return _items.values.toList();
  }

  // Get all items for a collection
  List<ItemUIModel> getItemsForCollection(String collectionKey) {
    return _items.values
        .where((item) => item.collectionKey == collectionKey)
        .toList();
  }
}
