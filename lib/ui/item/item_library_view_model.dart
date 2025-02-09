import 'dart:async';

import 'package:accollect/data/category_repository.dart';
import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class ItemLibraryViewModel extends ChangeNotifier {
  final IItemRepository repository;
  final ICategoryRepository categoryRepository;

  List<ItemUIModel> availableItems = [];
  Map<String, List<ItemUIModel>> groupedItems = {};
  Set<String> selectedItems = {};
  bool isLoading = false;
  String? errorMessage;
  String searchQuery = "";

  List<String> categories = [];
  String? selectedCategory; // `null` means show all categories
  String sortOrder = 'Year';
  bool isSortingAscending = true;

  bool isScrollingDown = false;

  ItemLibraryViewModel({
    required this.categoryRepository,
    required this.repository,
  }) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _loadCategories();
      await _loadAvailableItems();
    } catch (e) {
      errorMessage = 'Failed to initialize data';
      debugPrint('Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAvailableItems() async {
    try {
      availableItems = await repository.fetchAvailableItems();
      debugPrint('✅ Fetched ${availableItems.length} Available Items');
      _applyFiltersAndGrouping();
    } catch (e) {
      errorMessage = 'Failed to load items';
      debugPrint('❌ Error loading items: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      categories = await categoryRepository.fetchAllCategories();
      debugPrint('✅ Loaded ${categories.length} Categories');
    } catch (e) {
      errorMessage = 'Failed to load categories';
      debugPrint('❌ Error loading categories: $e');
    }
  }

  void _applyFiltersAndGrouping() {
    List<ItemUIModel> filteredItems = availableItems;

    // Apply category filter
    if (selectedCategory != null) {
      filteredItems = filteredItems
          .where((item) => item.category == selectedCategory)
          .toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filteredItems = filteredItems
          .where(
            (item) =>
                item.title.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply sorting
    if (sortOrder == 'Year') {
      filteredItems.sort((a, b) => isSortingAscending
          ? a.addedOn.compareTo(b.addedOn)
          : b.addedOn.compareTo(a.addedOn));
    } else if (sortOrder == 'Name') {
      filteredItems.sort((a, b) => isSortingAscending
          ? a.title.compareTo(b.title)
          : b.title.compareTo(a.title));
    }

    // Group by category
    groupedItems.clear();
    if (selectedCategory == null) {
      for (final item in filteredItems) {
        groupedItems.putIfAbsent(item.category, () => []).add(item);
      }
    } else {
      groupedItems[selectedCategory!] = filteredItems;
    }

    notifyListeners();
  }

  Map<String, List<ItemUIModel>> getAvailableItemsGroupedByCategory() {
    return groupedItems;
  }

  void toggleItemSelection(String itemKey, bool isSelected) {
    if (isSelected) {
      selectedItems.add(itemKey);
    } else {
      selectedItems.remove(itemKey);
    }
    notifyListeners();
  }

  bool isSelected(String itemKey) => selectedItems.contains(itemKey);

  Future<void> createItem(ItemUIModel newItem) async {
    try {
      isLoading = true;
      notifyListeners();
      await repository.createItem(newItem);
      await _loadAvailableItems();
    } catch (e) {
      errorMessage = 'Failed to create and add item';
      debugPrint('❌ Error creating item: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterItems(String query) {
    searchQuery = query;
    _applyFiltersAndGrouping();
  }

  void clearSearch() {
    searchQuery = "";
    _applyFiltersAndGrouping();
  }

  void selectCategory(String? category) {
    if (selectedCategory == category) {
      selectedCategory = null; // Reset to show all categories
    } else {
      selectedCategory = category;
    }
    _applyFiltersAndGrouping();
    notifyListeners();
  }

  void sortItems(String order) {
    if (sortOrder == order) {
      isSortingAscending = !isSortingAscending; // Toggle sorting order
    } else {
      sortOrder = order;
      isSortingAscending = true; // Reset to ascending when changing order type
    }
    _applyFiltersAndGrouping();
  }

  Future<void> addCategory(String newCategory) async {
    try {
      if (!categories.contains(newCategory)) {
        await categoryRepository.addCategory(newCategory);
        await _loadCategories();
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to add category';
      debugPrint('❌ Error adding category: $e');
    }
  }

  Future<void> removeItem(String itemKey) async {
    try {
      isLoading = true;
      notifyListeners();
      await repository
          .deleteItem(itemKey); // 🔹 Ensure item is removed from Firestore
      availableItems.removeWhere((item) => item.key == itemKey);
      _applyFiltersAndGrouping();
    } catch (e) {
      errorMessage = 'Failed to remove item';
      debugPrint('❌ Error removing item: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setScrollDirection(bool isScrollingDown) {
    if (this.isScrollingDown != isScrollingDown) {
      this.isScrollingDown = isScrollingDown;
      notifyListeners();
    }
  }

  Future<void> refreshLibrary() async {
    await _initialize();
  }
}
