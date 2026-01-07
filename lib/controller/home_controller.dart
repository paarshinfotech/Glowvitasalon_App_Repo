import 'package:flutter/material.dart';
import 'package:glow_vita_salon/model/category.dart';
import '../model/offers.dart';
import '../model/product.dart';
import '../model/salon.dart';
import '../model/vendor.dart';

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
    {
      'title': '50% OFF',
      'description': 'Floral Nail Art Designs',
      'imageUrl': 'https://i.imgur.com/example_nail_art.png',
    },
    {
      'title': '40% OFF',
      'description': 'Hair Color Combo: Global + Cut',
      'imageUrl': 'https://i.imgur.com/example_hair_color.png',
    },
    {
      'title': '10% OFF',
      'description': 'Detan + Cleanup',
      'imageUrl': 'https://i.imgur.com/example_facial.png',
    },
  ]).map((data) => Offer.fromMap(data)).toList();

  List<Category> categories = [];

  List<Salon> allSalons = []; // Store all salons for filtering
  List<Salon> popularSalons = [];
  List<Salon> recommendedSalons = [];
  List<Product> products = [];

  HomeController() {
    _fetchData();
    _getUserLocation();
  }

  Future<void> _fetchData() async {
    try {
      isLoading = true;
      // notifyListeners(); // Avoid unnecessary rebuilds if called from constructor

      print('Fetching data from API...');

      // Fetch all APIs in parallel using Future.wait
      // This significantly reduces load time compared to sequential awaits
      final results = await Future.wait([
        ApiService.getVendors(),
        ApiService.getProducts(),
        ApiService.getCategories(),
      ]);

      final vendors =
          results[0]
              as List<dynamic>; // Cast is safe due to ApiService return types
      final productsData = results[1] as List<Product>;
      final categoriesData = results[2] as List<Category>;

      // Perform heavy mapping/processing here
      final salons = vendors.map((vendor) {
        if (vendor is Vendor) {
          return Salon.fromVendor(vendor);
        }
        // Handle edge case if getVendors returns plain dynamic list which it shouldn't
        return Salon.fromVendor(vendor as Vendor);
      }).toList();

      categories = categoriesData;
      allSalons = salons; // Store all salons

      // Logic to split salons (Client-side logic is fast)
      // Logic to split salons (Client-side logic is fast)
      if (salons.length >= 8) {
        popularSalons = salons.take(4).toList();
        recommendedSalons = salons.skip(4).take(4).toList();
      } else if (salons.length > 4) {
        popularSalons = salons.take(4).toList();
        recommendedSalons = salons.skip(4).toList();
      } else {
        // Fallback for limited data: Show same salons but maybe reversed/shuffled
        popularSalons = salons;
        recommendedSalons = List.from(salons.reversed);
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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String newLocation = [
          place.subLocality,
          place.locality,
          place.administrativeArea,
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
