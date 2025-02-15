import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class IItemRepository {
  Stream<List<ItemUIModel>> fetchItemsStream(String? categoryFilter);

  Stream<List<ItemUIModel>> fetchItemsFromCollectionStream(
      String collectionKey);

  Stream<List<ItemUIModel>> fetchLatestItemsStream();

  Stream<ItemUIModel?> fetchItemStream(String itemKey);

  Future<ItemUIModel> createItem(ItemUIModel item);

  Future<void> removeItemFromCollection(String collectionKey, String itemKey);

  Future<void> addItemToCollection(String collectionKey, String itemKey);

  Future<void> deleteItem(String itemKey);

  Future<void> deleteAllItems();
}

class ItemRepository implements IItemRepository {
  final CollectionReference _itemsRef =
      FirebaseFirestore.instance.collection('items');

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
        .where('ownerId', isEqualTo: user.uid) // Ensure only user's items
        .orderBy('addedOn', descending: true) // Fetch most recent items first
        .limit(10) // Limit to the last 10 added items
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ItemUIModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Future<ItemUIModel> createItem(ItemUIModel item) async {
    await _itemsRef.doc(item.key).set(item.toJson());
    return item;
  }

  @override
  Future<void> addItemToCollection(String collectionKey, String itemKey) async {
    final docRef = _itemsRef.doc(itemKey);
    await docRef.update({
      'collectionIds': FieldValue.arrayUnion([collectionKey])
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
    } else {}
  }
}
