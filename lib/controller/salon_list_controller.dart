import 'package:flutter/material.dart';
import '../model/salon.dart';

class SalonListController extends ChangeNotifier {
  List<Salon> _salons = [];
  List<Salon> _filteredSalons = [];

  List<Salon> get filteredSalons => _filteredSalons;

  SalonListController() {
    _fetchSalons();
  }

  void _fetchSalons() {
    // In a real app, you'd fetch this from an API
    _salons = [
      Salon(
        name: 'Nidhi Hair & Nail Salon',
        salonType: 'Hair Salon',
        address: 'KBT Circle, Nashik',
        rating: 4.9,
        clientCount: 299,
        imageUrl: 'https://images.pexels.com/photos/2811088/pexels-photo-2811088.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        description: 'A premium salon for all your hair and nail needs.',
        hasNewOffer: true,
      ),
      Salon(
        name: 'Vishakha Salon',
        salonType: 'Hair Salon',
        address: 'Dream Castle, Nashik',
        rating: 3.4,
        clientCount: 209,
        imageUrl: 'https://images.pexels.com/photos/705255/pexels-photo-705255.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        description: 'Look your best with our expert stylists.',
      ),
       Salon(
        name: 'Nidhi Hair & Nail Salon',
        salonType: 'Hair Salon',
        address: 'KBT Circle, Nashik',
        rating: 4.9,
        clientCount: 299,
        imageUrl: 'https://images.pexels.com/photos/2811088/pexels-photo-2811088.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        description: 'A premium salon for all your hair and nail needs.',
        hasNewOffer: true,
      ),
      Salon(
        name: 'Nidhi Hair & Nail Salon',
        salonType: 'Hair Salon',
        address: 'KBT Circle, Nashik',
        rating: 4.9,
        clientCount: 299,
        imageUrl: 'https://images.pexels.com/photos/705255/pexels-photo-705255.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        description: 'Look your best with our expert stylists.',
      ),
    ];
    _filteredSalons = _salons;
    notifyListeners();
  }

  void search(String query) {
    if (query.isEmpty) {
      _filteredSalons = _salons;
    } else {
      _filteredSalons = _salons.where((salon) {
        final queryLower = query.toLowerCase();
        return salon.name.toLowerCase().contains(queryLower) ||
               salon.address.toLowerCase().contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }
}
