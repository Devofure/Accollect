import 'package:accollect/core/data/in_memory_database.dart';
import 'package:accollect/core/models/collection_ui_model.dart';

abstract class ICollectionRepository {
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey);

  Future<List<CollectionUIModel>> fetchCollections();
  Future<void> createCollection(CollectionUIModel collection);
}

class CollectionRepository implements ICollectionRepository {
  final InMemoryDatabase _db = InMemoryDatabase();

  @override
  Future<List<CollectionUIModel>> fetchCollections() async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      return _db.getAllCollections();
    });
  }

  @override
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey) async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      final collection = _db.getCollection(collectionKey);
      if (collection == null) throw Exception('Collection not found');
      return collection;
    });
  }

  @override
  Future<void> createCollection(CollectionUIModel collection) async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      _db.addCollection(collection);
    });
  }
}
