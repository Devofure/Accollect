// lib/features/home/collection_model.dart

class CollectionModel {
  final String key;
  final String name;
  final String description;
  final String imageUrl;
  final int itemCount;

  CollectionModel({
    required this.key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.itemCount,
  });
}
