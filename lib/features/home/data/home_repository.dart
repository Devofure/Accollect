import 'package:accollect/core/models/item_ui_model.dart';

import '../../../core/models/collection_ui_model.dart';

abstract class IHomeRepository {
  Future<List<CollectionUIModel>> fetchCollections();

  Future<List<ItemUIModel>> fetchLatestItems();
}

// lib/features/home/repositories/local_home_repository.dart
class HomeRepository implements IHomeRepository {
  @override
  Future<List<CollectionUIModel>> fetchCollections() async {
    return Future.delayed(
        const Duration(seconds: 1),
        () => [
              CollectionUIModel(
                  key: '1',
                  name: 'LEGO',
                  description: 'Build!',
                  itemCount: 5,
                  imageUrl: ''),
              CollectionUIModel(
                  key: '2',
                  name: 'Wines',
                  description: 'Fine collection!',
                  itemCount: 10,
                  imageUrl: ''),
            ]);
  }

  @override
  Future<List<ItemUIModel>> fetchLatestItems() async {
    return Future.delayed(
        const Duration(seconds: 1),
        () => [
              ItemUIModel(
                  key: 'item1',
                  title: 'Super Guy',
                  imageUrl: null,
                  addedOn: DateTime.now(),
                  description: ''),
              ItemUIModel(
                  key: 'item2',
                  title: 'Mega Hero',
                  imageUrl: null,
                  addedOn: DateTime.now().subtract(const Duration(days: 1)),
                  description: ''),
            ]);
  }
}
