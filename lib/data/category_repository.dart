import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class ICategoryRepository {
  Future<List<String>> fetchAllCategories();

  Stream<List<String>> fetchUserCategoriesStream();

  Future<void> addCategory(String category);

  Future<void> deleteCategory(String category);

  Future<void> deleteAllCategories();
}

class CategoryRepository implements ICategoryRepository {
  final CollectionReference _metaRef =
      FirebaseFirestore.instance.collection('meta');

  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection('users');

  @override
  Future<List<String>> fetchAllCategories() async {
    try {
      final staticCategories = await _fetchStaticCategories();
      final dynamicCategories = await fetchUserCategories();
      return [...staticCategories, ...dynamicCategories];
    } catch (e) {
      throw Exception('Failed to fetch all categories: $e');
    }
  }

  Future<List<String>> _fetchStaticCategories() async {
    try {
      final doc = await _metaRef.doc('categories').get();
      return List<String>.from(
          (doc.data() as Map<String, dynamic>?)?['staticCategories'] ?? []);
    } catch (e) {
      throw Exception('Failed to fetch static categories: $e');
    }
  }

  Future<List<String>> fetchUserCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    final doc = await _userRef.doc(user.uid).get();
    return List<String>.from(
        (doc.data() as Map<String, dynamic>?)?['dynamicCategories'] ?? []);
  }

  @override
  Stream<List<String>> fetchUserCategoriesStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated.");
    }

    return _userRef.doc(user.uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return [];
      return List<String>.from(
          (snapshot.data() as Map<String, dynamic>?)?['dynamicCategories'] ??
              []);
    });
  }

  @override
  Future<void> addCategory(String category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    final docRef = _userRef.doc(user.uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      await docRef.set({
        'dynamicCategories': [category]
      });
    } else {
      await docRef.update({
        'dynamicCategories': FieldValue.arrayUnion([category])
      });
    }
  }

  @override
  Future<void> deleteCategory(String category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    await _userRef.doc(user.uid).update({
      'dynamicCategories': FieldValue.arrayRemove([category])
    });
  }

  @override
  Future<void> deleteAllCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not authenticated.");

    try {
      await _userRef.doc(user.uid).update({'dynamicCategories': []});
    } catch (e) {
      throw Exception('Failed to delete all user categories: $e');
    }
  }
}
