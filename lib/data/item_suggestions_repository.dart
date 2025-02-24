import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class IItemSuggestionRepository {
  Future<List<Map<String, dynamic>>> fetchItemSuggestions(String query);

  Future<List<Map<String, dynamic>>> fetchItemByBarcode(String barcode);
}

class ItemSuggestionRepository implements IItemSuggestionRepository {
  static const String _baseUrlUpcItemDbLookup =
      "https://api.upcitemdb.com/prod/trial/lookup";
  static const String _baseUrlUpcItemDbSearch =
      "https://api.upcitemdb.com/prod/trial/search";

  @override
  Future<List<Map<String, dynamic>>> fetchItemSuggestions(String query) async {
    final Uri url = Uri.parse(
        "$_baseUrlUpcItemDbSearch?s=$query&match_mode=1&type=product");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['items'] != null && data['items'].isNotEmpty) {
          return _parseItems(data['items']);
        }
      } else {
        debugPrint("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching suggestions: $e");
    }

    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchItemByBarcode(String barcode) async {
    final Uri url = Uri.parse("$_baseUrlUpcItemDbLookup?upc=$barcode");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['items'] != null && data['items'].isNotEmpty) {
          return _parseItems(data['items']);
        }
      } else {
        debugPrint("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching item by barcode: $e");
    }
    return [];
  }

  List<Map<String, dynamic>> _parseItems(List<dynamic> items) {
    return items.map<Map<String, dynamic>>((item) {
      return {
        'ean': item['ean'],
        'title': item['title'],
        'description': item['description'] ?? "",
        'upc': item['upc'],
        'brand': item['brand'] ?? "Unknown Brand",
        'model': item['model'] ?? "",
        'color': item['color'] ?? "",
        'size': item['size'] ?? "",
        'dimension': item['dimension'] ?? "",
        'weight': item['weight'] ?? "",
        'category': item['category'] ?? "Other",
        'lowestPrice': item['lowest_recorded_price']?.toString() ?? "",
        'highestPrice': item['highest_recorded_price']?.toString() ?? "",
        'images': (item['images'] as List<dynamic>?)
                ?.whereType<String>()
                .where((url) =>
                    url.isNotEmpty &&
                    Uri.tryParse(url)?.hasAbsolutePath == true)
                .toList() ??
            [],
        'offers': (item['offers'] as List<dynamic>?)
                ?.map((offer) => {
                      'merchant': offer['merchant'],
                      'domain': offer['domain'],
                      'title': offer['title'],
                      'price': offer['price']?.toString(),
                      'shipping': offer['shipping'],
                      'condition': offer['condition'],
                      'link': offer['link'],
                    })
                .toList() ??
            [],
      };
    }).toList();
  }
}
