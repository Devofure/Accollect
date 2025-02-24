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

  Future<ItemUIModel> createItem(ItemUIModel item, List<File>? images);

  Future<void> removeItemFromCollection(String collectionKey, String itemKey);

  Future<void> addItemToCollection(String collectionKey, String itemKey);

  Future<void> deleteItem(String itemKey);

  Future<void> deleteAllItems();

  updateFavoriteImage(String itemKey, String imageUrl);
}

class ItemRepository implements IItemRepository {
  final CollectionReference _itemsRef =
      FirebaseFirestore.instance.collection('items');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Stream<ItemUIModel?> fetchItemStream(String itemKey) {
    return _itemsRef.doc(itemKey).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return ItemUIModel.fromJson(
          snapshot.data() as Map<String, dynamic>, snapshot.id);
    });
  }

  @override
  Stream<List<ItemUIModel>> fetchItemsStream(String? categoryFilter) {
    Query query = _itemsRef;
    if (categoryFilter != null) {
      query = query.where('category', isEqualTo: categoryFilter);
    }
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) =>
            ItemUIModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  @override
  Stream<List<ItemUIModel>> fetchItemsFromCollectionStream(
      String collectionKey) {
    return _itemsRef
        .where('collectionIds', arrayContains: collectionKey)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemUIModel.fromJson(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  @override
  Stream<List<ItemUIModel>> fetchLatestItemsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    return _itemsRef
        .where('ownerId', isEqualTo: user.uid)
        .orderBy('addedOn', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ItemUIModel.fromJson(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  @override
  Future<ItemUIModel> createItem(
    ItemUIModel item,
    List<File>? images,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    final newDocRef = _itemsRef.doc();
    final itemId = newDocRef.id;

    final Map<String, dynamic> itemData = item.toJson()
      ..removeWhere((key, value) => value == null);

    itemData['ownerId'] = user.uid;
    itemData['addedOn'] = FieldValue.serverTimestamp();

    await newDocRef.set(itemData);

    if (images?.isNotEmpty == true) {
      final imageUrls = await _uploadImagesToFirebase(itemId, images!);
      await newDocRef.update({'imageUrls': imageUrls});
    }

    return item.copyWith(
        key: itemId, imageUrls: images?.isNotEmpty == true ? [""] : []);
  }

  Future<List<String>> _uploadImagesToFirebase(
      String itemId, List<File> images) async {
    List<String> imageUrls = [];
    try {
      for (var image in images) {
        final ref = _storage.ref().child(
            'items/$itemId/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
    } catch (e) {
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

  @override
  Future<void> updateFavoriteImage(String itemKey, String imageUrl) async {
    await _itemsRef.doc(itemKey).update({'favoriteImageUrl': imageUrl});
  }
}
