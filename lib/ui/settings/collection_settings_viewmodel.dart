import 'package:accollect/data/category_repository.dart';
import 'package:flutter/foundation.dart';

class CollectionManagementViewModel extends ChangeNotifier {
  final ICategoryRepository categoryRepository;

  List<String> categories = [];
  bool isLoading = false;
  String? errorMessage;

  CollectionManagementViewModel({required this.categoryRepository}) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      isLoading = true;
      notifyListeners();
      categories = await categoryRepository.fetchCategories();
    } catch (e) {
      errorMessage = 'Failed to load categories';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(String category) async {
    try {
      isLoading = true;
      notifyListeners();
      await categoryRepository.addCategory(category);
      await _loadCategories();
    } catch (e) {
      errorMessage = 'Failed to add category';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String category) async {
    try {
      isLoading = true;
      notifyListeners();
      categories.remove(category);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete category';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAllCollections() async {
    try {
      isLoading = true;
      notifyListeners();
      categories.clear();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete collections';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAllData() async {
    try {
      isLoading = true;
      notifyListeners();
      categories.clear();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete all data';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
