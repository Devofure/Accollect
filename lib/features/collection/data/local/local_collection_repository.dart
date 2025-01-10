// lib/features/collection/data/local/local_collection_repository.dart
import 'dart:async';

import 'package:accollect/features/collection/domain/entities/collection_entity.dart';
import 'package:accollect/features/collection/domain/repositories/collection_repository.dart';

class LocalCollectionRepository implements CollectionRepository {
  final List<CollectionEntity> _collections = [];
  final StreamController<List<CollectionEntity>> _controller =
      StreamController.broadcast();

  LocalCollectionRepository() {
    _emitChanges();
  }

  @override
  Stream<List<CollectionEntity>> getCollections() {
    return _controller.stream;
  }

  @override
  Future<void> addCollection(CollectionEntity collection) async {
    _collections.add(collection);
    _emitChanges();
  }

  @override
  Future<void> deleteCollection(String id) async {
    _collections.removeWhere((collection) => collection.id == id);
    _emitChanges();
  }

  void _emitChanges() {
    _controller.add(List.unmodifiable(_collections));
  }

  void dispose() {
    _controller.close();
  }
}
