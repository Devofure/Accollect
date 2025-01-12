import 'package:accollect/core/models/collection_ui_model.dart';
import 'package:accollect/core/models/item_ui_model.dart';

class InMemoryDatabase {
  // Singleton instance
  static final InMemoryDatabase _instance = InMemoryDatabase._internal();

  factory InMemoryDatabase() => _instance;

  InMemoryDatabase._internal();

  // Storage for collections and items
  final Map<String, CollectionUIModel> _collections = {};
  final Map<String, List<ItemUIModel>> _items = {};

  Map<String, List<ItemUIModel>> get allItems => _items;

  // Add a collection
  void addCollection(CollectionUIModel collection) {
    _collections[collection.key] = collection;
    _items[collection.key] = [];
  }

  // Get a collection by key
  CollectionUIModel? getCollection(String collectionKey) {
    return _collections[collectionKey];
  }

  // Get all collections
  List<CollectionUIModel> getAllCollections() {
    return _collections.values.toList();
  }

  // Add an item to a collection
  void addItemToCollection(String collectionKey, ItemUIModel item) {
    _items[collectionKey]?.add(item);
    if (_collections[collectionKey] != null) {
      _collections[collectionKey] = _collections[collectionKey]!
          .copyWith(itemCount: _items[collectionKey]!.length);
    }
  }

  // Get all items for a collection
  List<ItemUIModel> getItems(String collectionKey) {
    return _items[collectionKey] ?? [];
  }
}
