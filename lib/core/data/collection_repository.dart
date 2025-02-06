import 'package:accollect/core/models/collection_ui_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ICollectionRepository {
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey);

  Stream<List<CollectionUIModel>> fetchCollectionsStream();

  Future<void> createCollection(CollectionUIModel collection);
}

class CollectionRepository implements ICollectionRepository {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('collections');

  @override
  Stream<List<CollectionUIModel>> fetchCollectionsStream() {
    return _collectionRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              CollectionUIModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey) async {
    try {
      final doc = await _collectionRef.doc(collectionKey).get();
      if (!doc.exists) throw Exception('Collection not found');
      return CollectionUIModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch collection details: $e');
    }
  }

  @override
  Future<void> createCollection(CollectionUIModel collection) async {
    try {
      await _collectionRef.doc(collection.key).set(collection.toJson());
    } catch (e) {
      throw Exception('Failed to create collection: $e');
    }
  }
}
