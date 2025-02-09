import 'package:accollect/domain/models/collection_ui_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class ICollectionRepository {
  Future<CollectionUIModel> fetchCollectionDetails(String collectionKey);

  Stream<List<CollectionUIModel>> fetchCollectionsStream();

  Stream<List<CollectionUIModel>> fetchSharedCollectionsStream();

  Future<void> createCollection(CollectionUIModel collection);

  Future<void> shareCollection(String collectionKey, String userId);

  void removeItemFromCollection(String itemKey, String collectionKey);

  Future<void> deleteAllCollections();
}

class CollectionRepository implements ICollectionRepository {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('collections');
  final CollectionReference _itemsRef =
      FirebaseFirestore.instance.collection('items');

  @override
  Stream<List<CollectionUIModel>> fetchCollectionsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    return _collectionRef
        .where('ownerId', isEqualTo: user.uid) // Fetch only user's collections
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                CollectionUIModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Stream<List<CollectionUIModel>> fetchSharedCollectionsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    return _collectionRef
        .where('sharedWith',
            arrayContains: user.uid) // Fetch shared collections
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                CollectionUIModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not authenticated.");

      final data = collection.toJson();
      data['ownerId'] = user.uid; // Store the collection owner
      data['sharedWith'] = []; // Default to no shared users

      await _collectionRef.doc(collection.key).set(data);
    } catch (e) {
      throw Exception('Failed to create collection: $e');
    }
  }

  @override
  Future<void> shareCollection(String collectionKey, String userId) async {
    try {
      final docRef = _collectionRef.doc(collectionKey);
      await docRef.update({
        'sharedWith': FieldValue.arrayUnion([userId]) // Add user to shared list
      });
    } catch (e) {
      throw Exception('Failed to share collection: $e');
    }
  }

  @override
  Future<void> removeItemFromCollection(
      String itemKey, String collectionKey) async {
    try {
      final docRef = _itemsRef.doc(itemKey);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception("Item not found.");
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      List<String> collectionKeys =
          List<String>.from(data['collectionKeys'] ?? []);

      if (collectionKeys.contains(collectionKey)) {
        collectionKeys.remove(collectionKey);

        await docRef.update({
          'collectionKeys': collectionKeys,
        });

        debugPrint("✅ Item $itemKey removed from collection $collectionKey");
      } else {
        debugPrint("⚠️ Item is not in collection $collectionKey");
      }
    } catch (e) {
      throw Exception('Failed to remove item from collection: $e');
    }
  }

  @override
  Future<void> deleteAllCollections() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final querySnapshot = await _collectionRef.get();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all collections: $e');
    }
  }
}
