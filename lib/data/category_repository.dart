import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ICategoryRepository {
  Future<List<String>> fetchCategories();

  Future<void> addCategory(String category);
}

class CategoryRepository implements ICategoryRepository {
  final DocumentReference _categoriesDoc =
      FirebaseFirestore.instance.collection('meta').doc('categories');

  @override
  Future<List<String>> fetchCategories() async {
    try {
      final doc = await _categoriesDoc.get();
      if (!doc.exists) return ['Funko Pop', 'LEGO', 'Wine', 'Other'];

      final data = doc.data() as Map<String, dynamic>?;
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
        final data = doc.data() as Map<String, dynamic>?;

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
}
