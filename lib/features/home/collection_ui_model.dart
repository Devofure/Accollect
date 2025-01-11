/// UI Model for representing a collection in the app
class CollectionUIModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final int itemCount;

  CollectionUIModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.itemCount,
  });

  // Factory to create UIModel from a domain entity
  factory CollectionUIModel.fromEntity(dynamic entity) {
    return CollectionUIModel(
      id: entity.key,
      // Replace with your domain entity field
      name: entity.name,
      description: entity.description,
      imageUrl: entity.imageUrl,
      itemCount: entity.itemCount ?? 0,
    );
  }

  // Factory to create UIModel from a Firebase snapshot or raw map
  factory CollectionUIModel.fromMap(Map<String, dynamic> map) {
    return CollectionUIModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      itemCount: map['itemCount'] ?? 0,
    );
  }

  // Convert UIModel back to a map (e.g., for saving or sending data)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'itemCount': itemCount,
    };
  }

  @override
  String toString() {
    return 'CollectionUIModel(id: $id, name: $name, description: $description, itemCount: $itemCount)';
  }
}
