// lib/features/home/home_view_model.dart

import 'package:accollect/features/home/ui_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'collection_ui_model.dart';

class HomeViewModel extends ChangeNotifier {
  List<CollectionUIModel> collections = [];
  List<LatestItemUIModel> latestItems = [];
  bool isLoading = true;
  String? errorMessage;

  HomeViewModel() {
    _loadData();
  }

  get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _loadData() async {
    try {
      // Simulate a delay for fetching data
      await Future.delayed(const Duration(seconds: 2));
      // Mock collections
      collections = [
        CollectionUIModel(
          id: '1',
          name: 'LEGO',
          description: 'Build your imagination',
          itemCount: 12,
        ),
        CollectionUIModel(
          id: '2',
          name: 'Wines',
          description: 'A collection of exquisite wines.',
          itemCount: 8,
        ),
      ];

      // Mock latest items
      latestItems = [
        LatestItemUIModel(
          id: 'item1',
          title: 'Super Guy',
          imageUrl: null,
          addedOn: DateTime.now(),
        ),
        LatestItemUIModel(
          id: 'item2',
          title: 'Mega Hero',
          imageUrl: null,
          addedOn: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      isLoading = false;
    } catch (e) {
      errorMessage = 'Failed to load data';
      isLoading = false;
    } finally {
      notifyListeners();
    }
  }
}
