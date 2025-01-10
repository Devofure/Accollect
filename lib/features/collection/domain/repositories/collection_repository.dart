// lib/features/collection/domain/repositories/collection_repository.dart
import 'package:accollect/features/collection/domain/entities/collection_entity.dart';

abstract class CollectionRepository {
  Stream<List<CollectionEntity>> getCollections();

  Future<void> addCollection(CollectionEntity collection);

  Future<void> deleteCollection(String id);
}
