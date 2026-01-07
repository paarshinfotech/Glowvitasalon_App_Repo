import 'package:flutter/material.dart';
import '../model/salon.dart';
import '../services/api_service.dart';

class SalonListController extends ChangeNotifier {
  List<Salon> _salons = [];
  List<Salon> _filteredSalons = [];
  bool _isLoading = false;

  List<Salon> get filteredSalons => _filteredSalons;
  bool get isLoading => _isLoading;

  List<String> _categories = [];
  List<String> get categories => _categories;

  SalonListController() {
    _fetchData();
  }

  void _fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiService.getVendors(),
        ApiService.getCategories(),
      ]);

      final vendors = results[0] as List<dynamic>;
      final categoriesData = results[1] as List<dynamic>;

      _salons = vendors.map((vendor) => Salon.fromVendor(vendor)).toList();
      _filteredSalons = _salons;

      // Extract category names for suggestion chips
      _categories = categoriesData.map((cat) => cat.name as String).toList();
    } catch (e) {
      print('Error fetching data for search: $e');
      // Keep fallback data logic or handle empty state
      if (_salons.isEmpty) {
        // ... static fallback ...
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      _filteredSalons = _salons;
    } else {
      _filteredSalons = _salons.where((salon) {
        final queryLower = query.toLowerCase().trim();
        if (queryLower.isEmpty) return true;

        final terms = queryLower
            .split(RegExp(r'\s+'))
            .where((t) => t.isNotEmpty);

        // Construct a searchable corpus for this salon
        final StringBuffer buffer = StringBuffer();
        buffer.write(salon.name.toLowerCase());
        buffer.write(" ");
        buffer.write(salon.address.toLowerCase());
        buffer.write(" ");
        buffer.write(salon.salonType.toLowerCase());
        buffer.write(" ");
        // Add subcategories
        for (var sub in salon.subCategories) {
          buffer.write(sub.toLowerCase());
          buffer.write(" ");
        }
        // Add services
        for (var service in salon.services) {
          buffer.write(service.name.toLowerCase());
          buffer.write(" ");
          buffer.write(service.category.toLowerCase());
          buffer.write(" ");
        }

        final searchableText = buffer.toString();

        // Check if ALL terms match the searchable text (AND logic)
        return terms.every((term) {
          if (term.length == 1) {
            // For single character, force "Starts with" logic (Word Boundary)
            // This prevents "a" from matching "Salon"
            return RegExp('\\b${RegExp.escape(term)}').hasMatch(searchableText);
          }
          // For longer terms, standard "contains" is better (e.g. "cut" matches "Haircut")
          return searchableText.contains(term);
        });
      }).toList();
    }
    notifyListeners();
  }
}
