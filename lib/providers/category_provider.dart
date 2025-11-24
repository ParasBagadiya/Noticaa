import 'package:flutter/material.dart';
import 'package:noticaa/models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];

  List<Category> get categories => _categories;

  CategoryProvider() {
    _loadDefaultCategories();
  }

  void _loadDefaultCategories() {
    _categories = [
      Category(
        id: 'default',
        name: 'All Notes',
        color: Colors.blue,
        icon: Icons.note_rounded,
      ),
      Category(
        id: 'personal',
        name: 'Personal',
        color: Colors.green,
        icon: Icons.person_rounded,
      ),
      Category(
        id: 'work',
        name: 'Work',
        color: Colors.orange,
        icon: Icons.work_rounded,
      ),
      Category(
        id: 'ideas',
        name: 'Ideas',
        color: Colors.purple,
        icon: Icons.lightbulb_rounded,
      ),
      Category(
        id: 'important',
        name: 'Important',
        color: Colors.red,
        icon: Icons.star_rounded,
      ),
      Category(
        id: 'study',
        name: 'Study',
        color: Colors.teal,
        icon: Icons.school_rounded,
      ),
      Category(
        id: 'travel',
        name: 'Travel',
        color: Colors.pink,
        icon: Icons.flight_rounded,
      ),
      Category(
        id: 'shopping',
        name: 'Shopping',
        color: Colors.deepOrange,
        icon: Icons.shopping_cart_rounded,
      ),
    ];
    notifyListeners();
  }

  Category getCategoryById(String id) {
    return _categories.firstWhere(
      (category) => category.id == id,
      orElse: () => _categories.first,
    );
  }

  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }
  void removeCategory(String id) {
    _categories.removeWhere((category) => category.id == id);
    notifyListeners();
  }
}
