import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:accollect/domain/models/item_ui_model.dart';

class InMemoryDatabase {
  static final InMemoryDatabase _instance = InMemoryDatabase._internal();

  factory InMemoryDatabase() => _instance;

  InMemoryDatabase._internal();

  // Storage for collections and items
  final Map<String, CollectionUIModel> _collections = {};
  final Map<String, ItemUIModel> _items = {};
  final List<String> _categories = ['Funko Pop', 'LEGO', 'Wine', 'Other'];

  Map<String, ItemUIModel> get allItems => _items;

  // Add a collection
  void addCollection(CollectionUIModel collection) {
    print('[InMemoryDatabase] Adding collection: ${collection.name}');
    _collections[collection.key] = collection;
  }

  // Get a collection by key
  CollectionUIModel? getCollection(String collectionKey) {
    print('[InMemoryDatabase] Fetching collection for key: $collectionKey');
    return _collections[collectionKey];
  }

  // Get all collections
  List<CollectionUIModel> getAllCollections() {
    print('[InMemoryDatabase] Fetching all collections');
    return _collections.values.toList();
  }

  // Add an item
  void addItem(ItemUIModel item) {
    print('[InMemoryDatabase] Adding item: ${item.title}');
    _items[item.key] = item;
  }

  // Update an item
  void updateItem(ItemUIModel updatedItem) {
    print('[InMemoryDatabase] Updating item: ${updatedItem.title}');
    allItems[updatedItem.key] = updatedItem;
  }

  // Get all items
  List<ItemUIModel> getAllItems() {
    print('[InMemoryDatabase] Fetching all items');
    return _items.values.toList();
  }

  // Get all items for a collection
  List<ItemUIModel> getItemsForCollection(String collectionKey) {
    print('[InMemoryDatabase] Fetching items for collection: $collectionKey');
    return _items.values
        .where((item) => item.collectionKey == collectionKey)
        .toList();
  }

  List<String> getCategories() {
    return List.unmodifiable(_categories);
  }

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
    }
  }
}
