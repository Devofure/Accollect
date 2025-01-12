import 'package:accollect/core/data/collection_repository.dart';
import 'package:accollect/core/data/item_repository.dart';
import 'package:accollect/core/models/collection_ui_model.dart';
import 'package:accollect/core/models/item_ui_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class HomeViewModel extends ChangeNotifier {
  final IItemRepository itemRepository;
  final ICollectionRepository collectionRepository;

  List<CollectionUIModel> collections = [];
  List<ItemUIModel> latestItems = [];
  bool isLoading = true;
  String? errorMessage;

  HomeViewModel({
    required this.itemRepository,
    required this.collectionRepository,
  }) {
    loadData();
  }

  get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> loadData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      collections = await collectionRepository.fetchCollections();
      latestItems = await itemRepository.fetchLatestItems();

      isLoading = false;
    } catch (e) {
      errorMessage = 'Failed to load data';
      isLoading = false;
    } finally {
      notifyListeners();
    }
  }

  void retryFetchingData() {
    loadData();
  }
}
