import 'package:accollect/core/data/item_repository.dart';
import 'package:accollect/core/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class ItemLibraryViewModel extends ChangeNotifier {
  final IItemRepository repository;

  List<ItemUIModel> availableItems = [];
  Map<String, List<ItemUIModel>> groupedItems = {};
  Set<String> selectedItems = {};
  bool isLoading = false;
  String? errorMessage;

  List<String> categories = []; // Dynamically loaded categories
  String? selectedCategory; // Default to the first category after loading
  String sortOrder = 'Year';

  ItemLibraryViewModel({required this.repository}) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      // Load categories first
      await _loadCategories();

      // Then load available items
      await _loadAvailableItems();
    } catch (e) {
      errorMessage = 'Failed to initialize data';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAvailableItems() async {
    try {
      availableItems = await repository.fetchAvailableItems();
      debugPrint('Fetched Available Items: ${availableItems.length}');
      _applyFiltersAndGrouping();
    } catch (e) {
      errorMessage = 'Failed to load items';
      debugPrint('Error loading items: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      categories = await repository.fetchCategories();
      if (categories.isNotEmpty) {
        selectedCategory ??= categories.first; // Default to the first category
      } else {
        selectedCategory = null;
      }
    } catch (e) {
      errorMessage = 'Failed to load categories';
      debugPrint('Error loading categories: $e');
    }
  }

  void _applyFiltersAndGrouping() {
    List<ItemUIModel> filteredItems = availableItems;
    if (selectedCategory != null) {
      filteredItems = filteredItems
          .where((item) => item.category == selectedCategory)
          .toList();
    }

    // Apply sorting
    if (sortOrder == 'Year') {
      filteredItems
          .sort((a, b) => b.addedOn.compareTo(a.addedOn)); // Descending
    } else if (sortOrder == 'Name') {
      filteredItems.sort((a, b) => a.title.compareTo(b.title)); // Alphabetical
    }

    // Group items by category
    groupedItems.clear();
    for (final item in filteredItems) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }
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
      debugPrint('Error creating item: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterItems(String query) {
    final filtered = availableItems
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (selectedCategory != null) {
      groupedItems.clear();
      for (final item in filtered) {
        if (item.category == selectedCategory) {
          groupedItems.putIfAbsent(item.category, () => []).add(item);
        }
      }
    } else {
      groupedItems.clear();
      for (final item in filtered) {
        groupedItems.putIfAbsent(item.category, () => []).add(item);
      }
    }

    notifyListeners();
  }

  void selectCategory(String category) {
    selectedCategory = category;
    _applyFiltersAndGrouping();
    notifyListeners();
  }

  void sortItems(String order) {
    sortOrder = order;
    _applyFiltersAndGrouping();
    notifyListeners();
  }

  Future<void> addCategory(String newCategory) async {
    try {
      if (!categories.contains(newCategory)) {
        await repository.addCategory(newCategory); // Save in repository
        await _loadCategories(); // Reload categories
        selectedCategory = newCategory; // Automatically select the new category
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to add category';
      debugPrint('Error adding category: $e');
    }
  }
}
