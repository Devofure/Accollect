import 'dart:async';

import 'package:accollect/data/item_suggestions_repository.dart';
import 'package:flutter/foundation.dart';

/// Model representing a single scanned item.
class ScannedItem {
  final String barcode;

  /// Additional details fetched from an online API (if available)
  final Map<String, dynamic>? details;

  ScannedItem({required this.barcode, this.details});
}

/// The view model that manages scanned items and fetches additional details.
class MultiItemScannerViewModel extends ChangeNotifier {
  final IItemSuggestionRepository suggestionRepository;
  final List<ScannedItem> _scannedItems = [];

  List<ScannedItem> get scannedItems => List.unmodifiable(_scannedItems);

  MultiItemScannerViewModel({required this.suggestionRepository});

  /// Adds a scanned barcode if not already present. Then fetches additional details.
  Future<void> addBarcode(String barcode) async {
    // Do not add duplicates.
    if (_scannedItems.any((item) => item.barcode == barcode)) return;

    Map<String, dynamic>? details;
    try {
      final suggestions =
          await suggestionRepository.fetchItemByBarcode(barcode);
      if (suggestions.isNotEmpty) {
        details = suggestions.first;
      }
    } catch (e) {
      debugPrint("Error fetching details for barcode $barcode: $e");
    }
    _scannedItems.add(ScannedItem(barcode: barcode, details: details));
    notifyListeners();
  }

  void removeBarcode(String barcode) {
    _scannedItems.removeWhere((item) => item.barcode == barcode);
    notifyListeners();
  }

  void clearAll() {
    _scannedItems.clear();
    notifyListeners();
  }
}
