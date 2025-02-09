import 'package:accollect/data/models/item_ui_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

abstract class IItemRepository {
  Future<List<ItemUIModel>> fetchAvailableItems({int limit});

  Stream<List<ItemUIModel>> fetchLatestItemsStream();

  Future<List<ItemUIModel>> fetchItems(String collectionKey);

  Future<void> createItem(ItemUIModel item);

  Future<void> addItemToCollection(String collectionKey, String itemKey);

  Future<List<String>> fetchCategories();

  Future<void> addCategory(String category);

  Future<ItemUIModel> getItemByKey(String itemKey);

  Future<void> deleteItem(String itemKey);
}

class ItemRepository implements IItemRepository {
  final CollectionReference _itemsRef =
      FirebaseFirestore.instance.collection('items');
  final DocumentReference _categoriesDoc =
      FirebaseFirestore.instance.collection('meta').doc('categories');

  @override
  Future<List<ItemUIModel>> fetchAvailableItems({int limit = 20}) async {
    try {
      final snapshot = await _itemsRef.limit(limit).get();
      debugPrint("Fetched ${snapshot.docs.length} items from Firestore.");
      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map(
        (doc) {
          final item = ItemUIModel.fromJson(doc.data() as Map<String, dynamic>);
          debugPrint("📦 Item: ${item.title}, Category: ${item.category}");
          return item;
        },
      ).toList();
    } catch (e) {
      debugPrint("❌ Error fetching available items: $e");
      throw Exception('Failed to fetch available items: $e');
    }
  }

  @override
  Stream<List<ItemUIModel>> fetchLatestItemsStream() {
    return _itemsRef
        .where('collectionKey', isNotEqualTo: null)
        .orderBy('addedOn', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ItemUIModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Future<List<ItemUIModel>> fetchItems(String collectionKey) async {
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
  Future<void> createItem(ItemUIModel item) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not authenticated.");
      }
      await _itemsRef.doc(item.key).set(item.toJson());
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
}
