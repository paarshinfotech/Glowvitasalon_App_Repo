import 'package:flutter/material.dart';
import '../model/salon.dart';
import '../services/api_service.dart';

class SalonListController extends ChangeNotifier {
  List<Salon> _salons = [];
  List<Salon> _filteredSalons = [];
  bool _isLoading = false;

  List<Salon> get filteredSalons => _filteredSalons;
  bool get isLoading => _isLoading;

  SalonListController() {
    _fetchSalons();
  }

  void _fetchSalons() async {
    _isLoading = true;
    notifyListeners();

    try {
      final vendors = await ApiService.getVendors();
      _salons = vendors.map((vendor) => Salon.fromVendor(vendor)).toList();
      _filteredSalons = _salons;
    } catch (e) {
      print('Error fetching vendors: $e');
      // Keep the static data as fallback if API fails
      _salons = [
        Salon(
          id: '6915a50fd303709d2be34774',
          name: 'Nidhi Hair & Nail Salon',
          salonType: 'Hair Salon',
          address: 'KBT Circle, Nashik',
          rating: 4.9,
          clientCount: 299,
          imageUrl:
              'https://images.pexels.com/photos/2811088/pexels-photo-2811088.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          description: 'A premium salon for all your hair and nail needs.',
          hasNewOffer: true,
        ),
        Salon(
          id: 'static_2',
          name: 'Vishakha Salon',
          salonType: 'Hair Salon',
          address: 'Dream Castle, Nashik',
          rating: 3.4,
          clientCount: 209,
          imageUrl:
              'https://images.pexels.com/photos/705255/pexels-photo-705255.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          description: 'Look your best with our expert stylists.',
        ),
      ];
      _filteredSalons = _salons;
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
        final queryLower = query.toLowerCase();

        final nameMatch = salon.name.toLowerCase().contains(queryLower);
        final addressMatch = salon.address.toLowerCase().contains(queryLower);
        final typeMatch = salon.salonType.toLowerCase().contains(queryLower);

        // Search in subCategories
        final subCategoryMatch = salon.subCategories.any(
          (sub) => sub.toLowerCase().contains(queryLower),
        );

        // Search in services
        final serviceMatch = salon.services.any(
          (service) => service.category.toLowerCase().contains(queryLower),
        );

        return nameMatch ||
            addressMatch ||
            typeMatch ||
            subCategoryMatch ||
            serviceMatch;
      }).toList();
    }
    notifyListeners();
  }
}
