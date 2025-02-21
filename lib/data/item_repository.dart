import 'dart:io';

import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

abstract class IItemRepository {
  Stream<List<ItemUIModel>> fetchItemsStream(String? categoryFilter);

  Stream<List<ItemUIModel>> fetchItemsFromCollectionStream(
      String collectionKey);

  Stream<List<ItemUIModel>> fetchLatestItemsStream();

  Stream<ItemUIModel?> fetchItemStream(String itemKey);

  Future<ItemUIModel> createItem(ItemUIModel item, List<File> images);

  Future<void> removeItemFromCollection(String collectionKey, String itemKey);

  Future<void> addItemToCollection(String collectionKey, String itemKey);

  Future<void> deleteItem(String itemKey);

  Future<void> deleteAllItems();
}

class ItemRepository implements IItemRepository {
  final CollectionReference _itemsRef =
      FirebaseFirestore.instance.collection('items');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Stream<ItemUIModel?> fetchItemStream(String itemKey) {
    return _itemsRef.doc(itemKey).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return ItemUIModel.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  @override
  Stream<List<ItemUIModel>> fetchItemsStream(String? categoryFilter) {
    Query query = _itemsRef;
    if (categoryFilter != null) {
      query = query.where('category', isEqualTo: categoryFilter);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ItemUIModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  @override
  Stream<List<ItemUIModel>> fetchItemsFromCollectionStream(
    String collectionKey,
  ) {
    return _itemsRef
        .where('collectionIds', arrayContains: collectionKey)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ItemUIModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Stream<List<ItemUIModel>> fetchLatestItemsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated.");
    }

    return _itemsRef
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('addedOn', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ItemUIModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Future<ItemUIModel> createItem(ItemUIModel item, List<File> images) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    final imageUrls = await _uploadImagesToFirebase(images);

    final itemData = item.toJson();
    itemData['ownerId'] = user.uid;
    itemData['imageUrls'] = imageUrls;

    await _itemsRef.doc(item.key).set(itemData);
    return item;
  }

  Future<List<String>> _uploadImagesToFirebase(List<File> images) async {
    List<String> imageUrls = [];
    try {
      for (var image in images) {
        final ref = _storage
            .ref()
            .child('items/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
    } catch (e) {
      // TODO silently fail for now because Storage cost
      debugPrint('Error uploading images: $e');
    }
    return imageUrls;
  }

  @override
  Future<void> addItemToCollection(String collectionKey, String itemKey) async {
    final itemDocRef = _itemsRef.doc(itemKey);
    final collectionDocRef =
        FirebaseFirestore.instance.collection('collections').doc(collectionKey);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(itemDocRef, {
        'collectionIds': FieldValue.arrayUnion([collectionKey]),
      });
      transaction.update(collectionDocRef, {
        'itemsCount': FieldValue.increment(1),
      });
    });
  }

  @override
  Future<void> deleteItem(String itemKey) async {
    await _itemsRef.doc(itemKey).delete();
  }

  @override
  Future<void> deleteAllItems() async {
    final querySnapshot = await _itemsRef.get();
    final batch = FirebaseFirestore.instance.batch();

    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  @override
  Future<void> removeItemFromCollection(
      String collectionKey, String itemKey) async {
    final itemDocRef = _itemsRef.doc(itemKey);
    final collectionDocRef =
        FirebaseFirestore.instance.collection('collections').doc(collectionKey);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.update(itemDocRef, {
        'collectionIds': FieldValue.arrayRemove([collectionKey]),
      });
      transaction.update(collectionDocRef, {
        'itemsCount': FieldValue.increment(-1),
      });
    });
  }
}
