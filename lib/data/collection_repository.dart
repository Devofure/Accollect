import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ICollectionRepository {
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey);

  Stream<List<CollectionUIModel>> fetchCollectionsStream();

  Stream<List<CollectionUIModel>> fetchSharedCollectionsStream();

  Future<void> createCollection(CollectionUIModel collection);

  Future<void> shareCollection(String collectionKey, String userId);

  Future<void> deleteCollection(String collectionKey);

  Future<void> deleteAllCollections();
}

class CollectionRepository implements ICollectionRepository {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('collections');

  @override
  Stream<List<CollectionUIModel>> fetchCollectionsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    return _collectionRef.where('ownerId', isEqualTo: user.uid).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) =>
                CollectionUIModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Stream<List<CollectionUIModel>> fetchSharedCollectionsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    return _collectionRef
        .where('sharedWith', arrayContains: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                CollectionUIModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey) async {
    final doc = await _collectionRef.doc(collectionKey).get();
    if (!doc.exists) throw Exception('Collection not found');
    return CollectionUIModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> createCollection(CollectionUIModel collection) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    final data = collection.toJson();
    data['ownerId'] = user.uid;
    data['sharedWith'] = [];
    data['itemsCount'] = 0;

    await _collectionRef.doc(collection.key).set(data);
  }

  @override
  Future<void> shareCollection(String collectionKey, String userId) async {
    final docRef = _collectionRef.doc(collectionKey);
    await docRef.update({
      'sharedWith': FieldValue.arrayUnion([userId])
    });
  }

  @override
  Future<void> deleteCollection(String collectionKey) async {
    await _collectionRef.doc(collectionKey).delete();
  }

  @override
  Future<void> deleteAllCollections() async {
    final querySnapshot = await _collectionRef.get();
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
