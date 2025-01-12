// CollectionViewModel
import 'package:flutter/foundation.dart';

import '../../core/models/item_ui_model.dart';
import 'data/collection_repository.dart';

class CollectionViewModel extends ChangeNotifier {
  final ICollectionRepository repository;
  final String collectionKey;

  String collectionName = '';
  String? collectionImageUrl;
  List<ItemUIModel> items = [];
  bool isLoading = true;
  String? errorMessage;

  CollectionViewModel({required this.repository, required this.collectionKey}) {
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final collection = await repository.fetchCollectionDetails(collectionKey);
      collectionName = collection.name;
      collectionImageUrl = collection.imageUrl;
      items = await repository.fetchItems(collectionKey);

      isLoading = false;
    } catch (e) {
      errorMessage = 'Failed to load collection data';
      isLoading = false;
    } finally {
      notifyListeners();
    }
  }

  void retryFetchingData() {
    _loadData();
  }
}
