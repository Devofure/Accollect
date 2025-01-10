// lib/features/collection/domain/entities/collection_entity.dart
class CollectionEntity {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int itemCount;

  CollectionEntity({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.itemCount,
  });
}
