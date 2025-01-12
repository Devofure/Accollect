class ItemUIModel {
  final String key;
  final String title;
  final String? imageUrl;
  final DateTime addedOn;

  ItemUIModel({
    required this.key,
    required this.title,
    required this.imageUrl,
    required this.addedOn,
    required String description,
  });

  // Factory to convert from domain entity
  factory ItemUIModel.fromEntity(dynamic entity) {
    return ItemUIModel(
      key: entity.key,
      // Adjust based on your domain entity
      title: entity.title,
      imageUrl: entity.imageUrl,
      addedOn: entity.addedOn,
      description: '',
    );
  }

  // Example: Convert from a Map, if the data is fetched in a raw map format
  factory ItemUIModel.fromMap(Map<String, dynamic> map) {
    return ItemUIModel(
      key: map['id'],
      title: map['title'],
      imageUrl: map['imageUrl'],
      addedOn: map['addedOn'],
      description: '',
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
}
