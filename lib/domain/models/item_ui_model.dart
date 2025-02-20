import 'package:cloud_firestore/cloud_firestore.dart';

class ItemUIModel {
  final String key;
  final String title;
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
    required this.title,
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

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
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

  factory ItemUIModel.fromJson(Map<String, dynamic> json) {
    return ItemUIModel(
      key: json['key'],
      title: json['title'],
      description: json['description'],
      collectionName: json['collectionName'],
      category: json['category'],
      addedOn: (json['addedOn'] as Timestamp).toDate(),
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
