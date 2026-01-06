import 'package:flutter/material.dart';
import 'package:glow_vita_salon/model/category.dart';
import '../model/offers.dart';
import '../model/product.dart';
import '../model/salon.dart';

import '../services/api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class HomeController extends ChangeNotifier {
  String location = "Fetching location..."; // Default or loading state
  bool isLoading = true;

  void updateLocation(String newLocation) {
    location = newLocation;
    notifyListeners();
  }

  final List<Offer> offers = ([
    {'title': '50% OFF', 'description': 'Floral Nail Art Designs', 'imageUrl': 'https://i.imgur.com/example_nail_art.png'},
    {'title': '40% OFF', 'description': 'Hair Color Combo: Global + Cut', 'imageUrl': 'https://i.imgur.com/example_hair_color.png'},
    {'title': '10% OFF', 'description': 'Detan + Cleanup', 'imageUrl': 'https://i.imgur.com/example_facial.png'},
  ]).map((data) => Offer.fromMap(data)).toList();

  final List<Category> categories = [
    Category(id: '1', name: 'Nail Salon', iconUrl: 'https://i.imgur.com/example_nails.png'),
    Category(id: '2', name: 'Hair Salon', iconUrl: 'https://i.imgur.com/example_hair.png'),
    Category(id: '3', name: 'Spa', iconUrl: 'https://i.imgur.com/example_spa.png'),
    Category(id: '4', name: 'Makeup', iconUrl: 'https://i.imgur.com/example_makeup.png'),
    Category(id: '5', name: 'Skin Care', iconUrl: 'https://i.imgur.com/example_skincare.png'),
    Category(id: '6', name: 'Bridal', iconUrl: 'https://i.imgur.com/example_bridal.png'),
  ];

  List<Salon> popularSalons = [];
  List<Salon> recommendedSalons = [];
  List<Product> products = [];

  HomeController() {
    _fetchData();
    _getUserLocation();
  }

  void _fetchData() async {
    try {
      isLoading = true;
      notifyListeners();

      print('Fetching data from API...');
      print('Fetching data from API...');
      final vendorsFuture = ApiService.getVendors();
      final productsFuture = ApiService.getProducts();

      final vendors = await vendorsFuture;
      final productsData = await productsFuture;

      final salons = vendors.map((vendor) => Salon.fromVendor(vendor)).toList();

      // Ensure we have enough salons to split
      if (salons.length >= 6) {
        popularSalons = salons.take(3).toList();
        recommendedSalons = salons.skip(3).take(3).toList();
      } else if (salons.length > 3) {
        popularSalons = salons.take(3).toList();
        recommendedSalons = salons.skip(3).toList();
      } else {
        popularSalons = salons;
        recommendedSalons = [];
      }

      products = productsData.take(4).toList();

      print('Data fetched successfully');
    } catch (e) {
      print('Error fetching data: $e');
      popularSalons = [];
      recommendedSalons = [];
      products = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        location = "Location disabled";
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          location = "Location denied";
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        location = "Location permanently denied";
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String newLocation = [
          place.subLocality,
          place.locality,
          place.administrativeArea
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        if (newLocation.isEmpty) {
          newLocation = "Unknown Location";
        }
        updateLocation(newLocation);
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      location = "Failed to get location";
      notifyListeners();
    }
  }
}
