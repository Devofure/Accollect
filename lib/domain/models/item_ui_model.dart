import 'package:cloud_firestore/cloud_firestore.dart';

class ItemUIModel {
  final String key;
  final String name;
  final String? description;
  final String? collectionName;
  final String? category;
  final DateTime addedOn;
  final List<String>? imageUrls;
  final String? collectionKey;
  final String? notes;
  final String? originalPrice;
  final Map<String, dynamic>? additionalAttributes;

  ItemUIModel({
    required this.key,
    required this.name,
    required this.description,
    required this.category,
    required this.addedOn,
    this.collectionName,
    this.imageUrls,
    this.collectionKey,
    this.notes,
    this.originalPrice,
    this.additionalAttributes,
  });

  ItemUIModel copyWith({
    String? key,
    String? name,
    String? description,
    String? collectionName,
    String? category,
    DateTime? addedOn,
    List<String>? imageUrls,
    String? collectionKey,
    String? notes,
    String? originalPrice,
    Map<String, dynamic>? additionalAttributes,
  }) {
    return ItemUIModel(
      key: key ?? this.key,
      name: name ?? this.name,
      description: description ?? this.description,
      collectionName: collectionName ?? this.collectionName,
      category: category ?? this.category,
      addedOn: addedOn ?? this.addedOn,
      imageUrls: imageUrls ?? this.imageUrls,
      collectionKey: collectionKey ?? this.collectionKey,
      notes: notes ?? this.notes,
      originalPrice: originalPrice ?? this.originalPrice,
      additionalAttributes: additionalAttributes ?? this.additionalAttributes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'addedOn': Timestamp.fromDate(addedOn),
      'imageUrls': imageUrls,
      'collectionKey': collectionKey,
      'additionalAttributes': additionalAttributes,
      'originalPrice': originalPrice,
      'notes': notes,
    };
  }

  factory ItemUIModel.fromJson(Map<String, dynamic> json, String id) {
    return ItemUIModel(
      key: id,
      name: json['name'] ?? "Untitled",
      description: json['description'],
      collectionName: json['collectionName'],
      category: json['category'],
      addedOn: (json['addedOn'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrls: (json['imageUrls'] as List?)?.map((e) => e as String).toList(),
      collectionKey: json['collectionKey'],
      notes: json['notes'],
      originalPrice: json['originalPrice'],
      additionalAttributes: json['additionalAttributes'] != null
          ? Map<String, dynamic>.from(json['additionalAttributes'])
          : null,
    );
  }
}

extension ItemUIModelExtensions on ItemUIModel {
  String? get firstImageUrl {
    return (imageUrls?.isNotEmpty == true) ? imageUrls!.first : null;
  }
}
