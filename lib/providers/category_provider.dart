import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final List<String> _categories = ["Auto", "Cibo", "Casa", "Bolletta"];

  List<String> get categories => _categories;

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();
    }
  }
}
