class ItemUIModel {
  final String key;
  final String? collectionKey;
  final String title;
  final String category;
  final String description;
  final String? imageUrl;
  final DateTime addedOn;

  ItemUIModel({
    required this.key,
    required this.collectionKey,
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.addedOn,
    required this.description,
  });

  // Factory to convert from domain entity
  factory ItemUIModel.fromEntity(dynamic entity) {
    return ItemUIModel(
      key: entity.key,
      // Adjust based on your domain entity
      title: entity.title,
      category: entity.category,
      imageUrl: entity.imageUrl,
      addedOn: entity.addedOn,
      description: entity.description,
      collectionKey: entity.collectionKey,
    );
  }

  // Example: Convert from a Map, if the data is fetched in a raw map format
  factory ItemUIModel.fromMap(Map<String, dynamic> map) {
    return ItemUIModel(
      key: map['id'],
      title: map['title'],
      category: map['category'],
      imageUrl: map['imageUrl'],
      addedOn: map['addedOn'],
      description: map['description'],
      collectionKey: map['collectionKey'],
    );
  }

  // Example: Convert to Map, if needed for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': key,
      'title': title,
      'imageUrl': imageUrl,
      'addedOn': addedOn.toIso8601String(),
    };
  }

  ItemUIModel copyWith({
    String? key,
    String? collectionKey,
    String? title,
    String? imageUrl,
    String? category,
    DateTime? addedOn,
    String? description,
  }) {
    return ItemUIModel(
      key: key ?? this.key,
      collectionKey: collectionKey ?? this.collectionKey,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      addedOn: addedOn ?? this.addedOn,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }
}
