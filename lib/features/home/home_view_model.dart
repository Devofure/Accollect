import 'package:accollect/core/models/collection_ui_model.dart';
import 'package:accollect/core/models/item_ui_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'home_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final IHomeRepository repository;

  List<CollectionUIModel> collections = [];
  List<ItemUIModel> latestItems = [];
  bool isLoading = true;
  String? errorMessage;

  HomeViewModel({required this.repository}) {
    _loadData();
  }

  get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _loadData() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      collections = await repository.fetchCollections();
      latestItems = await repository.fetchLatestItems();
      isLoading = false;
    } catch (e) {
      errorMessage = 'Failed to load data';
      isLoading = false;
    } finally {
      notifyListeners();
    }
  }

  /// Retry fetching data by calling `_loadData` again
  void retryFetchingData() {
    _loadData();
  }
}
