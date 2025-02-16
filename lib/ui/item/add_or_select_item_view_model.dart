import 'dart:async';

import 'package:accollect/data/item_repository.dart';
import 'package:accollect/domain/models/item_ui_model.dart';
import 'package:flutter/foundation.dart';

class AddOrSelectItemViewModel extends ChangeNotifier {
  final IItemRepository repository;
  final String? collectionKey;
  final Set<String> selectedItems = {};
  late Stream<List<ItemUIModel>> _itemsStream;

  Stream<List<ItemUIModel>> get itemsStream => _itemsStream;
  final _loadingController = StreamController<bool>.broadcast();

  Stream<bool> get loadingStream => _loadingController.stream;
  final _errorController = StreamController<String?>.broadcast();

  Stream<String?> get errorStream => _errorController.stream;
  late final void Function(String itemKey, bool isSelected)
      toggleItemSelectionCommand;
  late final void Function() addSelectedItemsCommand;
  late final Future<void> Function(ItemUIModel newItem) createItemCommand;
  late final void Function(String query) filterItemsCommand;
  String? _categoryFilter;

  AddOrSelectItemViewModel({
    required this.repository,
    required this.collectionKey,
  }) {
    _itemsStream = repository.fetchItemsStream(null);
    toggleItemSelectionCommand = (itemKey, isSelected) {
      _toggleItemSelection(itemKey, isSelected);
    };
    addSelectedItemsCommand = () {
      _addSelectedItems();
    };
    createItemCommand = (newItem) {
      return _createItem(newItem);
    };
    filterItemsCommand = (query) {
      _filterItems(query);
    };
  }

  void _toggleItemSelection(String itemKey, bool isSelected) {
    if (isSelected) {
      selectedItems.add(itemKey);
    } else {
      selectedItems.remove(itemKey);
    }
    notifyListeners();
  }

  bool isSelected(String itemKey) => selectedItems.contains(itemKey);

  Future<void> _addSelectedItems() async {
    if (collectionKey == null) {
      _errorController.add('Collection key is missing');
      return;
    }
    try {
      _loadingController.add(true);
      await Future.wait(selectedItems.map((itemKey) async {
        try {
          await repository.addItemToCollection(collectionKey!, itemKey);
        } catch (e) {}
      }));
      selectedItems.clear();
    } catch (e) {
      _errorController.add('Failed to add selected items to collection');
    } finally {
      _loadingController.add(false);
    }
  }

  Future<void> _createItem(ItemUIModel newItem) async {
    try {
      _loadingController.add(true);
      await repository.createItem(newItem);
    } catch (e) {
      _errorController.add('Failed to create and add item');
    } finally {
      _loadingController.add(false);
    }
  }

  void _filterItems(String query) {
    _categoryFilter = query.isEmpty ? null : query;
    _itemsStream = repository.fetchItemsStream(_categoryFilter);
    notifyListeners();
  }

  @override
  void dispose() {
    _loadingController.close();
    _errorController.close();
    super.dispose();
  }
}
