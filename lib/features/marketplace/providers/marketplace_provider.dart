import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../cores/config/app_config.dart';
import '../models/item_model.dart';

class MarketplaceProvider extends ChangeNotifier {
  static String get baseUrl => AppConfig.apiBaseUrl;

  List<Item> _items = [];
  List<Item> _latestItems = [];

  bool _isLoading = false;
  String? _error;

  List<Item> get items => _items;
  List<Item> get latestItems => _latestItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Item _itemFromJson(dynamic itemJson) {
    return Item(
      id: int.parse(itemJson["id"].toString()),
      itemName: itemJson["item_name"],
      itemPrice: double.parse(itemJson["item_price"].toString()),
      description: itemJson["description"],
      category: itemJson["category"],
      createdAt: itemJson["created_at"],
      status: itemJson["status"] ?? "available",
    );
  }

  Future<void> fetchItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allResponse = await http
          .get(Uri.parse("$baseUrl/get_item.php"))
          .timeout(const Duration(seconds: 10));

      final allData = jsonDecode(allResponse.body);

      if (allData["success"] == true) {
        _items = (allData["items"] as List)
            .map((itemJson) => _itemFromJson(itemJson))
            .toList();
        _latestItems = _items.take(10).toList();
      } else {
        _error = "Failed to load items";
      }
    } catch (e) {
      _error = "Connection error: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Item? getItemById(int id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      try {
        return _latestItems.firstWhere((item) => item.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  void addItem(Item item) {
    _items.insert(0, item);
    _latestItems.insert(0, item);

    if (_latestItems.length > 10) {
      _latestItems = _latestItems.take(10).toList();
    }

    notifyListeners();
  }

  List<Item> searchItems(String query) {
    if (query.isEmpty) return _items;

    final lowerQuery = query.toLowerCase();

    return _items.where((item) {
      return item.itemName.toLowerCase().contains(lowerQuery) ||
          item.description.toLowerCase().contains(lowerQuery) ||
          item.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
