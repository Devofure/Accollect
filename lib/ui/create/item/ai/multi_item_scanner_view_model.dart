import 'package:accollect/data/item_suggestions_repository.dart';
import 'package:flutter/foundation.dart';

/// Model representing a single scanned item.
class ScannedItem {
  final String barcode;
  final String barcodeType; // New: Track barcode type
  final Map<String, dynamic>? details;
  final DateTime scannedAt;

  ScannedItem({
    required this.barcode,
    required this.barcodeType,
    this.details,
  }) : scannedAt = DateTime.now();
}

class MultiItemScannerViewModel extends ChangeNotifier {
  final IItemSuggestionRepository suggestionRepository;
  final List<ScannedItem> _scannedItems = [];
  final Set<String> _scannedBarcodes = {};

  List<ScannedItem> get scannedItems => List.unmodifiable(_scannedItems);

  MultiItemScannerViewModel({required this.suggestionRepository});

  /// Adds a barcode if it's new and fetches additional details.
  /// Returns `true` if the barcode was added, `false` if it was a duplicate.
  Future<bool> addBarcode(String barcode, String barcodeType) async {
    if (_scannedBarcodes.contains(barcode)) return false;

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

    final newItem = ScannedItem(
        barcode: barcode, barcodeType: barcodeType, details: details);
    _scannedItems.add(newItem);
    _scannedBarcodes.add(barcode);
    notifyListeners();
    return true;
  }

  void removeBarcode(String barcode) {
    _scannedItems.removeWhere((item) => item.barcode == barcode);
    _scannedBarcodes.remove(barcode);
    notifyListeners();
  }

  void clearAll() {
    _scannedItems.clear();
    _scannedBarcodes.clear();
    notifyListeners();
  }
}
