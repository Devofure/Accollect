class CategoryAttributesModel {
  final String category;
  final List<AttributeDefinition> attributes;

  CategoryAttributesModel({
    required this.category,
    required this.attributes,
  });

  factory CategoryAttributesModel.fromJson(Map<String, dynamic> json) {
    return CategoryAttributesModel(
      category: json['category'] as String,
      attributes: (json['attributes'] as List<dynamic>)
          .map((e) => AttributeDefinition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'attributes': attributes.map((e) => e.toJson()).toList(),
      };
}

class AttributeDefinition {
  final String field;
  final String label;
  final String type;
  final String? placeholder;

  AttributeDefinition({
    required this.field,
    required this.label,
    required this.type,
    this.placeholder,
  });

  factory AttributeDefinition.fromJson(Map<String, dynamic> json) {
    return AttributeDefinition(
      field: json['field'] as String,
      label: json['label'] as String,
      type: json['type'] as String,
      placeholder: json['placeholder'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'field': field,
        'label': label,
        'type': type,
        'placeholder': placeholder,
      };
}
