import 'package:accollect/core/data/in_memory_database.dart';
import 'package:accollect/core/models/collection_ui_model.dart';

abstract class ICreateCollectionRepository {
  Future<void> createCollection(CollectionUIModel collection);
}

class CreateCollectionRepository implements ICreateCollectionRepository {
  final InMemoryDatabase _db = InMemoryDatabase();

  @override
  Future<void> createCollection(CollectionUIModel collection) async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      _db.addCollection(collection);
    });
  }
}
