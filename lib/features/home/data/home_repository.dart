import '../../../core/data/in_memory_database.dart';
import '../../../core/models/collection_ui_model.dart';
import '../../../core/models/item_ui_model.dart';

abstract class IHomeRepository {
  Future<List<CollectionUIModel>> fetchCollections();

  Future<List<ItemUIModel>> fetchLatestItems();
}

class HomeRepository implements IHomeRepository {
  final InMemoryDatabase _db = InMemoryDatabase();

  @override
  Future<List<CollectionUIModel>> fetchCollections() async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      return _db.getAllCollections();
    });
  }

  @override
  Future<List<ItemUIModel>> fetchLatestItems() async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      final allItems = _db.allItems.values.expand((items) => items).toList();
      allItems.sort((a, b) => b.addedOn.compareTo(a.addedOn));
      return allItems.take(5).toList();
    });
  }
}
