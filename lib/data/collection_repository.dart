import 'dart:io';

import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class ICollectionRepository {
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey);

  Stream<List<CollectionUIModel>> fetchCollectionsStream();

  Stream<List<CollectionUIModel>> fetchSharedCollectionsStream();

  Future<void> createCollection(CollectionUIModel collection, File? image);

  Future<void> deleteCollection(String collectionKey);

  Future<void> deleteAllCollections();
}

class CollectionRepository implements ICollectionRepository {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('collections');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey) async {
    final doc = await _collectionRef.doc(collectionKey).get();
    if (!doc.exists) throw Exception('Collection not found');

    final data = doc.data() as Map<String, dynamic>;
    return CollectionUIModel.fromJson(data, doc.id);
  }

  @override
  Stream<List<CollectionUIModel>> fetchCollectionsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    return _collectionRef.where('ownerId', isEqualTo: user.uid).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => CollectionUIModel.fromJson(
                doc.data() as Map<String, dynamic>, doc.id))
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
            .map((doc) => CollectionUIModel.fromJson(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  @override
  Future<void> createCollection(
      CollectionUIModel collection, File? image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    final newDocRef = _collectionRef.doc();
    String? imageUrl;

    if (image != null) {
      imageUrl = await _uploadCollectionImage(newDocRef.id, image);
    }

    final data = {
      'name': collection.name,
      'description': collection.description,
      'category': collection.category,
      'ownerId': user.uid,
      'sharedWith': [],
      'itemsCount': 0,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await newDocRef.set(data);
  }

  Future<String> _uploadCollectionImage(
      String collectionKey, File image) async {
    try {
      final ref = _storage.ref().child('collections/$collectionKey.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      // TODO silently fail for now because Storage cost
      throw Exception('Failed to upload image: $e');
    }
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
