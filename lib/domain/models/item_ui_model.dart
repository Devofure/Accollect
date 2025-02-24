import 'package:cloud_firestore/cloud_firestore.dart';

class ItemUIModel {
  final String key;
  final String name;
  final String? description;
  final String? collectionName;
  final String? category;
  final DateTime addedOn;
  final List<String>? imageUrls;
  final List<String>? onlineImageUrls;
  final String? favoriteImageUrl;
  final String? collectionKey;
  final String? notes;
  final String? originalPrice;
  final Map<String, dynamic>? additionalAttributes;

  ItemUIModel({
    required this.key,
    required this.name,
    this.description,
    this.collectionName,
    this.category,
    required this.addedOn,
    this.imageUrls,
    this.onlineImageUrls,
    this.favoriteImageUrl,
    this.collectionKey,
    this.notes,
    this.originalPrice,
    this.additionalAttributes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'addedOn': Timestamp.fromDate(addedOn),
      if (description != null) 'description': description,
      if (collectionName != null) 'collectionName': collectionName,
      if (category != null) 'category': category,
      if (imageUrls != null && imageUrls!.isNotEmpty) 'imageUrls': imageUrls,
      if (onlineImageUrls != null && onlineImageUrls!.isNotEmpty)
        'onlineImageUrls': onlineImageUrls,
      if (favoriteImageUrl != null) 'favoriteImageUrl': favoriteImageUrl,
      if (collectionKey != null) 'collectionKey': collectionKey,
      if (notes != null) 'notes': notes,
      if (originalPrice != null) 'originalPrice': originalPrice,
      if (additionalAttributes != null)
        'additionalAttributes': additionalAttributes,
    };
    return json;
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
      onlineImageUrls:
          (json['onlineImageUrls'] as List?)?.map((e) => e as String).toList(),
      favoriteImageUrl: json['favoriteImageUrl'],
      collectionKey: json['collectionKey'],
      notes: json['notes'],
      originalPrice: json['originalPrice'],
      additionalAttributes: json['additionalAttributes'] != null
          ? Map<String, dynamic>.from(json['additionalAttributes'])
          : null,
    );
  }

  ItemUIModel copyWith({
    String? key,
    String? name,
    String? description,
    String? collectionName,
    String? category,
    DateTime? addedOn,
    List<String>? imageUrls,
    List<String>? onlineImageUrls,
    String? favoriteImageUrl,
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
      onlineImageUrls: onlineImageUrls ?? this.onlineImageUrls,
      favoriteImageUrl: favoriteImageUrl ?? this.favoriteImageUrl,
      collectionKey: collectionKey ?? this.collectionKey,
      notes: notes ?? this.notes,
      originalPrice: originalPrice ?? this.originalPrice,
      additionalAttributes: additionalAttributes ?? this.additionalAttributes,
    );
  }
}

extension ItemUIModelExtensions on ItemUIModel {
  String? get firstImageUrl {
    if (favoriteImageUrl != null) {
      return favoriteImageUrl;
    } else if (imageUrls?.isNotEmpty == true) {
      return imageUrls!.first;
    } else if (onlineImageUrls?.isNotEmpty == true) {
      return onlineImageUrls!.first;
    }
    return null;
  }
}
