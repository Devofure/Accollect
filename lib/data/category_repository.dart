import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ICategoryRepository {
  Future<List<String>> fetchAllCategories();

  Future<List<String>> fetchEditableCategories();

  Future<void> addCategory(String category);

  Future<void> deleteCategory(String category);

  Future<void> deleteAllCategory();
}

class CategoryRepository implements ICategoryRepository {
  final DocumentReference _categoriesRef =
      FirebaseFirestore.instance.collection('meta').doc('categories');

  static const List<String> _staticCategories = [
    'Funko Pop',
    'LEGO',
    'Wine',
    'Other'
  ];

  @override
  Future<List<String>> fetchAllCategories() async {
    try {
      final doc = await _categoriesRef.get();
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final dynamicCategories =
          List<String>.from(data['dynamicCategories'] ?? []);
      return [..._staticCategories, ...dynamicCategories];
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<void> addCategory(String category) async {
    await _categoriesRef.update({
      'dynamicCategories': FieldValue.arrayUnion([category])
    });
  }

  @override
  Future<void> deleteCategory(String category) async {
    await _categoriesRef.update({
      'dynamicCategories': FieldValue.arrayRemove([category])
    });
  }

  @override
  Future<void> deleteAllCategory() async {
    await _categoriesRef.update({'dynamicCategories': []});
  }

  @override
  Future<List<String>> fetchEditableCategories() async {
    final doc = await _categoriesRef.get();
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return List<String>.from(data['dynamicCategories'] ?? []);
  }
}
