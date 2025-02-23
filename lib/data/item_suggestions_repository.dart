import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class IItemSuggestionRepository {
  Future<List<Map<String, dynamic>>> fetchItemSuggestions(String query);
}

class ItemSuggestionRepository implements IItemSuggestionRepository {
  static const String _baseUrlUpicitemdb =
      "https://api.upcitemdb.com/prod/trial/search";

  @override
  Future<List<Map<String, dynamic>>> fetchItemSuggestions(String query) async {
    final Uri url =
        Uri.parse("$_baseUrlUpicitemdb?s=$query&match_mode=1&type=product");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          return data['items'].map<Map<String, dynamic>>((item) {
            return {
              'title': item['title'],
              'brand': item['brand'] ?? "Unknown Brand",
              'images': item['images'] ?? [],
              'description': item['description'] ?? "",
              'category': item['category'] ?? "Other",
              'originalPrice': item['lowest_recorded_price']?.toString() ?? "",
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching suggestions: $e");
    }

    return [];
  }
}
