import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ICategoryRepository {
  Future<List<String>> fetchAllCategories();

  Future<List<String>> fetchEditableCategories();

  Future<void> addCategory(String category);

  Future<void> deleteCategory(String category);
}

class CategoryRepository implements ICategoryRepository {
  final DocumentReference _dynamicCategoriesDoc =
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
      final dynamicCategories = await fetchEditableCategories();
      return [...dynamicCategories, ..._staticCategories];
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<List<String>> fetchEditableCategories() async {
    try {
      final doc = await _dynamicCategoriesDoc.get();
      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>?;
      return List<String>.from(data?['categories'] ?? []);
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<void> addCategory(String category) async {
    if (_staticCategories.contains(category)) {
      throw Exception('Cannot add a static category: $category');
    }

    try {
      final doc = await _dynamicCategoriesDoc.get();
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final List<String> currentCategories =
          List<String>.from(data['categories'] ?? []);

      if (!currentCategories.contains(category)) {
        currentCategories.add(category);
        await _dynamicCategoriesDoc.set({'categories': currentCategories});
      }
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String category) async {
    if (_staticCategories.contains(category)) {
      throw Exception('Cannot delete a static category: $category');
    }

    try {
      final doc = await _dynamicCategoriesDoc.get();
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final List<String> currentCategories =
          List<String>.from(data['categories'] ?? []);

      if (currentCategories.contains(category)) {
        currentCategories.remove(category);
        await _dynamicCategoriesDoc.set({'categories': currentCategories});
      }
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
