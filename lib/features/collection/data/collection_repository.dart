import 'package:accollect/core/data/in_memory_database.dart';
import 'package:accollect/core/models/collection_ui_model.dart';
import 'package:accollect/core/models/item_ui_model.dart';

abstract class ICollectionRepository {
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey);

  Future<List<ItemUIModel>> fetchItems(String collectionKey);

  Future<void> createCollection(CollectionUIModel collection);
}

class CollectionRepository implements ICollectionRepository {
  final InMemoryDatabase _db = InMemoryDatabase();

  @override
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey) async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      final collection = _db.getCollection(collectionKey);
      if (collection == null) throw Exception('Collection not found');
      return collection;
    });
  }

  @override
  Future<List<ItemUIModel>> fetchItems(String collectionKey) async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      return _db.getItemsForCollection(collectionKey);
    });
  }

  @override
  Future<void> createCollection(CollectionUIModel collection) async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      _db.addCollection(collection);
    });
  }
}
