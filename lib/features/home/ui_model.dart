class LatestItemUIModel {
  final String id;
  final String title;
  final String? imageUrl;
  final DateTime addedOn;

  LatestItemUIModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.addedOn,
  });

  // Factory to convert from domain entity
  factory LatestItemUIModel.fromEntity(dynamic entity) {
    return LatestItemUIModel(
      id: entity.key, // Adjust based on your domain entity
      title: entity.title,
      imageUrl: entity.imageUrl,
      addedOn: entity.addedOn,
    );
  }

  // Example: Convert from a Map, if the data is fetched in a raw map format
  factory LatestItemUIModel.fromMap(Map<String, dynamic> map) {
    return LatestItemUIModel(
      id: map['id'],
      title: map['title'],
      imageUrl: map['imageUrl'],
      addedOn: map['addedOn'],
    );
  }

  // Example: Convert to Map, if needed for serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'addedOn': addedOn.toIso8601String(),
    };
  }
}
