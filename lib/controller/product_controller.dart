import 'package:flutter/material.dart';
import '../model/product.dart';

class ProductController {
  late VoidCallback onStateChanged;

  List<Product> flashSaleProducts = [];
  List<Product> allProducts = [];
  List<Product> filteredProducts = [];
  List<String> categories = [];
  String? selectedCategory;

  bool isLoading = true;
  
  void init() {
    _loadProducts();
  }

  void _loadProducts() async {
    isLoading = true;
    onStateChanged();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));


    _updateCategories();
    _filterProducts();
    isLoading = false;
    onStateChanged();
  }

  void _updateCategories() {
    categories = allProducts.map((p) => p.category).toSet().toList();
  }

  void _filterProducts() {
    if (selectedCategory == null) {
      filteredProducts = List.from(allProducts);
    } else {
      filteredProducts = allProducts.where((p) => p.category == selectedCategory).toList();
    }
  }

  void selectCategory(String? category) {
    selectedCategory = category;
    _filterProducts();
    onStateChanged();
  }
}
