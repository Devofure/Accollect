import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

abstract class IItemRepository {
  Stream<List<ItemUIModel>> fetchItemsStream(String? categoryFilter);

  Stream<List<ItemUIModel>> fetchLatestItemsStream();

  Future<List<ItemUIModel>> fetchItemsFromCollection(String collectionKey);

  Future<ItemUIModel> createItem(ItemUIModel item);

  Future<void> addItemToCollection(String collectionKey, String itemKey);

  Future<List<String>> fetchCategories();

  Future<void> addCategory(String category);

  Future<ItemUIModel> getItemByKey(String itemKey);

  Future<void> deleteItem(String itemKey);

  Future<void> deleteAllItems();
}

class ItemRepository implements IItemRepository {
  final CollectionReference _itemsRef =
      FirebaseFirestore.instance.collection('items');
  final DocumentReference _categoriesDoc =
      FirebaseFirestore.instance.collection('meta').doc('categories');

  @override
  Stream<List<ItemUIModel>> fetchItemsStream(String? categoryFilter) {
    Query query = _itemsRef;
    if (categoryFilter != null && categoryFilter != 'All') {
      query = query.where('category', isEqualTo: categoryFilter);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  ItemUIModel.fromJson(doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  @override
  Stream<List<ItemUIModel>> fetchLatestItemsStream() {
    return _itemsRef
        .where('collectionKey', isNotEqualTo: null)
        .orderBy('addedOn', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ItemUIModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Future<List<ItemUIModel>> fetchItemsFromCollection(
      String collectionKey) async {
    try {
      final snapshot = await _itemsRef
          .where('collectionKeys', arrayContains: collectionKey)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Ensure 'title' and other fields are not null
        return ItemUIModel.fromJson({
          'key': doc.id,
          'title': data['title'] ?? 'Unknown Item',
          'category': data['category'] ?? 'Other',
          'collectionKeys': List<String>.from(data['collectionKeys'] ?? [])
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch items for collection: $e');
    }
  }

  @override
  Future<ItemUIModel> createItem(ItemUIModel item) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }
      await _itemsRef.doc(item.key).set(item.toJson());
      return item; // TODO Return the created item
    } catch (e, stackTrace) {
      debugPrint('Failed to create item: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Failed to create item: $e');
    }
  }

  @override
  Future<void> addItemToCollection(String collectionKey, String itemKey) async {
    try {
      await _itemsRef.doc(itemKey).update({'collectionKey': collectionKey});
    } catch (e) {
      throw Exception('Failed to add item to collection: $e');
    }
  }

  @override
  Future<List<String>> fetchCategories() async {
    try {
      final doc = await _categoriesDoc.get();

      if (!doc.exists)
        return ['Funko Pop', 'LEGO', 'Wine', 'Other']; // Default categories

      final data = doc.data() as Map<String, dynamic>?; // 🔥 Null-safe cast
      return List<String>.from(data?['categories'] ?? []);
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<void> addCategory(String category) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final doc = await transaction.get(_categoriesDoc);
        final data = doc.data() as Map<String, dynamic>?; // 🔥 Null-safe cast

        final List<String> currentCategories =
            List<String>.from(data?['categories'] ?? []);

        if (!currentCategories.contains(category)) {
          currentCategories.add(category);
          transaction.set(_categoriesDoc, {'categories': currentCategories});
        }
      });
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  @override
  Future<ItemUIModel> getItemByKey(String itemKey) async {
    try {
      final doc = await _itemsRef.doc(itemKey).get();

      if (!doc.exists) {
        throw Exception('Item not found.');
      }

      final data = doc.data() as Map<String, dynamic>;
      return ItemUIModel.fromJson(data);
    } catch (e) {
      debugPrint('❌ Error fetching item by key: $e');
      throw Exception('Failed to fetch item: $e');
    }
  }

  @override
  Future<void> deleteItem(String itemKey) async {
    try {
      await _itemsRef.doc(itemKey).delete();
      debugPrint("✅ Item deleted: $itemKey");
    } catch (e) {
      debugPrint('❌ Error deleting item: $e');
      throw Exception('Failed to delete item: $e');
    }
  }

  @override
  Future<void> deleteAllItems() async {
    try {
      const int batchSize = 500;
      QuerySnapshot snapshot;
      do {
        snapshot = await _itemsRef.limit(batchSize).get();
        if (snapshot.docs.isEmpty) {
          return;
        }
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } while (snapshot.docs.length == batchSize);
    } catch (e) {
      debugPrint("❌ Error deleting all items: $e");
      throw Exception('Failed to delete all items: $e');
    }
  }
}
